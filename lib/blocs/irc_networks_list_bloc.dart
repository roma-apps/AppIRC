import 'dart:async';
import 'dart:collection';

import 'package:flutter_appirc/blocs/irc_networks_preferences_bloc.dart';
import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "IRCNetworksListBloc", enabled: true);

class IRCNetworksListBloc extends Providable {
  final LoungeService lounge;

  final IRCNetworksPreferencesBloc preferencesBloc;
  final Set<IRCNetwork> _networks = Set<IRCNetwork>();

  List<IRCNetworkChannel> get allNetworksChannels {
    var allChannels = List<IRCNetworkChannel>();
    _networks.forEach((network) {
      allChannels.addAll(network.channels);
    });

    return allChannels;
  }

  final BehaviorSubject<List<IRCNetwork>> _networksController =
      new BehaviorSubject<List<IRCNetwork>>(seedValue: []);

  Stream<List<IRCNetwork>> get newNetworksStream => _networksController.stream;

  StreamSubscription<
      LoungeResultForRequest<LoungeJsonRequest<NetworkNewLoungeRequestBody>,
          NetworksLoungeResponseBody>> _networksSubscription;
  StreamSubscription<JoinLoungeResponseBody> _joinSubscription;

  IRCNetworksListBloc(this.lounge, this.preferencesBloc) {
    _logger.i(() => "start creating");

    _networksSubscription = lounge.networksStream.listen((resultForRequest) {
      var request = resultForRequest.request;
      var result = resultForRequest.result;

      var networkToAdd = result.networks.firstWhere(
          (loungeNetwork) => _isNetworkForNewRequest(request, loungeNetwork));

      if (networkToAdd != null) {
        _addNetwork(request, networkToAdd);
      } else {
        throw Exception(
            "Netowork not found in result $result for request $request");
      }

//
//      for (var network in event.networks) {
//        List<IRCNetworkChannel> newChannels = List();
//        var newNetwork = IRCNetwork(network.name, network.uuid, newChannels,
//            IRCNetworkStatus(network.status["connected"]));
//        for (var loungeChannel in network.channels) {
//          newChannels.add(IRCNetworkChannel(
//              name: loungeChannel.name,
//              remoteId: loungeChannel.id,
//              type: detectIRCNetworkChannelType(loungeChannel.type)));
//        }
//        newNetworks.add(newNetwork);
//      }
//
//      _networks.addAll(newNetworks);
    });

    _joinSubscription = lounge.joinStream.listen((event) {
//      var networkForChannel =
//          _networks.firstWhere((network) => network.remoteId == event.network);
//      var newChannel =
//          IRCNetworkChannel(name: event.chan.name, remoteId: event.chan.id);
//      networkForChannel.channels.add(newChannel);
//      _onNetworksListChanged();
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

    _joinSubscription.cancel();
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

    preferencesBloc.setNewPreferenceValue(networksListPreferences);

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
            connected: loungeNetworkStatus.connected,
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
