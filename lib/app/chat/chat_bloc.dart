import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_model.dart';
import 'package:flutter_appirc/app/networks/irc_network_channel_model.dart';
import 'package:flutter_appirc/app/networks/irc_network_model.dart';
import 'package:flutter_appirc/app/networks/irc_networks_new_connection_bloc.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';


typedef ChatPreferencesLoaderOrNull = Future<ChatPreferences> Function();

class ChatBloc extends Providable {

  final ChatBackendService backendService;
  final ChatPreferencesLoaderOrNull startPreferencesLoader;
  ChatBloc(this.backendService, this.startPreferencesLoader);

  int _maxNetworkLocalId;
  int get _nextNetworkLocalId => ++_maxNetworkLocalId;
  int _maxNetworkChannelLocalId;
  int get _nextNetworkChannelLocalId => ++_maxNetworkChannelLocalId;


  var _backendConnectedController = BehaviorSubject<bool>(seedValue: false);
  Stream<bool> get backendConnectedStream => _backendConnectedController.stream;
  Future<bool> get isBackendConnected => _backendConnectedController.last;

  var _networksController = BehaviorSubject<List<IRCNetwork>>(seedValue: []);
  Stream<List<IRCNetwork>> get networksStream => _networksController.stream;

  Future<List<IRCNetwork>> get networks => _networksController.last;
  Stream<int> get networksCountStream => networksStream.map((networks) {
    if(networks != null) {
      return 0;
    } else {
      return networks?.length;
    }
  });

  Stream<bool> get networksIsEmptyStream => networksStream.map((networks) {
    if(networks != null) {
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
    _networksController.close();
    _backendConnectedController.close();
  }

  Future<bool> connectToBackend() {

  }

  ChatNewNetworkBloc createNewChatNetworkBloc(IRCNetworkPreferences startValues) {
    return ChatNewNetworkBloc();
  }



  Stream<List<IRCNetwork>> get newNetworksStream => _networksController.stream;

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

  IRCNetworksListBloc(this.lounge, this.preferencesBloc) {
    _logger.i(() => "start creating");

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

      var networkForJoinedChannel = _networks
          .firstWhere((network) => network.remoteId == remoteNetworkId);

      var networksListPreferences = await preferencesBloc
          .getPreferenceOrValue(IRCNetworksListPreferences());

      var channelLocalId =
      networksListPreferences.getNextNetworkChannelLocalId();
      var networkChannelPreferences = IRCNetworkChannelPreferences(
          name: loungeChannel.name,
          isLobby: false,
          localId: channelLocalId);
      networkForJoinedChannel.channels.add(IRCNetworkChannel(
          networkPreferences: networkForJoinedChannel.connectionPreferences,
          type: detectIRCNetworkChannelType(loungeChannel.type),
          isEditTopicPossible: loungeChannel.editTopic,
          remoteId: loungeChannel.id,
          channelPreferences: networkChannelPreferences));


      _onNetworksListChanged();
    });

    _joinToRequestSubscription =
        lounge.joinToRequestStream.listen((resultForRequest) {
          var request = resultForRequest.request;
          var result = resultForRequest.result;

          var loungeChannel = result.chan;

          var remoteNetworkId = result.network;

          var networkForJoinedChannel = _networks
              .firstWhere((network) => network.remoteId == remoteNetworkId);

          var networksListPreferences = preferencesBloc
              .getPreferenceOrValue(() => IRCNetworksListPreferences());

          var channelLocalId =
          networksListPreferences.getNextNetworkChannelLocalId();
          var networkChannelPreferences = IRCNetworkChannelPreferences(
              password: request.body.content.channelPassword,
              name: loungeChannel.name,
              isLobby: false,
              localId: channelLocalId);
          networkForJoinedChannel.channels.add(IRCNetworkChannel(
              networkPreferences: networkForJoinedChannel.connectionPreferences,
              type: detectIRCNetworkChannelType(loungeChannel.type),
              isEditTopicPossible: loungeChannel.editTopic,
              remoteId: loungeChannel.id,
              channelPreferences: networkChannelPreferences));

          var networkPreferences = networksListPreferences.networks.firstWhere(
                  (network) =>
              network.localId == networkForJoinedChannel.localId);

          networkPreferences.channels.add(networkChannelPreferences);

          _onNetworksListChanged();


          preferencesBloc.setValue(networksListPreferences);
        });

    _closeSubscription = lounge.closeToRequestStream.listen((resultForRequest) {
      var result = resultForRequest.result;

      var loungeChannelId = result.chan;

      var channelToRemove = allNetworksChannels
          .firstWhere((channel) => channel.remoteId == loungeChannelId);

      var networkForClosedChannel = _networks.firstWhere((network) =>
      network.localId == channelToRemove.networkPreferences.localId);

      var networksListPreferences = preferencesBloc
          .getPreferenceOrValue(() => IRCNetworksListPreferences());

      networkForClosedChannel.channels.remove(channelToRemove);

      var networkPreferences = networksListPreferences.networks.firstWhere(
              (network) => network.localId == networkForClosedChannel.localId);
      networkPreferences.channels.remove(networkPreferences.channels
          .firstWhere((channel) => channel.localId == channelToRemove.localId));

      _onNetworksListChanged();
      preferencesBloc.setValue(networksListPreferences);
    });

    _quitSubscription = lounge.quitStream.listen((quitResponse) {
      var remoteNetworkId = quitResponse.network;

      var networkToQuit = _networks.firstWhere((network) =>
      network.remoteId == remoteNetworkId);
      _networks.remove(networkToQuit);


      var networksListPreferences = preferencesBloc
          .getPreferenceOrValue(() => IRCNetworksListPreferences());

      var networkPreferenceToRemove = networksListPreferences.networks
          .firstWhere((network) => network.localId == networkToQuit.localId);
      networksListPreferences.networks.remove(networkPreferenceToRemove);

      _onNetworksListChanged();
      preferencesBloc.setValue(networksListPreferences);
    });

    _logger.i(() => "stop creating");
  }

