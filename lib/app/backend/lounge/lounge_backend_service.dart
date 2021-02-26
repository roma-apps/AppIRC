import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/api/lounge_backend_socket_io_api_wrapper_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connect/lounge_backend_connect_bloc.dart';
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
import 'package:flutter_appirc/socket_io/instance/socket_io_instance_bloc.dart';
import 'package:flutter_appirc/socket_io/socket_io_service.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/subjects.dart';

var _logger = Logger("lounge_backend_service.dart");

const _timeoutForRequestsWithResponse = Duration(
  seconds: 10,
);
const _timeBetweenCheckResultForRequestsWithResponse = Duration(
  milliseconds: 100,
);

class LoungeBackendService extends DisposableOwner
    implements ChatBackendService {
  final LoungePreferences loungePreferences;
  final SocketIOService socketIoService;
  SocketIOInstanceBloc socketIOInstanceBloc;

  @override
  Stream<bool> get isChatConfigExistStream => chatConfigStream.map(
        (chatConfig) => chatConfig != null,
      );

  @override
  bool get isConnected => connectionState == ChatConnectionState.connected;

  @override
  Stream<bool> get isConnectedStream => connectionStateStream
      .map(
        (state) => state == ChatConnectionState.connected,
      )
      .distinct();

  @override
  Stream<ChatConnectionState> get connectionStateStream =>
      connectionStateSubject.stream.distinct();

  final BehaviorSubject<ChatConnectionState> connectionStateSubject =
      BehaviorSubject();

  @override
  ChatConnectionState get connectionState =>
      mapConnectionState(socketIOInstanceBloc.simpleConnectionState);


  @override
  Stream<ChatConfig> get chatConfigStream => loungeBackendConnectBloc.configStream;

  @override
  ChatConfig get chatConfig => loungeBackendConnectBloc.config;

  @override
  ChatInitInformation get chatInit => loungeBackendConnectBloc?.chatInit;

  // ignore: close_sinks
  final BehaviorSubject<bool> signOutSubject = BehaviorSubject();

  // lounge don't response properly to edit request
  // ignore: close_sinks
  final BehaviorSubject<NetworkPreferences> editNetworkRequests =
      BehaviorSubject();

  bool get isSocketIOServiceExist => socketIOInstanceBloc != null;

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
    addDisposable(subject: signOutSubject);
    addDisposable(subject: connectionStateSubject);
    addDisposable(subject: editNetworkRequests);
    addDisposable(subject: messageTogglePreviewSubject);
  }

  Future<int> Function() lastMessageRemoteIdExtractor;

  LoungeBackendSocketIoApiWrapperBloc socketIoApiWrapperBloc;
  LoungeBackendConnectBloc loungeBackendConnectBloc;

  Future init({
    @required Channel Function() currentChannelExtractor,
    @required Future<int> Function() lastMessageRemoteIdExtractor,
  }) async {
    _logger.fine(() => "init started");

    this.lastMessageRemoteIdExtractor = lastMessageRemoteIdExtractor;

    var host = loungePreferences.hostPreferences.host;
    socketIOInstanceBloc = SocketIOInstanceBloc(
      socketIoService: socketIoService,
      uri: host,
    );

    addDisposable(disposable: socketIOInstanceBloc);

    await socketIOInstanceBloc.performAsyncInit();

    socketIOInstanceBloc.simpleConnectionStateStream
        .listen((simpleConnectionState) {
      connectionStateSubject.add(
        mapConnectionState(
          simpleConnectionState,
        ),
      );
    });

    socketIoApiWrapperBloc = LoungeBackendSocketIoApiWrapperBloc(
      socketIOInstanceBloc: socketIOInstanceBloc,
    );

    socketIoApiWrapperBloc.listenForInit((init) {
      _logger.fine(() => "debug init $init");

      // TODO: I don't know why. But init not called after reconnection without
      //  this debug subscription
      // maybe bug in socket io lib
    });

    loungeBackendConnectBloc = LoungeBackendConnectBloc(
      loungeBackendSocketIoApiWrapperBloc: socketIoApiWrapperBloc,
      loungeAuthPreferences: loungePreferences.authPreferences,
    );
    addDisposable(disposable: loungeBackendConnectBloc);
    addDisposable(
      streamSubscription:
          socketIOInstanceBloc.simpleConnectionStateStream.listen(
        (socketState) {
          ChatConnectionState newBackendState = mapConnectionState(socketState);

          // reconnecting
          if (newBackendState == ChatConnectionState.connected &&
              chatInit != null) {
            // send connect after reconnecting. required by lounge
            socketIOInstanceBloc.connect();
          }

          _logger.fine(() => "newState socketState $socketState "
              " newBackendState $newBackendState");
          connectionStateSubject.add(newBackendState);
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

    RequestResult<ChatLoginResult> requestResult;
    try {
      var loungeConnectAndAuthDetails =
          await loungeBackendConnectBloc.connectAndLoginAndWaitForResult();

      if (loungeConnectAndAuthDetails.connectDetails.isSocketTimeout) {
        requestResult = RequestResult.timeout();
      } else if (loungeConnectAndAuthDetails.connectDetails.isSocketError) {
        requestResult = RequestResult.error(null);
      } else if (loungeConnectAndAuthDetails
          .connectDetails.isLoungeNotSentRequiredDataAndTimeoutReached) {
        requestResult = RequestResult.timeout();
      } else {
        var success =
            loungeConnectAndAuthDetails.connectDetails.publicPart != null ||
                (loungeConnectAndAuthDetails.authPerformComplexLoungeResponse !=
                        null &&
                    loungeConnectAndAuthDetails
                        .authPerformComplexLoungeResponse.isSuccess);
        ChatLoginResult loginResult = ChatLoginResult(
          success: success,
          isAuthUsed:
              loungeConnectAndAuthDetails.authPerformComplexLoungeResponse !=
                  null,
          config: loungeBackendConnectBloc.config,
          chatInit: loungeBackendConnectBloc.chatInit,
        );
        requestResult = RequestResult.withResponse(
          loginResult,
        );
      }
    } catch (e, stackTrace) {
      _logger.fine(() => "connectChat exception", e, stackTrace);
      requestResult = RequestResult.error(
        e,
      );
    }

    _logger.fine(() => "connectChat loginResult = $requestResult");

    return requestResult;
  }

  IDisposable createEventListenerDisposable({
    @required String eventName,
    @required Function(dynamic raw) listener,
  }) =>
      _createEventListenerDisposable(
        socketIOInstanceBloc: socketIOInstanceBloc,
        eventName: eventName,
        listener: listener,
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
  Future<RequestResult<bool>> editChannelTopic({
    @required Network network,
    @required Channel channel,
    @required String newTopic,
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw const NotImplementedYetLoungeException();
    }
    _sendInputRequest(
      network: network,
      channel: channel,
      message: TopicIRCCommand(
        newTopic: newTopic,
      ).asRawString,
    );
    return const RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<Network>> editNetworkSettings({
    @required Network network,
    @required NetworkPreferences networkPreferences,
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
      remoteId: network.remoteId,
      userPreferences: userPreferences,
      serverPreferences: serverPreferences,
    );

    // important to put request before send it
    editNetworkRequests.add(networkPreferences);

    await _sendRequest(
      request: request,
      isNeedAddRequestToPending: false,
    );

    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<bool>> enableNetwork({
    @required Network network,
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
      network: network,
      channel: network.lobbyChannel,
      message: ConnectIRCCommand().asRawString,
    );
    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<bool>> disableNetwork({
    @required Network network,
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
      network: network,
      channel: network.lobbyChannel,
      message: DisconnectIRCCommand().asRawString,
    );
    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<List<ChannelUser>>> requestChannelUsers({
    @required Network network,
    @required Channel channel,
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }

    var request = NamesLoungeJsonRequest(
      targetChannelRemoteId: channel.remoteId,
    );
    await _sendRequest(
      request: request,
      isNeedAddRequestToPending: false,
    );

    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<ChannelUser>> requestUserInfo({
    @required Network network,
    @required Channel channel,
    @required String userNick,
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
      network: network,
      channel: channel,
      message: WhoIsIRCCommand(
        userNick: userNick,
      ).asRawString,
    );
    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<NetworkWithState>> joinNetwork({
    @required NetworkPreferences networkPreferences,
    bool waitForResult = false,
  }) async {
    var serverPreferences =
        networkPreferences.networkConnectionPreferences.serverPreferences;

    var channelsWithoutPassword = networkPreferences.channelsWithoutPassword;
    var channelNames = channelsWithoutPassword.map(
      (channel) => channel.name,
    );
    String join = channelNames.join(LoungeConstants.channelsNamesSeparator);
    var request = ChatNetworkNewLoungeJsonRequest(
      networkPreferences: networkPreferences,
      join: join,
    );

    var result;
    IDisposable networkListener;
    networkListener = listenForNetworkJoin(listener: (networkWithState) async {
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
          await Future.delayed(
            Duration(
              seconds: 5,
            ),
          );

          for (var channelPreferences in channelsWithPassword) {
            var joinChannelResult = await joinChannel(
              network: networkWithState.network,
              channelPreferences: channelPreferences,
              waitForResult: true,
            );
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
    await _sendRequest(
      request: request,
      isNeedAddRequestToPending: true,
    );

    if (waitForResult) {
      return await _doWaitForResult<NetworkWithState>(() => result);
    } else {
      return RequestResult.notWaitForResponse();
    }
  }

  @override
  Future<RequestResult<ChannelWithState>> joinChannel({
    @required Network network,
    @required ChannelPreferences channelPreferences,
    bool waitForResult = false,
  }) async {
    _logger.fine(
        () => "joinChannel $channelPreferences waitForResult $waitForResult");

    var request = ChatJoinChannelInputLoungeJsonRequest(
      preferences: channelPreferences,
      targetChannelRemoteId: network.lobbyChannel.remoteId,
    );

    var result;
    IDisposable channelListener;
    channelListener = listenForChannelJoin(
      network: network,
      listener: (channelWithState) async {
        var isForRequest =
            channelWithState.channel.name == channelPreferences.name;
        _logger.fine(() => "joinChannel listenForChannelJoin $channelWithState "
            "isForRequest= $isForRequest");
        if (isForRequest) {
          result = channelWithState;
          await channelListener.dispose();
        }
      },
    );
    await _sendRequest(
      request: request,
      isNeedAddRequestToPending: true,
    );

    if (waitForResult) {
      return await _doWaitForResult<ChannelWithState>(() => result);
    } else {
      return RequestResult.notWaitForResponse();
    }
  }

  @override
  Future<RequestResult<ChannelWithState>> openDirectMessagesChannel({
    @required Network network,
    @required Channel channel,
    @required String nick,
    bool waitForResult = false,
  }) async {
    var request = InputLoungeJsonRequest(
      targetChannelRemoteId: channel.remoteId,
      // private channel name is equal to nickname
      text: JoinIRCCommand(
        channelName: nick,
      ).asRawString,
    );

    var result;
    IDisposable channelListener;
    channelListener = listenForChannelJoin(
        network: network,
        listener: (channelWithState) async {
          result = channelWithState;
          await channelListener.dispose();
        });
    await _sendRequest(
      request: request,
      isNeedAddRequestToPending: true,
    );

    if (waitForResult) {
      return await _doWaitForResult<ChannelWithState>(() => result);
    } else {
      return RequestResult.notWaitForResponse();
    }
  }

  @override
  Future<RequestResult<bool>> leaveNetwork({
    @required Network network,
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
      network: network,
      channel: network.lobbyChannel,
      message: QuitIRCCommand().asRawString,
    );
    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<bool>> leaveChannel({
    @required Network network,
    @required Channel channel,
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
      network: network,
      channel: channel,
      message: CloseIRCCommand().asRawString,
    );
    return RequestResult.notWaitForResponse();
  }

  @override
  IDisposable listenForMessages({
    @required Network network,
    @required Channel channel,
    @required ChannelMessageListener listener,
  }) {
    var disposable = CompositeDisposable([]);

    disposable.add(
      socketIoApiWrapperBloc.listenForInit(
        (InitLoungeResponseBody initLoungeResponseBody) {
          // new messages after reconnect

          var initResponse = toChatInitInformation(initLoungeResponseBody);

          var channelsWithState = initResponse.channelsWithState;

          var channelWithState = channelsWithState.firstWhere(
            (channelsWithState) =>
                channelsWithState.channel.remoteId == channel.remoteId,
            orElse: () => null,
          );

          if (channelWithState != null) {
            listener(
              MessagesForChannel(
                channel: channel,
                messages: channelWithState.initMessages,
                isNeedCheckAdditionalLoadMore: true,
                isNeedCheckAlreadyExistInLocalStorage: true,
              ),
            );
          }
        },
      ),
    );

    disposable.add(
      createEventListenerDisposable(
        eventName: MsgLoungeResponseBody.eventName,
        listener: (raw) {
          var data = MsgLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw: raw,
            ),
          );

          if (channel.remoteId == data.chan) {
            var message = toChatMessage(channel, data.msg);
            _logger.fine(() => "onNewMessage for {$data.chan}  $data");
            var type = detectRegularMessageType(data.msg.type);
            if (type == RegularMessageType.whoIs) {
              // lounge send whois message as regular
              // but actually lounge client display it as special
              var message = _toWhoIsSpecialMessage(data);
              listener(
                MessagesForChannel(
                  isNeedCheckAlreadyExistInLocalStorage: true,
                  isNeedCheckAdditionalLoadMore: false,
                  channel: channel,
                  messages: <ChatMessage>[
                    message,
                  ],
                ),
              );
            } else {
              listener(
                MessagesForChannel(
                  isNeedCheckAlreadyExistInLocalStorage: false,
                  isNeedCheckAdditionalLoadMore: false,
                  channel: channel,
                  messages: <ChatMessage>[
                    message,
                  ],
                ),
              );
            }

          }
        },
      ),
    );

    disposable.add(
      createEventListenerDisposable(
        eventName: MsgSpecialLoungeResponseBody.eventName,
        listener: (raw) {
          MsgSpecialLoungeResponseBody messageSpecialLoungeResponseBody =
              MsgSpecialLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw: raw,
            ),
          );

          if (channel.remoteId == messageSpecialLoungeResponseBody.chan) {
            toSpecialMessages(
              channel: channel,
              messageSpecialLoungeResponseBody:
                  messageSpecialLoungeResponseBody,
            ).then(
              (specialMessages) {
                var isFirstMessageIsText = specialMessages.length == 1 &&
                    specialMessages.first.specialType ==
                        SpecialMessageType.text;
                if (isFirstMessageIsText) {
                  return;
                }
                listener(
                  MessagesForChannel(
                    isNeedCheckAlreadyExistInLocalStorage: false,
                    isNeedCheckAdditionalLoadMore: false,
                    channel: channel,
                    messages: specialMessages,
                    isContainsTextSpecialMessage: true,
                  ),
                );
              },
            );
          }
        },
      ),
    );

    disposable.add(
      listenForLoadMore(
        network: network,
        channel: channel,
        listener: (loadMoreResponse) {
          listener(
            MessagesForChannel(
              isNeedCheckAlreadyExistInLocalStorage: false,
              isNeedCheckAdditionalLoadMore: true,
              channel: channel,
              messages: loadMoreResponse.messages,
            ),
          );
        },
      ),
    );

    return disposable;
  }

  SpecialMessage _toWhoIsSpecialMessage(
    MsgLoungeResponseBody data,
  ) {
    var whoIsSpecialBody = toWhoIsSpecialMessageBody(
      data.msg.whois,
    );

    return SpecialMessage(
      channelRemoteId: data.chan,
      data: whoIsSpecialBody,
      specialType: SpecialMessageType.whoIs,
      date: DateTime.now(),
      linksInMessage: null,
      messageLocalId: null,
      channelLocalId: null,
    );
  }

  @override
  IDisposable listenForChannelJoin({
    @required Network network,
    @required ChannelListener listener,
  }) {
    _logger.fine(() => "listenForChannelJoin $network");

    var disposable = CompositeDisposable([]);
    disposable.add(
      createEventListenerDisposable(
        eventName: JoinLoungeResponseBody.eventName,
        listener: (raw) {
          var joinLoungeResponseBody = JoinLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw: raw,
            ),
          );

          _logger.fine(() => "listenForChannelJoin "
              "parsed $joinLoungeResponseBody network.remoteId = $network.remoteId");
          if (joinLoungeResponseBody.network == network.remoteId) {
            ChatJoinChannelInputLoungeJsonRequest request =
                _findJoinChannelOriginalRequest(
              pendingRequests: _pendingRequests,
              joinLoungeResponseBody: joinLoungeResponseBody,
            );

            var preferences;

            if (request != null) {
              preferences = ChannelPreferences(
                localId: request.preferences.localId,
                name: joinLoungeResponseBody.chan.name,
                password: request.preferences.password,
              );
              _pendingRequests.remove(request);
            } else {
              preferences = ChannelPreferences(
                name: joinLoungeResponseBody.chan.name,
                password: "",
              );
            }

            var loungeChannel = joinLoungeResponseBody.chan;

            var channelWithState = toChannelWithState(loungeChannel);

            channelWithState.channel.channelPreferences = preferences;

            listener(channelWithState);
          }
        },
      ),
    );

    return disposable;
  }

  @override
  IDisposable listenForChannelLeave({
    @required Network network,
    @required Channel channel,
    @required VoidCallback listener,
  }) {
    var disposable = CompositeDisposable([]);
    disposable.add(
      createEventListenerDisposable(
        eventName: PartLoungeResponseBody.eventName,
        listener: (raw) {
          var parsed = PartLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw: raw,
            ),
          );

          if (parsed.chan == channel.remoteId) {
            listener();
          }
        },
      ),
    );

    return disposable;
  }

  @override
  IDisposable listenForChannelState({
    @required Network network,
    @required Channel channel,
    @required ChannelState Function() currentStateExtractor,
    @required Future<int> Function() currentMessageCountExtractor,
    @required ChannelStateListener listener,
  }) {
    var disposable = CompositeDisposable([]);
    disposable.add(
      createEventListenerDisposable(
        eventName: MsgLoungeResponseBody.eventName,
        listener: (raw) {
          var data = MsgLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw: raw,
            ),
          );

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
        eventName: MoreLoungeResponseBody.eventName,
        listener: (raw) async {
          var parsed = MoreLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw: raw,
            ),
          );

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
        eventName: TopicLoungeResponseBody.eventName,
        listener: (raw) {
          var data = TopicLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw: raw,
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
        eventName: ChannelStateLoungeResponseBody.eventName,
        listener: (raw) {
          var data = ChannelStateLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw: raw,
            ),
          );

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
  IDisposable listenForChannelUsers({
    @required Network network,
    @required Channel channel,
    @required VoidCallback listener,
  }) {
    var disposable = CompositeDisposable([]);
    disposable.add(
      createEventListenerDisposable(
        eventName: UsersLoungeResponseBody.eventName,
        listener: (raw) {
          var parsed = UsersLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw: raw,
            ),
          );

          if (parsed.chan == channel.remoteId) {
            listener();
          }
        },
      ),
    );

    return disposable;
  }

  @override
  IDisposable listenForNetworkJoin({
    @required NetworkListener listener,
  }) {
    var disposable = CompositeDisposable(
      [],
    );

    disposable.add(
      createEventListenerDisposable(
        eventName: NetworkLoungeResponseBody.eventName,
        listener: (raw) {
          var parsed = NetworkLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw: raw,
            ),
          );

          _logger.fine(() => "listenForNetworkJoin parsed = $parsed");

          for (var loungeNetwork in parsed.networks) {
            // Why lounge sent array of networks?
            // It is possible to join only one network Lounge API per request
            // Lounge should send only one network in this response
            // todo: open ticket for lounge
            ChatNetworkNewLoungeJsonRequest request =
                _findOriginalJoinNetworkRequest(
              pendingRequests: _pendingRequests,
              loungeNetwork: loungeNetwork,
            );

            _pendingRequests.remove(request);

            var connectionPreferences =
                request.networkPreferences.networkConnectionPreferences;

            // when requested nick is not available and server give new nick
            var nick = loungeNetwork.nick;
            connectionPreferences.userPreferences.nickname = nick;

            NetworkWithState networkWithState = toNetworkWithState(loungeNetwork);

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

            networkWithState = networkWithState.copyWith(
              network: networkWithState.network.copyWith(
                connectionPreferences: connectionPreferences,
              ),
            );

            listener(networkWithState);
          }
        },
      ),
    );

    return disposable;
  }

  @override
  IDisposable listenForNetworkLeave({
    @required Network network,
    @required VoidCallback listener,
  }) {
    var disposable = CompositeDisposable([]);
    disposable.add(
      createEventListenerDisposable(
        eventName: QuitLoungeResponseBody.eventName,
        listener: (raw) {
          var parsed = QuitLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw: raw,
            ),
          );

          if (parsed.network == network.remoteId) {
            listener();
          }
        },
      ),
    );

    return disposable;
  }

  @override
  IDisposable listenForMessagePreviews({
    @required Network network,
    @required Channel channel,
    @required ChannelMessagePreviewListener listener,
  }) {
    var disposable = CompositeDisposable([]);
    disposable.add(
      createEventListenerDisposable(
        eventName: MsgPreviewLoungeResponseBody.eventName,
        listener: (raw) {
          var parsed = MsgPreviewLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw: raw,
            ),
          );

          if (parsed.chan == channel.remoteId) {
            listener(
              MessagePreviewForRemoteMessageId(
                remoteMessageId: parsed.id,
                messagePreview: toMessagePreview(
                  parsed.preview,
                ),
              ),
            );
          }
        },
      ),
    );

    return disposable;
  }

  @override
  IDisposable listenForNetworkEdit({
    @required Network network,
    @required NetworkConnectionListener listener,
  }) {
    return StreamSubscriptionDisposable(
      editNetworkRequests.listen(
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
  IDisposable listenForNetworkState({
    @required Network network,
    @required NetworkState Function() currentStateExtractor,
    @required NetworkStateListener listener,
  }) {
    var disposable = CompositeDisposable([]);

    disposable.add(
      StreamSubscriptionDisposable(
        editNetworkRequests.listen(
          (NetworkPreferences networkPreferences) {
            if (network.connectionPreferences.localId ==
                networkPreferences.localId) {
              var currentState = currentStateExtractor();
              currentState = currentState.copyWith(
                name: networkPreferences
                    .networkConnectionPreferences.serverPreferences.name,
              );
              listener(currentState);
            }
          },
        ),
      ),
    );

    disposable.add(
      createEventListenerDisposable(
        eventName: NickLoungeResponseBody.eventName,
        listener: (raw) {
          var nickLoungeResponseBody = NickLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw: raw,
            ),
          );

          if (nickLoungeResponseBody.network == network.remoteId) {
            var currentState = currentStateExtractor();
            currentState = currentState.copyWith(
              nick: nickLoungeResponseBody.nick,
            );
            listener(currentState);
          }
        },
      ),
    );

    disposable.add(
      createEventListenerDisposable(
        eventName: NetworkOptionsLoungeResponseBody.eventName,
        listener: (raw) {
          var parsed = NetworkOptionsLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw: raw,
            ),
          );

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
        eventName: NetworkStatusLoungeResponseBody.eventName,
        listener: (raw) {
          var loungeNetworkStatus = NetworkStatusLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw: raw,
            ),
          );

          if (loungeNetworkStatus.network == network.remoteId) {
            var currentState = currentStateExtractor();
            var newState = toNetworkState(
              loungeNetworkStatus: loungeNetworkStatus,
              nick: currentState.nick,
              name: network.name,
            );
            listener(newState);
          }
        },
      ),
    );

    return disposable;
  }

  @override
  Future<RequestResult<bool>> sendChannelOpenedEventToServer({
    @required Network network,
    @required Channel channel,
  }) async {
    await _sendRequest(
      request: ChannelOpenedLoungeRawRequest(
        channelRemoteId: channel.remoteId,
      ),
      isNeedAddRequestToPending: false,
    );
    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<bool>> sendDevicePushFCMTokenToServer({
    @required String newToken,
    bool waitForResult = false,
  }) async {
    _logger.fine(() => "sendDevicePushFCMTokenToServer $newToken");

    await _sendRequest(
      request: PushFCMTokenLoungeJsonRequest(
        fcmToken: newToken,
      ),
      isNeedAddRequestToPending: false,
    );

    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<List<SpecialMessage>>> printNetworkAvailableChannels({
    @required Network network,
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
      network: network,
      channel: network.lobbyChannel,
      message: ChannelsListIRCCommand().asRawString,
    );
    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<RegularMessage>> printChannelBannedUsers({
    @required Network network,
    @required Channel channel,
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
      network: network,
      channel: channel,
      message: BanListIRCCommand().asRawString,
    );
    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<ChatMessage>> printNetworkIgnoredUsers({
    @required Network network,
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
      network: network,
      channel: network.lobbyChannel,
      message: IgnoreListIRCCommand().asRawString,
    );
    return RequestResult.notWaitForResponse();
  }

  @override
  Future<RequestResult<RegularMessage>> sendChannelRawMessage({
    @required Network network,
    @required Channel channel,
    @required String rawMessage,
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
      network: network,
      channel: channel,
      message: rawMessage,
    );
    return RequestResult.notWaitForResponse();
  }

  @override
  IDisposable listenForChannelNames({
    @required Network network,
    @required Channel channel,
    @required Function(List<ChannelUser>) listener,
  }) {
    var disposable = CompositeDisposable([]);
    disposable.add(
      createEventListenerDisposable(
        eventName: NamesLoungeResponseBody.eventName,
        listener: (raw) {
          var parsed = NamesLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw: raw,
            ),
          );

          _logger.fine(() => "listenForChannelUsers $parsed for $channel");

          if (parsed.id == channel.remoteId) {
            listener(
              parsed.users
                  .map(
                    (loungeUser) => toChannelUser(loungeUser),
                  )
                  .toList(),
            );
          }
        },
      ),
    );

    return disposable;
  }

  Future _sendRequest({
    @required LoungeRequest request,
    @required bool isNeedAddRequestToPending,
  }) {
    if (isNeedAddRequestToPending) {
      _pendingRequests.add(request);
    }
    _logger.fine(() => "_sendCommand $request");
    var socketIOCommand = request.toSocketIOCommand();
    _logger.fine(() => "socketIOCommand $socketIOCommand");
    return socketIOInstanceBloc.emit(socketIOCommand);
  }

  Future disconnect() async {
    var result;

    result = await socketIOInstanceBloc.disconnect();
    return result;
  }

  @override
  Future dispose() async {
    await super.dispose();

    await socketIOInstanceBloc.dispose();
  }

  void _sendInputRequest({
    @required Network network,
    @required Channel channel,
    @required String message,
  }) {
    if (_isCollapseClientSideCommand(message)) {
      _channelTogglePreviewSubject.add(
        ToggleChannelPreviewData(
          network: network,
          channel: channel,
          allPreviewsShown: false,
        ),
      );
    } else if (_isExpandClientSideCommand(message)) {
      _channelTogglePreviewSubject.add(
        ToggleChannelPreviewData(
          network: network,
          channel: channel,
          allPreviewsShown: true,
        ),
      );
    } else {
      _sendRequest(
        request: InputLoungeJsonRequest(
          targetChannelRemoteId: channel.remoteId,
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
  Future<RequestResult<String>> uploadFile({
    @required File file,
  }) async {
    String uploadFileToken;

    var disposable = _createEventListenerDisposable(
      socketIOInstanceBloc: socketIOInstanceBloc,
      eventName: UploadAuthLoungeResponseBody.eventName,
      listener: (raw) {
        var parsed = UploadAuthLoungeResponseBody.fromRaw(raw);

        uploadFileToken = parsed.uploadAuthToken;
      },
    );
    await socketIOInstanceBloc.emit(
      UploadAuthLoungeEmptyRequest().toSocketIOCommand(),
    );

    await _doWaitForResult(() => uploadFileToken);

    await disposable.dispose();

    String loungeUrl = loungePreferences.hostPreferences.host;
    var uploadedFileRemoteURL = await uploadFileToLounge(
      loungeUrl,
      file,
      uploadFileToken,
      chatConfig.fileUploadMaxSizeInBytes,
    );

    return RequestResult.withResponse(uploadedFileRemoteURL);
  }

  IDisposable listenForLoadMore({
    @required Network network,
    @required Channel channel,
    @required Function(MessageListLoadMore) listener,
  }) {
    var disposable = CompositeDisposable([]);

    disposable.add(
      createEventListenerDisposable(
        eventName: MoreLoungeResponseBody.eventName,
        listener: (raw) {
          var moreLoungeResponseBody = MoreLoungeResponseBody.fromJson(
            _preProcessRawDataEncodeDecodeJson(
              raw: raw,
            ),
          );

          _logger.fine(
              () => "loadMoreHistory $moreLoungeResponseBody for $channel");

          if (moreLoungeResponseBody.chan == channel.remoteId) {
            toChatLoadMore(
              channel: channel,
              moreLoungeResponseBody: moreLoungeResponseBody,
            ).then(
              (chatLoadMore) {
                listener(chatLoadMore);
              },
            );
          }
        },
      ),
    );

    return disposable;
  }

  IDisposable listenForSignOut(VoidCallback callback) {
    var disposable = CompositeDisposable([]);

    disposable.add(
      StreamSubscriptionDisposable(
        signOutSubject.stream.listen(
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
        eventName: SignOutLoungeResponseBody.eventName,
        listener: (raw) {
          _logger.fine(() => "listenForSignOut $raw");
          callback();
        },
      ),
    );

    return disposable;
  }

  @override
  Future<RequestResult<MessageListLoadMore>> loadMoreHistory({
    @required Network network,
    @required Channel channel,
    @required int lastMessageId,
  }) async {
    var disposable = CompositeDisposable(
      [],
    );

    MessageListLoadMore chatLoadMore;

    disposable.add(
      listenForLoadMore(
        network: network,
        channel: channel,
        listener: (loadMoreResponse) {
          chatLoadMore = loadMoreResponse;
        },
      ),
    );

    await _sendRequest(
      request: MoreLoungeJsonRequest(
        targetChannelRemoteId: channel.remoteId,
        lastMessageRemoteId: lastMessageId,
      ),
      isNeedAddRequestToPending: false,
    );

    await _doWaitForResult(() => chatLoadMore);

    await disposable.dispose();

    return RequestResult.withResponse(chatLoadMore);
  }

  // ignore: close_sinks
  final BehaviorSubject<ToggleMessagePreviewData> messageTogglePreviewSubject =
      BehaviorSubject();

  @override
  IDisposable listenForMessagePreviewToggle({
    @required Network network,
    @required Channel channel,
    @required Function(ToggleMessagePreviewData) listener,
  }) {
    return StreamSubscriptionDisposable(
      messageTogglePreviewSubject.stream.listen(
        (ToggleMessagePreviewData toggle) {
          if (toggle.channel == channel) {
            listener(toggle);
          }
        },
      ),
    );
  }

  // ignore: close_sinks
  final BehaviorSubject<ToggleChannelPreviewData> _channelTogglePreviewSubject =
      BehaviorSubject();

  @override
  IDisposable listenForChannelPreviewToggle({
    @required Network network,
    @required Channel channel,
    @required Function(ToggleChannelPreviewData) listener,
  }) =>
      StreamSubscriptionDisposable(
        _channelTogglePreviewSubject.stream.listen(
          (ToggleChannelPreviewData toggle) {
            if (toggle.channel == channel) {
              listener(toggle);
            }
          },
        ),
      );

  @override
  Future<RequestResult<ToggleMessagePreviewData>> togglePreview({
    @required Network network,
    @required Channel channel,
    @required RegularMessage message,
    @required MessagePreview preview,
    bool waitForResult = false,
  }) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }

    var shownInverted = !preview.shown;
    preview.shown = shownInverted;
    await _sendRequest(
      request: MsgPreviewToggleLoungeJsonRequest(
        targetChannelRemoteId: channel.remoteId,
        messageRemoteId: message.messageRemoteId,
        link: preview.link,
        shown: shownInverted,
      ),
      isNeedAddRequestToPending: false,
    );

    var chatTogglePreview = ToggleMessagePreviewData(
      network: network,
      channel: channel,
      message: message,
      preview: preview,
      newShownValue: shownInverted,
    );

    messageTogglePreviewSubject.add(chatTogglePreview);
    return RequestResult.withResponse(chatTogglePreview);
  }

  void signOut() {
    signOutSubject.add(true);

    _sendRequest(
      request: SignOutLoungeEmptyRequest(),
      isNeedAddRequestToPending: false,
    );
  }
}

IDisposable _createEventListenerDisposable({
  @required SocketIOInstanceBloc socketIOInstanceBloc,
  @required String eventName,
  @required Function(dynamic raw) listener,
}) {
  socketIOInstanceBloc.on(eventName, listener);

  return CustomDisposable(
    () => socketIOInstanceBloc.off(
      eventName,
      listener,
    ),
  );
}

// dynamic because it is json entity, so maybe List or Map
dynamic _preProcessRawDataEncodeDecodeJson({
  @required raw,
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

ChatJoinChannelInputLoungeJsonRequest _findJoinChannelOriginalRequest({
  @required List<LoungeRequest> pendingRequests,
  @required JoinLoungeResponseBody joinLoungeResponseBody,
}) =>
    pendingRequests.firstWhere(
      (request) {
        if (request is ChatJoinChannelInputLoungeJsonRequest) {
          ChatJoinChannelInputLoungeJsonRequest joinRequest = request;
          if (joinRequest != null) {
            if (joinRequest.preferences.name ==
                joinLoungeResponseBody.chan.name) {
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

ChatNetworkNewLoungeJsonRequest _findOriginalJoinNetworkRequest({
  @required List<LoungeRequest> pendingRequests,
  @required NetworkLoungeResponseBodyPart loungeNetwork,
}) =>
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
