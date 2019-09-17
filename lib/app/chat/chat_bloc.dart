import 'dart:async';
import 'dart:collection';

import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_model.dart';
import 'package:flutter_appirc/app/networks/irc_network_channel_model.dart';
import 'package:flutter_appirc/app/networks/irc_network_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_service.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "ChatBloc", enabled: true);

class ServerNameNotUniqueException implements Exception {}

typedef ChatPreferencesLoaderOrNull = Future<ChatPreferences> Function();

typedef IdGenerator = Future<int> Function();

class ChatBloc extends Providable {
  final IdGenerator nextChannelIdGenerator;
  final IdGenerator nextNetworkIdGenerator;
  final LoungeBackendService backendService;

  LoungeService get lounge => backendService.lounge;
  final ChatPreferencesLoaderOrNull startPreferencesLoader;

  ChatBloc(this.backendService, this.startPreferencesLoader,
      this.nextNetworkIdGenerator, this.nextChannelIdGenerator) {
    _networksSubscription = lounge.networksStream.listen((resultForRequest) {
      var request = resultForRequest.request;
      var result = resultForRequest.result;

      var networkToAdd = result.networks.firstWhere(
              (loungeNetwork) =>
              _isNetworkForNewRequest(request, loungeNetwork));

      if (networkToAdd != null) {
        _addNetwork(request, networkToAdd);
      } else {
        throw Exception(
            "Netowork not found in result $result for request $request");
      }
    });

    _joinSubscription = lounge.joinStream.listen((result) async {
      var loungeChannel = result.chan;

      var remoteNetworkId = result.network;

      var networkForJoinedChannel = (await networks)
          .firstWhere((network) => network.remoteId == remoteNetworkId);

//      var networksListPreferences = await preferencesBloc
//          .getPreferenceOrValue(IRCNetworksListPreferences());


      var networkChannelPreferences = IRCNetworkChannelPreferences(
          name: loungeChannel.name,
          isLobby: false,
          localId: await _nextNetworkChannelLocalId);
      networkForJoinedChannel.channels.add(IRCNetworkChannel(
          networkPreferences: networkForJoinedChannel.connectionPreferences,
          type: detectIRCNetworkChannelType(loungeChannel.type),
          isEditTopicPossible: loungeChannel.editTopic,
          remoteId: loungeChannel.id,
          channelPreferences: networkChannelPreferences));

      _onNetworksListChanged();
    });

    _joinToRequestSubscription =
        lounge.joinToRequestStream.listen((resultForRequest) async {
          var request = resultForRequest.request;
          var result = resultForRequest.result;

          var loungeChannel = result.chan;

          var remoteNetworkId = result.network;

          var networkForJoinedChannel = (await networks)
              .firstWhere((network) => network.remoteId == remoteNetworkId);

//          var networksListPreferences = preferencesBloc
//              .getPreferenceOrValue(() => IRCNetworksListPreferences());

          var networkChannelPreferences = IRCNetworkChannelPreferences(
              password: request.body.content.channelPassword,
              name: loungeChannel.name,
              isLobby: false,
              localId: await _nextNetworkChannelLocalId);
          networkForJoinedChannel.channels.add(IRCNetworkChannel(
              networkPreferences: networkForJoinedChannel.connectionPreferences,
              type: detectIRCNetworkChannelType(loungeChannel.type),
              isEditTopicPossible: loungeChannel.editTopic,
              remoteId: loungeChannel.id,
              channelPreferences: networkChannelPreferences));
//
//          var networkPreferences = networksListPreferences.networks.firstWhere(
//                  (network) =>
//              network.localId == networkForJoinedChannel.localId);
//
//          networkPreferences.channels.add(networkChannelPreferences);

          _onNetworksListChanged();

//          preferencesBloc.setValue(networksListPreferences);
        });

    _closeSubscription =
        lounge.closeToRequestStream.listen((resultForRequest) async {
          var result = resultForRequest.result;

          var loungeChannelId = result.chan;

          var channelToRemove = (await allNetworksChannels)
              .firstWhere((channel) => channel.remoteId == loungeChannelId);

          var networkForClosedChannel = (await networks).firstWhere((network) =>
          network.localId == channelToRemove.networkPreferences.localId);
//
//      var networksListPreferences = preferencesBloc
//          .getPreferenceOrValue(() => IRCNetworksListPreferences());

          networkForClosedChannel.channels.remove(channelToRemove);
//
//      var networkPreferences = networksListPreferences.networks.firstWhere(
//              (network) => network.localId == networkForClosedChannel.localId);
//      networkPreferences.channels.remove(networkPreferences.channels
//          .firstWhere((channel) => channel.localId == channelToRemove.localId));

          _onNetworksListChanged();
//      preferencesBloc.setValue(networksListPreferences);
        });

    _quitSubscription = lounge.quitStream.listen((quitResponse) async {
      var remoteNetworkId = quitResponse.network;

      var networkToQuit = (await networks)
          .firstWhere((network) => network.remoteId == remoteNetworkId);
      (await networks).remove(networkToQuit);

//
//      var networksListPreferences = preferencesBloc
//          .getPreferenceOrValue(() => IRCNetworksListPreferences());
//
//      var networkPreferenceToRemove = networksListPreferences.networks
//          .firstWhere((network) => network.localId == networkToQuit.localId);
//      networksListPreferences.networks.remove(networkPreferenceToRemove);

      _onNetworksListChanged();
//      preferencesBloc.setValue(networksListPreferences);
    });
  }