  void _onNetworksListChanged() {
    _logger.i(() => "_onNetworksListChanged $_networks");
    _networksController.sink.add(UnmodifiableListView(_networks));
  }

  void dispose() {
    _networksController.close();

    _networksSubscription.cancel();
    _closeSubscription.cancel();

    _joinToRequestSubscription.cancel();
    _joinSubscription.cancel();
    _quitSubscription.cancel();
  }

  void _addNetwork(LoungeJsonRequest<NetworkNewLoungeRequestBody> request,
      NetworkLoungeResponseBody loungeNetwork) {
    _logger.d(() => "_addNetwork $request, $loungeNetwork");
    var networksListPreferences = preferencesBloc
        .getPreferenceOrValue(() => IRCNetworksListPreferences());

    var requestBody = request.body;
    var networkConnectionPreferences = IRCNetworkConnectionPreferences(
        localId: networksListPreferences.getNextNetworkLocalId(),
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

    var channelsPreferences = requestBody.join
        .split(IRCNetworkPreferences.channelsSeparator)
        .map((channelName) {
      return IRCNetworkChannelPreferences(
          name: channelName,
          localId: networksListPreferences.getNextNetworkChannelLocalId(),
          isLobby: false);
    }).toList();

    // add lobby
    var lobbyLoungeChannel = loungeNetwork.channels.firstWhere(
            (loungeChannel) =>
        detectIRCNetworkChannelType(loungeChannel.type) ==
            IRCNetworkChannelType.LOBBY);

    if (lobbyLoungeChannel == null) {
      throw Exception("Lobby channel not found in $loungeNetwork");
    }

    channelsPreferences.add(IRCNetworkChannelPreferences(
        isLobby: true,
        localId: networksListPreferences.getNextNetworkChannelLocalId(),
        name: lobbyLoungeChannel.name));

    var networkPreferences = IRCNetworkPreferences(
        networkConnectionPreferences: networkConnectionPreferences,
        channels: channelsPreferences);

    networksListPreferences.networks.add(networkPreferences);

    preferencesBloc.setValue(networksListPreferences);

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
        status: IRCNetworkStatus(
            secure: loungeNetworkStatus.secure),
        channels: channels);

    _networks.add(network);
    _onNetworksListChanged();
  }

}

// We should force unique network names
bool _isNetworkForNewRequest(
    LoungeJsonRequest<NetworkNewLoungeRequestBody> request,
    NetworkLoungeResponseBody network) =>
    request.body.name == network.name;
