import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_model.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_model_adapter.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_socketio_adapter.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';
import 'package:flutter_appirc/disposable/async_disposable.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/irc/irc_commands_model.dart';

import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_request_model.dart';
import 'package:flutter_appirc/lounge/lounge_response_model.dart';
import 'package:flutter_appirc/lounge/upload/lounge_upload_file_helper.dart';
import 'package:flutter_appirc/socketio/instance/socketio_instance_bloc.dart';
import 'package:flutter_appirc/socketio/socket_io_service.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/subjects.dart';

var _logger = Logger("lounge_backend_service.dart");

var _connectTimeout = Duration(seconds: 15);
const _timeBetweenCheckingConnectionResponse = Duration(milliseconds: 500);

const _timeoutForRequestsWithResponse = Duration(seconds: 10);
const _timeBetweenCheckResultForRequestsWithResponse =
    Duration(milliseconds: 100);

class LoungeBackendService extends DisposableOwner
    implements ChatBackendService {
  final LoungePreferences loungePreferences;
  final SocketIOService socketIoService;
  SocketIOInstanceBloc _socketIOInstanceBloc;

  @override
  Stream<bool> get isChatConfigExistStream => chatConfigStream.map(
        (chatConfig) => chatConfig != null,
      );

  @override
  bool get isConnected => connectionState == ChatConnectionState.connected;

  @override
  Stream<bool> get isConnectedStream => connectionStateStream
      .map((state) => state == ChatConnectionState.connected)
      .distinct();

  // ignore: close_sinks
  final BehaviorSubject<ChatConnectionState> _connectionStateSubject =
      BehaviorSubject.seeded(
    ChatConnectionState.disconnected,
  );

  @override
  Stream<ChatConnectionState> get connectionStateStream =>
      _connectionStateSubject.stream.distinct();

  @override
  ChatConnectionState get connectionState => _connectionStateSubject.value;

  // ignore: close_sinks
  final BehaviorSubject<ChatConfig> _chatConfigSubject = BehaviorSubject();

  @override
  Stream<ChatConfig> get chatConfigStream => _chatConfigSubject.stream;

  @override
  ChatConfig get chatConfig => _chatConfigSubject.value;

  @override
  ChatInitInformation chatInit;

  // ignore: close_sinks
  final BehaviorSubject<bool> _signOutSubject = BehaviorSubject();

  // lounge don't response properly to edit request
  // ignore: close_sinks
  final BehaviorSubject<NetworkPreferences> _editNetworkRequests =
      BehaviorSubject();

  bool get isSocketIOServiceExist => _socketIOInstanceBloc != null;

  bool get isConnectionStateDisconnected =>
      connectionState == ChatConnectionState.disconnected;

  bool get isLoungePreferencesExistAndNotEmpty =>
      loungePreferences != null && loungePreferences != LoungePreferences.empty;

  @override
  bool get isReadyToConnect =>
      isSocketIOServiceExist &&
      isConnectionStateDisconnected &&
      isLoungePreferencesExistAndNotEmpty;

  // Lounge API don't return all information required by the app
  // So, in some cases we should store original request to use it in response
  // handler
  // For example, when lounge in public mode  we should save original
  // network/channel join request to save password which doesn't exist in
  // response
  final List<LoungeRequest> _pendingRequests = [];

  LoungeBackendService({
    @required this.socketIoService,
    @required this.loungePreferences,
  }) {
    addDisposable(subject: _signOutSubject);
    addDisposable(subject: _connectionStateSubject);
    addDisposable(subject: _editNetworkRequests);
    addDisposable(subject: _messageTogglePreviewSubject);
    addDisposable(subject: _chatConfigSubject);
  }

  Future<int> Function() lastMessageRemoteIdExtractor;

  Future init({
    @required Channel Function() currentChannelExtractor,
    @required Future<int> Function() lastMessageRemoteIdExtractor,
  }) async {
    _logger.fine(() => "init started");

    this.lastMessageRemoteIdExtractor = lastMessageRemoteIdExtractor;

    var host = loungePreferences.hostPreferences.host;
    _socketIOInstanceBloc = SocketIOInstanceBloc(
      socketIoService: socketIoService,
      uri: host,
    );

    await _socketIOInstanceBloc.init();

    _listenForInit(_socketIOInstanceBloc, (init) {
      _logger.fine(() => "debug init $init");

      // TODO: don't know why. But init not called after reconnection without
      //  this debug subscription
      // maybe bug in socket io lib
    });

    _listenForAuth(
      _socketIOInstanceBloc,
      (auth) async {
        if (chatInit != null) {
          // reconnect
          var authToken = chatInit.authToken;
//        var lastMessage =
//            await chatDatabase.regularMessagesDao.getLatestMessage();

          _logger.fine(() => "auth after reconnecting"
              " authToken $authToken"
              " auth $auth");

          var result = await authAfterReconnect(
              token: authToken,
              activeChannelId: currentChannelExtractor()?.remoteId,
              lastMessageId: await lastMessageRemoteIdExtractor(),
              user: loungePreferences?.authPreferences?.username,
              waitForResult: true);

          _logger.fine(() => "auth after reconnecting result $result");
        }
      },
    );

    addDisposable(
      streamSubscription: _socketIOInstanceBloc.connectionStateStream.listen(
        (socketState) {
          ChatConnectionState newBackendState = mapConnectionState(socketState);

          // reconnecting
          if (newBackendState == ChatConnectionState.connected &&
              chatInit != null) {
            // send connect after reconnecting. required by lounge
            _socketIOInstanceBloc.connect();
          }

          _logger.fine(() => "newState socketState $socketState "
              " newBackendState $newBackendState");
          _connectionStateSubject.add(newBackendState);
        },
      ),
    );
    _logger.fine(() => "init finished");
  }

  @override
  Future<RequestResult<ChatLoginResult>> connectChat() async {
    _logger.fine(() => "connectChat");

    assert(
      loungePreferences != null && loungePreferences != LoungePreferences.empty,
    );
    _logger.fine(() => "connectChat _loungePreferences $loungePreferences");

    _connectionStateSubject.add(ChatConnectionState.connecting);

    RequestResult<ChatLoginResult> requestResult =
        await _connectAndLogin(loungePreferences, _socketIOInstanceBloc);

    ChatLoginResult loginResult = requestResult.result;

    if (loginResult.config != null) {
      _chatConfigSubject.add(loginResult.config);
      chatInit = loginResult.chatInit;

      // socket io callback very slow
      _connectionStateSubject.add(ChatConnectionState.connected);
    } else {
      _connectionStateSubject.add(ChatConnectionState.disconnected);
    }

    _logger.fine(() => "connectChat loginResult = $loginResult");

    return requestResult;
  }

  IDisposable listenForConfiguration(
          Function(ConfigurationLoungeResponseBody) listener) =>
      _listenForConfiguration(
        _socketIOInstanceBloc,
        listener,
      );

  IDisposable listenForCommands(Function(List<String>) listener) =>
      _listenForCommands(
        _socketIOInstanceBloc,
        listener,
      );

  IDisposable listenForAuthorized(VoidCallback listener) =>
      _listenForAuthorized(
        _socketIOInstanceBloc,
        listener,
      );

  IDisposable createEventListenerDisposable(
    String eventName,
    Function(dynamic raw) listener,
  ) =>
      _createEventListenerDisposable(
        _socketIOInstanceBloc,
        eventName,
        listener,
      );

  @override
  Future<RequestResult<bool>> disconnectChat({
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw const NotImplementedYetLoungeException();
    }
    await disconnect();
    return const RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<bool>> editChannelTopic(
    Network network,
    Channel channel,
    String newTopic, {
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw const NotImplementedYetLoungeException();
    }
    _sendInputRequest(
      network,
      channel,
      TopicIRCCommand(
        newTopic: newTopic,
      ).asRawString,
    );
    return const RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<Network>> editNetworkSettings(
    Network network,
    NetworkPreferences networkPreferences, {
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }

    // todo: open ticket for lounge
    // if you change nickname to registered nickname on Freenode
    // then you should write additional query to identify user with password
    // Lounge API should send this request once new settings arrived
    var userPreferences =
        networkPreferences.networkConnectionPreferences.userPreferences;
    var serverPreferences =
        networkPreferences.networkConnectionPreferences.serverPreferences;

    var request = toNetworkEditLoungeRequestBody(
        network.remoteId, userPreferences, serverPreferences);

    // important to put request before send it
    _editNetworkRequests.add(networkPreferences);

    await _sendRequest(request, isNeedAddRequestToPending: false);

    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<bool>> enableNetwork(
    Network network, {
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
        network, network.lobbyChannel, ConnectIRCCommand().asRawString);
    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<bool>> disableNetwork(
    Network network, {
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
        network, network.lobbyChannel, DisconnectIRCCommand().asRawString);
    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<List<ChannelUser>>> requestChannelUsers(
    Network network,
    Channel channel, {
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }

    var request = NamesLoungeJsonRequest(
      target: channel.remoteId,
    );
    await _sendRequest(
      request,
      isNeedAddRequestToPending: false,
    );

    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<ChannelUser>> requestUserInfo(
    Network network,
    Channel channel,
    String userNick, {
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
        network, channel, WhoIsIRCCommand.name(userNick: userNick).asRawString);
    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<NetworkWithState>> joinNetwork(
    NetworkPreferences networkPreferences, {
    bool waitForResult = false,
  }) async {
    var serverPreferences =
        networkPreferences.networkConnectionPreferences.serverPreferences;

    var channelsWithoutPassword = networkPreferences.channelsWithoutPassword;
    var channelNames = channelsWithoutPassword.map((channel) => channel.name);
    String join = channelNames.join(LoungeConstants.channelsNamesSeparator);
    var request = ChatNetworkNewLoungeJsonRequest(
      networkPreferences: networkPreferences,
      join: join,
    );

    var result;
    IDisposable networkListener;
    networkListener = listenForNetworkJoin((networkWithState) async {
      var networkFromResult = networkWithState.network;

      if (networkFromResult.name == serverPreferences.name) {
        var channelsWithPassword = networkPreferences.channelsWithPassword;

        _logger.fine(
            () => "joinNetwork channelsWithPassword $channelsWithPassword");

        if (channelsWithPassword.isNotEmpty) {
          // it is bug in the lounge.
          // We should wait some time after join network
          // to start send requests to network
          // Lounge don't respond with error, it is just don't execute requests
          // It looks like bug exist only in public mode
          // Lounge doesn't execute request if network not created/connected
          // Lounge should send event when network is ready to receive commands
          // Also lounge should return error if something wrong
          // todo: open request for lounge server to fix this issue
          await Future.delayed(Duration(seconds: 5));

          for (var channelPreferences in channelsWithPassword) {
            var joinChannelResult = await joinChannel(
                networkWithState.network, channelPreferences,
                waitForResult: true);
            _logger
                .fine(() => "joinNetwork joinChannelResult $joinChannelResult");

            if (joinChannelResult.result != null) {
              var channel = joinChannelResult.result.channel;
              _logger.fine(
                () => "joinNetwork "
                    "channelPreferences $channelPreferences "
                    "result = $channel",
              );
              assert(channel != null);
              networkFromResult.channels.add(channel);
            }
          }
        }

        result = networkWithState;
        await networkListener.dispose();
      }
    });
    await _sendRequest(request, isNeedAddRequestToPending: true);

    if (waitForResult) {
      return await _doWaitForResult<NetworkWithState>(() => result);
    } else {
      return RequestResult.notWaitForResponse();
    }
  }

  @override
  Future<RequestResult<ChannelWithState>> joinChannel(
    Network network,
    ChannelPreferences preferences, {
    bool waitForResult = false,
  }) async {
    _logger.fine(() => "joinChannel $preferences waitForResult $waitForResult");

    var request = ChatJoinChannelInputLoungeJsonRequest(
      preferences: preferences,
      target: network.lobbyChannel.remoteId,
    );

    var result;
    IDisposable channelListener;
    channelListener = listenForChannelJoin(network, (channelWithState) async {
      var isForRequest = channelWithState.channel.name == preferences.name;
      _logger.fine(() => "joinChannel listenForChannelJoin $channelWithState "
          "isForRequest= $isForRequest");
      if (isForRequest) {
        result = channelWithState;
        await channelListener.dispose();
      }
    });
    await _sendRequest(request, isNeedAddRequestToPending: true);

    if (waitForResult) {
      return await _doWaitForResult<ChannelWithState>(() => result);
    } else {
      return RequestResult.notWaitForResponse();
    }
  }

  @override
  Future<RequestResult<ChannelWithState>> openDirectMessagesChannel(
    Network network,
    Channel channel,
    String nick, {
    bool waitForResult = false,
  }) async {
    var request = InputLoungeJsonRequest(
      target: channel.remoteId, // private channel name is equal to nickname
      text: JoinIRCCommand(
        channelName: nick,
      ).asRawString,
    );

    var result;
    IDisposable channelListener;
    channelListener = listenForChannelJoin(network, (channelWithState) async {
      result = channelWithState;
      await channelListener.dispose();
    });
    await _sendRequest(request, isNeedAddRequestToPending: true);

    if (waitForResult) {
      return await _doWaitForResult<ChannelWithState>(() => result);
    } else {
      return RequestResult.notWaitForResponse();
    }
  }

  @override
  Future<RequestResult<bool>> leaveNetwork(
    Network network, {
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
        network, network.lobbyChannel, QuitIRCCommand().asRawString);
    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<bool>> leaveChannel(
    Network network,
    Channel channel, {
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(network, channel, CloseIRCCommand().asRawString);
    return RequestResult.notWaitForResponse();
  }

  @override
  IDisposable listenForMessages(
    Network network,
    Channel channel,
    ChannelMessageListener listener,
  ) {
    var disposable = CompositeDisposable([]);

    disposable.add(
      _listenForInit(
        _socketIOInstanceBloc,
        (initResponse) {
          // new messages after reconnect

          var channelsWithState = initResponse.channelsWithState;

          var channelWithState = channelsWithState.firstWhere(
            (channelsWithState) =>
                channelsWithState.channel.remoteId == channel.remoteId,
            orElse: () => null,
          );

          if (channelWithState != null) {
            listener(MessagesForChannel.name(
                channel: channel,
                messages: channelWithState.initMessages,
                isNeedCheckAdditionalLoadMore: true,
                isNeedCheckAlreadyExistInLocalStorage: true));
          }
        },
      ),
    );

    disposable.add(
      createEventListenerDisposable(
        MsgLoungeResponseBody.eventName,
        (raw) {
          var data = MsgLoungeResponseBody.fromJson(
              _preProcessRawDataEncodeDecodeJson(raw));

          if (channel.remoteId == data.chan) {
            toChatMessage(channel, data.msg).then(
              (message) {
                _logger.fine(() => "onNewMessage for {$data.chan}  $data");
                var type = detectRegularMessageType(data.msg.type);
                if (type == RegularMessageType.whoIs) {
                  // lounge send whois message as regular
                  // but actually lounge client display it as special
                  _toWhoIsSpecialMessage(data).then((message) {
                    listener(MessagesForChannel.name(
                        isNeedCheckAlreadyExistInLocalStorage: true,
                        isNeedCheckAdditionalLoadMore: false,
                        channel: channel,
                        messages: <ChatMessage>[message]));
                  });
                } else {
                  listener(MessagesForChannel.name(
                      isNeedCheckAlreadyExistInLocalStorage: false,
                      isNeedCheckAdditionalLoadMore: false,
                      channel: channel,
                      messages: <ChatMessage>[message]));
                }
              },
            );
          }
        },
      ),
    );

    disposable.add(
      createEventListenerDisposable(
        MsgSpecialLoungeResponseBody.eventName,
        (raw) {
          MsgSpecialLoungeResponseBody data =
              MsgSpecialLoungeResponseBody.fromJson(
                  _preProcessRawDataEncodeDecodeJson(raw));

          if (channel.remoteId == data.chan) {
            toSpecialMessages(channel, data).then(
              (specialMessages) {
                if (specialMessages.length == 1 &&
                    specialMessages.first.specialType ==
                        SpecialMessageType.text) {
                  return;
                }
                listener(MessagesForChannel.name(
                    isNeedCheckAlreadyExistInLocalStorage: false,
                    isNeedCheckAdditionalLoadMore: false,
                    channel: channel,
                    messages: specialMessages,
                    isContainsTextSpecialMessage: true));
              },
            );
          }
        },
      ),
    );

    disposable.add(
      listenForLoadMore(
        network,
        channel,
        (loadMoreResponse) {
          listener(MessagesForChannel.name(
              isNeedCheckAlreadyExistInLocalStorage: false,
              isNeedCheckAdditionalLoadMore: true,
              channel: channel,
              messages: loadMoreResponse.messages));
        },
      ),
    );

    return disposable;
  }

  Future<SpecialMessage> _toWhoIsSpecialMessage(
    MsgLoungeResponseBody data,
  ) async {
    var whoIsSpecialBody = toWhoIsSpecialMessageBody(
      data.msg.whois,
    );

    return SpecialMessage(
      channelRemoteId: data.chan,
      data: whoIsSpecialBody,
      specialType: SpecialMessageType.whoIs,
      date: DateTime.now(),
      linksInMessage: null,
    );
  }

  @override
  IDisposable listenForChannelJoin(
    Network network,
    ChannelListener listener,
  ) {
    _logger.fine(() => "listenForChannelJoin $network");

    var disposable = CompositeDisposable([]);
    disposable.add(
      createEventListenerDisposable(
        JoinLoungeResponseBody.eventName,
        (raw) {
          var parsed = JoinLoungeResponseBody.fromJson(
              _preProcessRawDataEncodeDecodeJson(raw));

          _logger.fine(() => "listenForChannelJoin "
              "parsed $parsed network.remoteId = $network.remoteId");
          if (parsed.network == network.remoteId) {
            ChatJoinChannelInputLoungeJsonRequest request =
                _findJoinChannelOriginalRequest(
              _pendingRequests,
              parsed,
            );

            var preferences;

            if (request != null) {
              preferences = ChannelPreferences.name(
                localId: request.preferences.localId,
                name: parsed.chan.name,
                password: request.preferences.password,
              );
              _pendingRequests.remove(request);
            } else {
              preferences = ChannelPreferences.name(
                name: parsed.chan.name,
                password: "",
              );
            }

            var loungeChannel = parsed.chan;

            toChannelWithState(loungeChannel).then(
              (channelWithState) {
                channelWithState.channel.channelPreferences = preferences;

                listener(channelWithState);
              },
            );
          }
        },
      ),
    );

    return disposable;
  }

  @override
  IDisposable listenForChannelLeave(
    Network network,
    Channel channel,
    VoidCallback listener,
  ) {
    var disposable = CompositeDisposable([]);
    disposable.add(
      createEventListenerDisposable(
        (PartLoungeResponseBody.eventName),
        (raw) {
          var parsed = PartLoungeResponseBody.fromJson(
              _preProcessRawDataEncodeDecodeJson(raw));

          if (parsed.chan == channel.remoteId) {
            listener();
          }
        },
      ),
    );

    return disposable;
  }

  @override
  IDisposable listenForChannelState(
    Network network,
    Channel channel,
    ChannelState Function() currentStateExtractor,
    Future<int> Function() currentMessageCountExtractor,
    ChannelStateListener listener,
  ) {
    var disposable = CompositeDisposable([]);
    disposable.add(
      createEventListenerDisposable(
        MsgLoungeResponseBody.eventName,
        (raw) {
          var data = MsgLoungeResponseBody.fromJson(
              _preProcessRawDataEncodeDecodeJson(raw));

          if (channel.remoteId == data.chan) {
            if (data.unread != null) {
              var channelState = currentStateExtractor();
              channelState.unreadCount = data.unread;
              listener(channelState);
            }
          }
        },
      ),
    );
    disposable.add(
      createEventListenerDisposable(
        MoreLoungeResponseBody.eventName,
        (raw) async {
          var parsed = MoreLoungeResponseBody.fromJson(
              _preProcessRawDataEncodeDecodeJson(raw));

          if (channel.remoteId == parsed.chan) {
            var channelState = currentStateExtractor();

            var currentMessageCount = await currentMessageCountExtractor();
            var totalMessages = parsed.totalMessages;
            var _moreHistoryAvailable = totalMessages > currentMessageCount;
            _logger.fine(
                () => "load more current $currentMessageCount totalMessages"
                    " totalMessages $totalMessages"
                    "_moreHistoryAvailable $_moreHistoryAvailable");

            channelState.moreHistoryAvailable = _moreHistoryAvailable;
            listener(channelState);
          }
        },
      ),
    );

    disposable.add(
      createEventListenerDisposable(
        TopicLoungeResponseBody.eventName,
        (raw) {
          var data = TopicLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw,
            ),
          );

          if (channel.remoteId == data.chan) {
            var channelState = currentStateExtractor();
            channelState.topic = data.topic;
            listener(channelState);
          }
        },
      ),
    );

    disposable.add(
      createEventListenerDisposable(
        ChannelStateLoungeResponseBody.eventName,
        (raw) {
          var data = ChannelStateLoungeResponseBody.fromJson(
              _preProcessRawDataEncodeDecodeJson(raw));

          if (channel.remoteId == data.chan) {
            var channelState = currentStateExtractor();
            if (data.state == ChannelStateLoungeConstants.connected) {
              channelState.connected = true;
            } else {
              channelState.connected = false;
            }

            listener(channelState);
          }
        },
      ),
    );

    return disposable;
  }

  @override
  IDisposable listenForChannelUsers(
    Network network,
    Channel channel,
    VoidCallback listener,
  ) {
    var disposable = CompositeDisposable([]);
    disposable.add(
      createEventListenerDisposable(
        (UsersLoungeResponseBody.eventName),
        (raw) {
          var parsed = UsersLoungeResponseBody.fromJson(
              _preProcessRawDataEncodeDecodeJson(raw));

          if (parsed.chan == channel.remoteId) {
            listener();
          }
        },
      ),
    );

    return disposable;
  }

  @override
  IDisposable listenForNetworkJoin(NetworkListener listener) {
    var disposable = CompositeDisposable(
      [],
    );

    disposable.add(
      createEventListenerDisposable(
        NetworkLoungeResponseBody.eventName,
        (raw) {
          var parsed = NetworkLoungeResponseBody.fromJson(
              _preProcessRawDataEncodeDecodeJson(raw));

          _logger.fine(() => "listenForNetworkJoin parsed = $parsed");

          for (var loungeNetwork in parsed.networks) {
            // Why lounge sent array of networks?
            // It is possible to join only one network Lounge API per request
            // Lounge should send only one network in this response
            // todo: open ticket for lounge
            ChatNetworkNewLoungeJsonRequest request =
                _findOriginalJoinNetworkRequest(
                    _pendingRequests, loungeNetwork);

            _pendingRequests.remove(request);

            var connectionPreferences =
                request.networkPreferences.networkConnectionPreferences;

            // when requested nick is not available and server give new nick
            var nick = loungeNetwork.nick;
            connectionPreferences.userPreferences.nickname = nick;

            toNetworkWithState(loungeNetwork).then(
              (networkWithState) {
                networkWithState.network.localId =
                    request.networkPreferences.localId;

                networkWithState.network.channels.forEach((channel) {
                  var channelPreferences = request.networkPreferences.channels
                      .firstWhere((channelPreferences) {
                    return channel.name == channelPreferences.name;
                  }, orElse: () => null);

                  if (channelPreferences != null) {
                    channel.localId = channelPreferences.localId;
                  }
                });

                networkWithState.network.connectionPreferences =
                    connectionPreferences;

                listener(networkWithState);
              },
            );
          }
        },
      ),
    );

    return disposable;
  }

  @override
  IDisposable listenForNetworkLeave(Network network, VoidCallback listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(
      createEventListenerDisposable(
        (QuitLoungeResponseBody.eventName),
        (raw) {
          var parsed = QuitLoungeResponseBody.fromJson(
              _preProcessRawDataEncodeDecodeJson(raw));

          if (parsed.network == network.remoteId) {
            listener();
          }
        },
      ),
    );

    return disposable;
  }

  @override
  IDisposable listenForMessagePreviews(Network network, Channel channel,
      ChannelMessagePreviewListener listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(
      createEventListenerDisposable(
        (MsgPreviewLoungeResponseBody.eventName),
        (raw) {
          var parsed = MsgPreviewLoungeResponseBody.fromJson(
              _preProcessRawDataEncodeDecodeJson(raw));

          if (parsed.chan == channel.remoteId) {
            listener(MessagePreviewForRemoteMessageId(
                parsed.id, toMessagePreview(parsed.preview)));
          }
        },
      ),
    );

    return disposable;
  }

  @override
  IDisposable listenForNetworkEdit(
      Network network, NetworkConnectionListener listener) {
    return StreamSubscriptionDisposable(
      _editNetworkRequests.listen(
        (NetworkPreferences networkPreferences) {
          if (network.connectionPreferences.localId ==
              networkPreferences.localId) {
            listener(networkPreferences);
          }
        },
      ),
    );
  }

  @override
  IDisposable listenForNetworkState(
      Network network,
      NetworkState Function() currentStateExtractor,
      NetworkStateListener listener) {
    var disposable = CompositeDisposable([]);

    disposable.add(
      StreamSubscriptionDisposable(
        _editNetworkRequests.listen(
          (NetworkPreferences networkPreferences) {
            if (network.connectionPreferences.localId ==
                networkPreferences.localId) {
              var currentState = currentStateExtractor();
              currentState.name = networkPreferences
                  .networkConnectionPreferences.serverPreferences.name;
              listener(currentState);
            }
          },
        ),
      ),
    );

    disposable.add(
      createEventListenerDisposable(
        (NickLoungeResponseBody.eventName),
        (raw) {
          var parsed = NickLoungeResponseBody.fromJson(
              _preProcessRawDataEncodeDecodeJson(raw));

          if (parsed.network == network.remoteId) {
            var currentState = currentStateExtractor();
            currentState.nick = parsed.nick;
            listener(currentState);
          }
        },
      ),
    );

    disposable.add(
      createEventListenerDisposable(
        (NetworkOptionsLoungeResponseBody.eventName),
        (raw) {
          var parsed = NetworkOptionsLoungeResponseBody.fromJson(
              _preProcessRawDataEncodeDecodeJson(raw));

          if (parsed.network == network.remoteId) {
            // nothing to change right now
            var currentState = currentStateExtractor();
            listener(currentState);
          }
        },
      ),
    );

    disposable.add(
      createEventListenerDisposable(
        (NetworkStatusLoungeResponseBody.eventName),
        (raw) {
          var parsed = NetworkStatusLoungeResponseBody.fromJson(
              _preProcessRawDataEncodeDecodeJson(raw));

          if (parsed.network == network.remoteId) {
            var currentState = currentStateExtractor();
            var newState =
                toNetworkState(parsed, currentState.nick, network.name);
            listener(newState);
          }
        },
      ),
    );

    return disposable;
  }

  @override
  Future<RequestResult<bool>> sendChannelOpenedEventToServer(
    Network network,
    Channel channel,
  ) async {
    await _sendRequest(
      ChannelOpenedLoungeRawRequest(
        channelRemoteId: channel.remoteId,
      ),
      isNeedAddRequestToPending: false,
    );
    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<bool>> sendDevicePushFCMTokenToServer(String newToken,
      {bool waitForResult = false}) async {
    _logger.fine(() => "sendDevicePushFCMTokenToServer $newToken");

    await _sendRequest(
      PushFCMTokenLoungeJsonRequest(
        token: newToken,
      ),
      isNeedAddRequestToPending: false,
    );

    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<List<SpecialMessage>>> printNetworkAvailableChannels(
      Network network,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
        network, network.lobbyChannel, ChannelsListIRCCommand().asRawString);
    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<RegularMessage>> printChannelBannedUsers(
      Network network, Channel channel,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(network, channel, BanListIRCCommand().asRawString);
    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<ChatMessage>> printNetworkIgnoredUsers(Network network,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
        network, network.lobbyChannel, IgnoreListIRCCommand().asRawString);
    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<RegularMessage>> sendChannelRawMessage(
      Network network, Channel channel, String rawMessage,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(network, channel, rawMessage);
    return RequestResult.notWaitForResponse();
  }

  @override
  IDisposable listenForChannelNames(
      Network network, Channel channel, Function(List<ChannelUser>) listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(createEventListenerDisposable(
        (NamesLoungeResponseBody.eventName), (raw) {
      var parsed = NamesLoungeResponseBody.fromJson(
          _preProcessRawDataEncodeDecodeJson(raw));

      _logger.fine(() => "listenForChannelUsers $parsed for $channel");

      if (parsed.id == channel.remoteId) {
        listener(parsed.users
            .map((loungeUser) => toChannelUser(loungeUser))
            .toList());
      }
    }));

    return disposable;
  }

  Future _sendRequest(
    LoungeRequest request, {
    @required bool isNeedAddRequestToPending,
  }) {
    if (isNeedAddRequestToPending) {
      _pendingRequests.add(request);
    }

    _logger.fine(() => "_sendCommand $request");
    var socketIOCommand = toSocketIOCommand(request);
    _logger.fine(() => "socketIOCommand $socketIOCommand");
    return _socketIOInstanceBloc.emit(socketIOCommand);
  }

  Future disconnect() async {
    var result;

    result = await _socketIOInstanceBloc.disconnect();
    return result;
  }

  @override
  Future dispose() async {
    await super.dispose();

    await _socketIOInstanceBloc.dispose();
  }

  void _sendInputRequest(Network network, Channel channel, String message) {
    if (_isCollapseClientSideCommand(message)) {
      _channelTogglePreviewSubject.add(
        ToggleChannelPreviewData(
          network,
          channel,
          false,
        ),
      );
    } else if (_isExpandClientSideCommand(message)) {
      _channelTogglePreviewSubject.add(
        ToggleChannelPreviewData(
          network,
          channel,
          true,
        ),
      );
    } else {
      _sendRequest(
        InputLoungeJsonRequest(
          target: channel.remoteId,
          text: message,
        ),
        isNeedAddRequestToPending: false,
      );
    }
  }

  bool _isExpandClientSideCommand(
    String message,
  ) =>
      message.startsWith(
        ClientSideLoungeIRCCommandConstants.expand,
      );

  bool _isCollapseClientSideCommand(
    String message,
  ) =>
      message.startsWith(
        ClientSideLoungeIRCCommandConstants.collapse,
      );

  @override
  Future<RequestResult<String>> uploadFile(File file) async {
    String uploadFileToken;

    var disposable = _createEventListenerDisposable(
        _socketIOInstanceBloc, UploadAuthLoungeResponseBody.eventName, (raw) {
      var parsed = UploadAuthLoungeResponseBody.fromRaw(raw);

      uploadFileToken = parsed.uploadAuthToken;
    });
    await _socketIOInstanceBloc
        .emit(toSocketIOCommand(UploadAuthLoungeEmptyRequest()));

    await _doWaitForResult(() => uploadFileToken);

    await disposable.dispose();

    String loungeUrl = loungePreferences.hostPreferences.host;
    var uploadedFileRemoteURL = await uploadFileToLounge(
        loungeUrl, file, uploadFileToken, chatConfig.fileUploadMaxSizeInBytes);

    return RequestResult.withResponse(uploadedFileRemoteURL);
  }

  IDisposable listenForLoadMore(Network network, Channel channel,
      Function(MessageListLoadMore) callback) {
    var disposable = CompositeDisposable([]);

    disposable.add(
      createEventListenerDisposable(
        (MoreLoungeResponseBody.eventName),
        (raw) {
          var parsed = MoreLoungeResponseBody.fromJson(
              _preProcessRawDataEncodeDecodeJson(raw));

          _logger.fine(() => "loadMoreHistory $parsed for $channel");

          if (parsed.chan == channel.remoteId) {
            toChatLoadMore(channel, parsed).then((chatLoadMore) {
              callback(chatLoadMore);
            });
          }
        },
      ),
    );

    return disposable;
  }

  @override
  Future<RequestResult<ChatInitInformation>> authAfterReconnect({
    @required String token,
    @required int activeChannelId,
    @required int lastMessageId,
    @required String user,
    bool waitForResult = false,
  }) async {
    _logger.fine(() => "authAfterReconnect "
        "token = $token "
        "activeChannelId = $activeChannelId "
        "lastMessageId = $lastMessageId "
        "waitForResult $waitForResult");

    var request = AuthReconnectLoungeJsonRequestBody(
      lastMessageId: lastMessageId,
      openChannelId: activeChannelId,
      user: user,
      token: token,
    );
    IDisposable disposable;
    var result;
    disposable = _listenForInit(_socketIOInstanceBloc, (chatInit) async {
      _logger.fine(() => "_listenForInit");
      result = chatInit;
    });
    disposable = _listenForAuthorized(_socketIOInstanceBloc, () async {
      _logger.fine(() => "_listenForAuthorized");
    });
    disposable = _listenForCommands(_socketIOInstanceBloc, (commands) async {
      _logger.fine(() => "_listenForAuthorized");
    });
    await _sendRequest(request, isNeedAddRequestToPending: false);

    RequestResult<ChatInitInformation> requestResult;
    if (waitForResult) {
      requestResult = await _doWaitForResult<ChatInitInformation>(() => result);
    } else {
      requestResult = RequestResult.notWaitForResponse();
    }
    await disposable.dispose();
    return requestResult;
  }

  IDisposable listenForSignOut(VoidCallback callback) {
    var disposable = CompositeDisposable([]);

    disposable.add(
      StreamSubscriptionDisposable(
        _signOutSubject.stream.listen(
          (manualSignOut) {
            if (manualSignOut == true) {
              callback();
            }
          },
        ),
      ),
    );
    disposable.add(
      createEventListenerDisposable(
        (SignOutLoungeResponseBody.eventName),
        (raw) {
          _logger.fine(() => "listenForSignOut $raw");
          callback();
        },
      ),
    );

    return disposable;
  }

  @override
  Future<RequestResult<MessageListLoadMore>> loadMoreHistory(
    Network network,
    Channel channel,
    int lastMessageId,
  ) async {
    var disposable = CompositeDisposable(
      [],
    );

    MessageListLoadMore chatLoadMore;

    disposable.add(
      listenForLoadMore(
        network,
        channel,
        (loadMoreResponse) {
          chatLoadMore = loadMoreResponse;
        },
      ),
    );

    await _sendRequest(
      MoreLoungeJsonRequest(
        target: channel.remoteId,
        lastId: lastMessageId,
      ),
      isNeedAddRequestToPending: false,
    );

    await _doWaitForResult(() => chatLoadMore);

    await disposable.dispose();

    return RequestResult.withResponse(chatLoadMore);
  }

  // ignore: close_sinks
  final BehaviorSubject<ToggleMessagePreviewData> _messageTogglePreviewSubject =
      BehaviorSubject();

  @override
  IDisposable listenForMessagePreviewToggle(Network network, Channel channel,
      Function(ToggleMessagePreviewData) callback) {
    return StreamSubscriptionDisposable(
      _messageTogglePreviewSubject.stream.listen(
        (ToggleMessagePreviewData toggle) {
          if (toggle.channel == channel) {
            callback(toggle);
          }
        },
      ),
    );
  }

  // ignore: close_sinks
  final BehaviorSubject<ToggleChannelPreviewData> _channelTogglePreviewSubject =
      BehaviorSubject();

  @override
  IDisposable listenForChannelPreviewToggle(
    Network network,
    Channel channel,
    Function(ToggleChannelPreviewData) callback,
  ) =>
      StreamSubscriptionDisposable(
        _channelTogglePreviewSubject.stream.listen(
          (ToggleChannelPreviewData toggle) {
            if (toggle.channel == channel) {
              callback(toggle);
            }
          },
        ),
      );

  @override
  Future<RequestResult<ToggleMessagePreviewData>> togglePreview(
    Network network,
    Channel channel,
    RegularMessage message,
    MessagePreview preview, {
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }

    var shownInverted = !preview.shown;
    preview.shown = shownInverted;
    await _sendRequest(
      MsgPreviewToggleLoungeJsonRequest.name(
          target: channel.remoteId,
          msgId: message.messageRemoteId,
          link: preview.link,
          shown: shownInverted),
      isNeedAddRequestToPending: false,
    );

    var chatTogglePreview = ToggleMessagePreviewData.name(
      network,
      channel,
      message,
      preview,
      shownInverted,
    );

    _messageTogglePreviewSubject.add(chatTogglePreview);
    return RequestResult.withResponse(chatTogglePreview);
  }

  void signOut() {
    _signOutSubject.add(true);

    _sendRequest(SignOutLoungeEmptyRequest(), isNeedAddRequestToPending: false);
  }
}

IDisposable _listenForConfiguration(SocketIOInstanceBloc _socketIoService,
    Function(ConfigurationLoungeResponseBody) listener) {
  var disposable = CompositeDisposable([]);
  disposable.add(
    _createEventListenerDisposable(
      _socketIoService,
      (ConfigurationLoungeResponseBody.eventName),
      (raw) {
        var parsed = ConfigurationLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(raw));

        listener(parsed);
      },
    ),
  );

  return disposable;
}

IDisposable _listenForAuth(
  SocketIOInstanceBloc _socketIoService,
  Function(LoungeHostInformation auth) listener,
) {
  var disposable = CompositeDisposable(
    [],
  );
  disposable.add(
    _createEventListenerDisposable(
      _socketIoService,
      (AuthLoungeResponseBody.eventName),
      (raw) {
        _logger.fine(() => "_listenForAuth = $raw}");
        var parsed = AuthLoungeResponseBody.fromJson(
          _preProcessRawDataEncodeDecodeJson(
            raw,
          ),
        );
        _logger.fine(() => "AuthLoungeResponseBody = $parsed}");

        var hostInformation = LoungeHostInformation.connectedToPrivate(
          authResponse: parsed.success,
          registrationSupported: parsed.signUp,
        );
        listener(
          hostInformation,
        );
      },
    ),
  );

  return disposable;
}

IDisposable _listenForRegistration(
  SocketIOInstanceBloc _socketIoService,
  Function(ChatRegistrationResult registrationResult) listener,
) {
  _logger.fine(
      () => "_listenForRegistration ${RegistrationResponseBody.eventName}");
  var disposable = CompositeDisposable([]);
  disposable.add(
    _createEventListenerDisposable(
      _socketIoService,
      RegistrationResponseBody.eventName,
      (raw) {
        _logger.fine(() => "_listenForRegistration raw = $raw}");
        var parsed = RegistrationResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(raw));
        _logger.fine(() => "RegistrationResponseBody = $parsed}");
        listener(
          toChatRegistrationResult(
            parsed,
          ),
        );
      },
    ),
  );

  return disposable;
}

IDisposable _listenForCommands(
  SocketIOInstanceBloc _socketIoService,
  Function(List<String>) listener,
) {
  var disposable = CompositeDisposable([]);
  disposable.add(
    _createEventListenerDisposable(
      _socketIoService,
      (CommandsLoungeResponseBody.eventName),
      (raw) {
        var parsed = CommandsLoungeResponseBody.fromRaw(raw);

        listener(parsed.commands);
      },
    ),
  );

  return disposable;
}

IDisposable _listenForAuthorized(
  SocketIOInstanceBloc _socketIoService,
  VoidCallback listener,
) {
  var disposable = CompositeDisposable([]);
  disposable.add(
    _createEventListenerDisposable(
      _socketIoService,
      (AuthorizedLoungeResponseBody.eventName),
      (raw) {
        _logger.fine(() => "_listenForAuthorized = $raw}");
        listener();
      },
    ),
  );

  return disposable;
}

IDisposable _listenForInit(SocketIOInstanceBloc _socketIoService,
    Function(ChatInitInformation init) listener) {
  var disposable = CompositeDisposable([]);
  disposable.add(
    _createEventListenerDisposable(
      _socketIoService,
      (InitLoungeResponseBody.eventName),
      (raw) {
        _logger.fine(() => "_listenForInit = $raw}");
        var parsed = InitLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(raw));

        toChatInitInformation(parsed).then((chatInit) {
          listener(chatInit);
        });
      },
    ),
  );

  return disposable;
}

IDisposable _createEventListenerDisposable(
  SocketIOInstanceBloc _socketIoService,
  String eventName,
  Function(dynamic raw) listener,
) {
  _socketIoService.on(eventName, listener);

  return CustomDisposable(
    () => _socketIoService.off(
      eventName,
      listener,
    ),
  );
}

// dynamic because it is json entity, so maybe List or Map
dynamic _preProcessRawDataEncodeDecodeJson(
  raw, {
  bool isJsonData = true,
}) {
  // Hack for strange bug on ios
  // Flutter app throw exception which is not possible to catch
  // if use raw data without re-encoding
  // TODO: remove when bug will be fixed in socketio/json libraries
  var newRaw = raw;
  if (isJsonData && Platform.isIOS) {
    if (raw is Map) {
      var jsonData = json.encode(raw);
      newRaw = json.decode(jsonData);
    }
  }

  _logger
      .finest(() => "_preProcessRawData json = $isJsonData converted $newRaw");
  return newRaw;
}

Future<RequestResult<ChatLoginResult>> tryLoginToLounge(
  SocketIOService socketIoService,
  LoungePreferences preferences,
) async {
  SocketIOInstanceBloc socketIOInstanceBloc;

  RequestResult<ChatLoginResult> requestResult;

  try {
    socketIOInstanceBloc = SocketIOInstanceBloc(
      socketIoService: socketIoService,
      uri: preferences.hostPreferences.host,
    );
    await socketIOInstanceBloc.init();
    requestResult = await _connectAndLogin(preferences, socketIOInstanceBloc);
  } catch (e, stackTrace) {
    _logger.shout(() => "error during tryLoginToLounge", e, stackTrace);
  } finally {
    try {
      if (socketIOInstanceBloc != null) {
        await socketIOInstanceBloc.dispose();
      }
    } catch (e, stackTrace) {
      _logger.warning(() => "socketIoService.dispose()", e, stackTrace);
    }
  }

  return requestResult;
}

Future<RequestResult<ChatRegistrationResult>> registerOnLounge(
  SocketIOService socketIoService,
  LoungePreferences preferences,
) async {
  SocketIOInstanceBloc socketIOInstanceBloc;

  RequestResult<ChatRegistrationResult> requestResult;

  try {
    socketIOInstanceBloc = SocketIOInstanceBloc(
      socketIoService: socketIoService,
      uri: preferences.hostPreferences.host,
    );
    _logger.fine(() => "registerOnLounge before init");
    await socketIOInstanceBloc.init();
    _logger.fine(() => "registerOnLounge before _register");
    requestResult = await _register(preferences, socketIOInstanceBloc);
  } catch (e) {
    _logger.fine(() => "error during tryLoginToLounge = $e");
  } finally {
    try {
      if (socketIOInstanceBloc != null) {
        await socketIOInstanceBloc.dispose();
      }
    } catch (e, stackTrace) {
      _logger.warning(() => "socketIoService.dispose()", e, stackTrace);
    }
  }

  return requestResult;
}

Future<RequestResult<LoungeHostInformation>> retrieveLoungeHostInformation(
  SocketIOService socketIoService,
  LoungeHostPreferences hostPreferences,
) async {
  SocketIOInstanceBloc socketIOInstanceBloc;

  LoungeHostInformation result;
  try {
    socketIOInstanceBloc = SocketIOInstanceBloc(
      socketIoService: socketIoService,
      uri: hostPreferences.host,
    );
    await socketIOInstanceBloc.init();
    result =
        await _retrieveHostInformation(socketIOInstanceBloc, hostPreferences);
  } catch (e, stackTrace) {
    _logger.shout(
      () => "error during tryConnectWithDifferentPreferences",
      e,
      stackTrace,
    );
  } finally {
    try {
      await socketIOInstanceBloc?.dispose();
    } catch (e, stackTrace) {
      _logger.warning(() => "socketIoService.dispose()", e, stackTrace);
    }
  }

  return RequestResult.withResponse(result);
}

Future<LoungeHostInformation> _retrieveHostInformation(
  SocketIOInstanceBloc socketIoService,
  LoungeHostPreferences hostPreferences,
) async {
  String host = hostPreferences.host;
  _logger.fine(
    () => "_retrieveHostInformation "
        "host $host "
        "URI = ${socketIoService.uri}",
  );

  LoungeHostInformation result;

  var disposable = CompositeDisposable(
    [],
  );

  disposable.add(
    _listenForAuth(
      socketIoService,
      (auth) {
        result = auth;
      },
    ),
  );

  disposable.add(
    _listenForAuthorized(
      socketIoService,
      () => result = LoungeHostInformation.connectedToPublic(),
    ),
  );

  Future.delayed(
    _connectTimeout,
    () {
      result ??= LoungeHostInformation.notConnected();
    },
  );

  var connectErrorListener = (data) {
    _logger.fine(() => "_retrieveHostInformation connectErrorListener = $data");
    result = LoungeHostInformation.notConnected();
  };

  socketIoService.onConnectError(connectErrorListener);
  disposable.add(
    CustomDisposable(
      () {
        socketIoService.offConnectError(connectErrorListener);
      },
    ),
  );

  await socketIoService.connect();

  _logger.fine(() => "_retrieveHostInformation socketConnected");

  do {
    await Future.delayed(_timeBetweenCheckingConnectionResponse);
  } while (result == null);

  _logger.fine(() => "_retrieveHostInformation result = $result");

  return result;
}

Future<RequestResult<ChatRegistrationResult>> _register(
  LoungePreferences preferences,
  SocketIOInstanceBloc socketIoService,
) async {
  var authPreferences = preferences.authPreferences;
  var registrationCommand = toSocketIOCommand(
    RegistrationLoungeJsonRequest(
      user: authPreferences.username,
      password: authPreferences.password,
    ),
  );
  _logger.fine(() => "_register $registrationCommand");

  var disposable = CompositeDisposable([]);

  _logger.fine(() => "register eventName ${registrationCommand.eventName}");

  ChatRegistrationResult registrationResult;

  await socketIoService.connect();

  disposable.add(
    _listenForRegistration(
      socketIoService,
      (result) {
        registrationResult = result;
      },
    ),
  );

  await socketIoService.emit(registrationCommand);

  var requestResult = await _doWaitForResult(() => registrationResult);

  await disposable.dispose();

  _logger.fine(() => "_register $requestResult");

  return requestResult;
}

Future<RequestResult<ChatLoginResult>> _connectAndLogin(
  LoungePreferences preferences,
  SocketIOInstanceBloc socketIoService,
) async {
  _logger.fine(() => "start connect to $preferences "
      "URI = ${socketIoService.uri}");

  ChatLoginResult result = ChatLoginResult();
  result.isAuthUsed = false;
  result.success = false;

  var disposable = CompositeDisposable([]);

  ConfigurationLoungeResponseBody loungeConfig;
  List<String> loungeCommands;
  bool authorizedReceived = false;
  LoungeHostInformation authResponse;

  disposable.add(
    _listenForConfiguration(
      socketIoService,
      (result) => loungeConfig = result,
    ),
  );
  disposable.add(
    _listenForAuthorized(
      socketIoService,
      () {
        authorizedReceived = true;
        result.success = true;
      },
    ),
  );
  disposable.add(
    _listenForAuth(
      socketIoService,
      (auth) {
        authResponse = auth;
        result.isAuthUsed = true;
      },
    ),
  );
  disposable.add(
    _listenForInit(
      socketIoService,
      (initResponse) => result.chatInit = initResponse,
    ),
  );
  disposable.add(
    _listenForCommands(
      socketIoService,
      (result) => loungeCommands = result,
    ),
  );

  bool isFailAuthResponseReceived = false;
  bool isTimeout = false;
  bool isSocketConnected = false;
  bool isPrivateModeResponseReceived = false;
  bool isAuthRequestSent = false;
  dynamic error;

  Future.delayed(_connectTimeout, () {
    if (result.config != null || isFailAuthResponseReceived) {
      isTimeout = true;
    }
  });

  var connectErrorListener = (data) {
    _logger.fine(() => "_connect connectErrorListener = $data");
    isSocketConnected = false;
    error = data;
  };

  socketIoService.onConnectError(connectErrorListener);
  disposable.add(
    CustomDisposable(
      () {
        socketIoService.offConnectError(connectErrorListener);
      },
    ),
  );

  isSocketConnected = true;

  await socketIoService.connect();

  _logger.fine(() => "_connect socketConnected = $isSocketConnected");
  var authPreferences = preferences.authPreferences;

  bool authPreferencesExist =
      authPreferences != null && authPreferences != LoungeAuthPreferences.empty;
  bool authorizedResponseReceived = false;

  if (isSocketConnected) {
    bool isNeedWait;
    do {
      await Future.delayed(_timeBetweenCheckingConnectionResponse);

      authorizedResponseReceived = (loungeCommands != null &&
          loungeConfig != null &&
          result.chatInit != null &&
          authorizedReceived != false);
      isPrivateModeResponseReceived = authResponse != null || isAuthRequestSent;

      if (isPrivateModeResponseReceived &&
          !isAuthRequestSent &&
          authPreferencesExist) {
        var authRequest = AuthLoginLoungeJsonRequestBody.name(
          user: authPreferences.username,
          password: authPreferences.password,
        );

        authResponse = null;
        await socketIoService.emit(
          toSocketIOCommand(
            authRequest,
          ),
        );
        isAuthRequestSent = true;
        _logger.fine(() => "_connect send auth = $authRequest");
      }

      isFailAuthResponseReceived =
          authResponse != null ? authResponse.authResponse == false : false;

      isNeedWait = !isTimeout;
      isNeedWait &= !isFailAuthResponseReceived;
      isNeedWait &= error == null;
      isNeedWait &= !authorizedResponseReceived;
      // private mode but login/password not specified
      isNeedWait &= !isPrivateModeResponseReceived ||
          (isPrivateModeResponseReceived && isAuthRequestSent);
    } while (isNeedWait);
  }

  _logger.fine(() => "_connect end wait "
      "authorizedResponseReceived = $authorizedResponseReceived "
      ".isTimeout = $isTimeout "
      ".isPrivateModeResponseReceived = $isPrivateModeResponseReceived "
      ".isAuthRequestSent = $isAuthRequestSent "
      ".error = $error");

  await disposable.dispose();

  var configReceived = loungeConfig != null;
  var commandsReceived = loungeCommands != null;
  var chatInitReceived = result.chatInit != null;

  _logger
      .fine(() => "_connect result = $result configReceived = $configReceived"
          " commandsReceived = $commandsReceived "
          "authorizedReceived = $authorizedReceived");

  if (isTimeout) {
    return RequestResult.timeout();
  }

  if (error != null) {
    return RequestResult.error(error);
  }

  if (authorizedResponseReceived) {
    result.config = toChatConfig(
      loungeConfig,
      loungeCommands,
    );
    return RequestResult.withResponse(result);
  } else {
    if (authorizedReceived ||
        configReceived ||
        commandsReceived ||
        chatInitReceived) {
      return RequestResult.error(InvalidResponseException(
          preferences,
          authorizedReceived,
          configReceived,
          commandsReceived,
          chatInitReceived));
    } else {
      return RequestResult.withResponse(result);
    }
  }
}

ChatJoinChannelInputLoungeJsonRequest _findJoinChannelOriginalRequest(
  List<LoungeRequest> pendingRequests,
  JoinLoungeResponseBody parsed,
) =>
    pendingRequests.firstWhere(
      (request) {
        if (request is ChatJoinChannelInputLoungeJsonRequest) {
          ChatJoinChannelInputLoungeJsonRequest joinRequest = request;
          if (joinRequest != null) {
            if (joinRequest.preferences.name == parsed.chan.name) {
              return true;
            }
          } else {
            return false;
          }

          return false;
        } else {
          return false;
        }
      },
      orElse: () => null,
    );

ChatNetworkNewLoungeJsonRequest _findOriginalJoinNetworkRequest(
  List<LoungeRequest> pendingRequests,
  NetworkLoungeResponseBodyPart loungeNetwork,
) =>
    pendingRequests.firstWhere(
      (request) {
        var loungeJsonRequest = request as ChatNetworkNewLoungeJsonRequest;
        if (loungeJsonRequest != null) {
          if (loungeNetwork.name == loungeJsonRequest.name) {
            return true;
          } else {
            return false;
          }
        } else {
          return false;
        }
      },
      orElse: () => null,
    );

Future<RequestResult<T>> _doWaitForResult<T>(
  T Function() resultExtractor,
) async {
  RequestResult<T> result;

  Future.delayed(
    _timeoutForRequestsWithResponse,
    () {
      if (result == null) {
        _logger.fine(() => "_doWaitForResult timeout");
        result = RequestResult.timeout();
      }
    },
  );

  while (result == null) {
    await Future.delayed(_timeBetweenCheckResultForRequestsWithResponse);
    T extracted = resultExtractor();
    if (extracted != null) {
      _logger.fine(() => "_doWaitForResult extracted = $extracted");
      result = RequestResult.withResponse(
        extracted,
      );
    }
  }

  return result;
}