  Future<int> get _nextNetworkLocalId async => await nextNetworkIdGenerator();

  Future<int> get _nextNetworkChannelLocalId async =>
      await nextChannelIdGenerator();

  Stream<bool> get connectedStream => backendService.connectedStream;

  bool get isConnected  =>  backendService.isConnected;

  var _networksController = BehaviorSubject<List<IRCNetwork>>(seedValue: []);

  Stream<List<IRCNetwork>> get networksStream => _networksController.stream;

  List<IRCNetwork> get networks => _networksController.value;

  Stream<int> get networksCountStream =>
      networksStream.map((networks) {
        if (networks != null) {
          return 0;
        } else {
          return networks?.length;
        }
      });

  Stream<bool> get networksIsEmptyStream =>
      networksStream.map((networks) {
        if (networks != null) {
          return true;
        } else {
          return networks.isEmpty;
        }
      });

  Future<bool> get isNetworksEmpty async => (await networks).isEmpty;

  Future<bool> get isNetworksNotEmpty async => !(await isNetworksEmpty);

  Future<List<IRCNetworkChannel>> get allNetworksChannels async {
    var allChannels = List<IRCNetworkChannel>();
    (await networks).forEach((network) {
      allChannels.addAll(network.channels);
    });

    return allChannels;
  }

  @override
  void dispose() {
    _networksSubscription.cancel();
    _networksController.close();

    _closeSubscription.cancel();

    _joinToRequestSubscription.cancel();
    _joinSubscription.cancel();
    _quitSubscription.cancel();
  }

  Future<bool> connectToBackend() async {
    var result;
    try {
      result = await backendService.connect();
    } on Exception catch(e) {
      result = false;
      _logger.i(() => "error during connectToBackend $e");
    }

    return result;

  }

  StreamSubscription<
      LoungeResultForRequest<LoungeJsonRequest<NetworkNewLoungeRequestBody>,
          NetworksLoungeResponseBody>> _networksSubscription;
  StreamSubscription<
      LoungeResultForRequest<LoungeJsonRequest<InputLoungeRequestBody>,
          JoinLoungeResponseBody>> _joinToRequestSubscription;
  StreamSubscription<JoinLoungeResponseBody> _joinSubscription;
  StreamSubscription<QuitLoungeResponseBody> _quitSubscription;
  StreamSubscription<
      LoungeResultForRequest<LoungeJsonRequest<InputLoungeRequestBody>,
          ChanLoungeResponseBody>> _closeSubscription;

  void _onNetworksListChanged() async {
//    _logger.i(() => "_onNetworksListChanged $(await networks)");
    var list = (await networks);
    _networksController.add(UnmodifiableListView(list));
  }

  void _addNetwork(LoungeJsonRequest<NetworkNewLoungeRequestBody> request,
      NetworkLoungeResponseBody loungeNetwork) async {
    _logger.d(() => "_addNetwork $request, $loungeNetwork");
//    var networksListPreferences = preferencesBloc
//        .getPreferenceOrValue(() => IRCNetworksListPreferences());

    var requestBody = request.body;
    var networkConnectionPreferences = IRCNetworkConnectionPreferences(
        localId: await _nextNetworkLocalId,
        userPreferences: IRCNetworkUserPreferences(
            realName: requestBody.realname,
            username: requestBody.username,
            nickname: requestBody.nick),
        serverPreferences: IRCNetworkServerPreferences(
            serverHost: requestBody.host,
            serverPort: requestBody.port,
            useTls: requestBody.isTls,
            name: requestBody.name,
            useOnlyTrustedCertificates: requestBody.isRejectUnauthorized));

    List<IRCNetworkChannelPreferences> channelsPreferences = [];
    requestBody.join
        .split(IRCNetworkPreferences.channelsSeparator)
        .forEach((channelName) async {
      channelsPreferences.add(IRCNetworkChannelPreferences(
          name: channelName,
          localId: await _nextNetworkChannelLocalId,
          isLobby: false));
      });

    // add lobby
    var lobbyLoungeChannel = loungeNetwork.channels.firstWhere(
            (loungeChannel) =>
        detectIRCNetworkChannelType(loungeChannel.type) ==
            IRCNetworkChannelType.LOBBY);

    if (lobbyLoungeChannel == null) {
      throw Exception("Lobby channel not found in $loungeNetwork");
    }

    var lobbyId = await _nextNetworkChannelLocalId;
    channelsPreferences.add(IRCNetworkChannelPreferences(
        isLobby: true,
        localId: lobbyId,
        name: lobbyLoungeChannel.name));

//    var networkPreferences = IRCNetworkPreferences(
//        networkConnectionPreferences: networkConnectionPreferences,
//        channels: channelsPreferences);

//    networksListPreferences.networks.add(networkPreferences);
//
//    preferencesBloc.setValue(networksListPreferences);

    var loungeNetworkStatus = loungeNetwork.status;

    var channels = loungeNetwork.channels.map((loungeChannel) {
      return IRCNetworkChannel(
          channelPreferences: channelsPreferences.firstWhere(
                  (channelPreference) =>
              channelPreference.name == loungeChannel.name),
          remoteId: loungeChannel.id,
          isEditTopicPossible: loungeChannel.editTopic,
          type: detectIRCNetworkChannelType(loungeChannel.type),
          networkPreferences: networkConnectionPreferences);
    }).toList();
    var network = IRCNetwork(
        connectionPreferences: networkConnectionPreferences,
        remoteId: loungeNetwork.uuid,
        status: IRCNetworkStatus(secure: loungeNetworkStatus.secure),
        channels: channels);

    (await networks).add(network);
    _onNetworksListChanged();
  }

  Future<bool> isNetworkWithNameExist(String name) async {
    var found = (await networks)
        .firstWhere((network) => network.name == name, orElse: () => null);

    return found != null;
  }

  sendNewNetworkRequest(IRCNetworkPreferences preferences) async {
    var contains = await isNetworkWithNameExist(
        preferences.networkConnectionPreferences.name);

    if (contains) {
      throw new ServerNameNotUniqueException();
    }
    return await lounge.sendNewNetworkRequest(preferences);
  }
}

// We should force unique network names
bool _isNetworkForNewRequest(
    LoungeJsonRequest<NetworkNewLoungeRequestBody> request,
    NetworkLoungeResponseBody network) =>
    request.body.name == network.name;

class IRCNetworkStateBloc extends Providable {
  final LoungeService lounge;
  final IRCNetwork network;

  var _stateController =
  BehaviorSubject<IRCNetworkState>(seedValue: IRCNetworkState.DISCONNECTED);

  StreamSubscription<NetworkStatusLoungeResponseBody> stateSubscription;

  Stream<IRCNetworkState> get stateStream => _stateController.stream;

  IRCNetworkStateBloc(this.lounge, this.network) {
    stateSubscription =
        lounge.networkStatusStream.listen((loungeNetworkStatus) {
          if (loungeNetworkStatus.network == network.remoteId) {
            var newState;

            if (loungeNetworkStatus.connected) {
              newState = IRCNetworkState.CONNECTED;
            } else {
              newState = IRCNetworkState.DISCONNECTED;
            }

            _stateController.add(newState);
          }
        });
  }

  @override
  void dispose() {
    _stateController.close();
    stateSubscription.cancel();
  }
}

class IRCNetworkChannelStateBloc extends Providable {
  final LoungeService _lounge;
  final IRCNetworkChannel channel;
  final IRCNetworkStateBloc networkStateBloc;

  var _channelStateController = BehaviorSubject<IRCNetworkChannelState>(
      seedValue: IRCNetworkChannelState.DISCONNECTED);

  StreamSubscription<ChannelStateLoungeResponseBody> channelStateSubscription;
  StreamSubscription<IRCNetworkState> networkStateSubscription;

  Stream<IRCNetworkChannelState> get channelStateStream =>
      _channelStateController.stream;

  IRCNetworkChannelStateBloc(this._lounge, this.networkStateBloc,
      this.channel) {
    networkStateSubscription =
        networkStateBloc.stateStream.listen((networkState) {
          if (networkState == IRCNetworkState.DISCONNECTED) {
            _channelStateController.add(IRCNetworkChannelState.DISCONNECTED);
          }
        });

    channelStateSubscription =
        _lounge.channelStateStream.listen((loungeChannelState) {
          if (loungeChannelState.chan == channel.remoteId) {
            var newState;
            switch (loungeChannelState.state) {
              case ChannelStateLoungeResponseBody.STATE_CONNECTED:
                newState = IRCNetworkChannelState.CONNECTED;
                break;
              case ChannelStateLoungeResponseBody.STATE_DISCONNECTED:
                newState = IRCNetworkChannelState.DISCONNECTED;
                break;
              default:
                throw Exception("Invalid channel state $loungeChannelState");
            }

            _channelStateController.add(newState);
          }
        });
  }

  @override
  void dispose() {
    _channelStateController.close();
    channelStateSubscription.cancel();
    networkStateSubscription.cancel();
  }
}
