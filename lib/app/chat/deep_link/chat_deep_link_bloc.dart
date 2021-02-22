import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/chat/active_channel/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/deep_link/chat_deep_link_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_bloc.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_blocs_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/server/network_server_preferences_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';

import 'package:logging/logging.dart';
import 'package:uni_links/uni_links.dart';

var _logger = Logger("chat_deep_link_bloc.dart");

class ChatDeepLinkBloc extends DisposableOwner {
  final ChatBackendService _backendService;
  final NetworkBlocsBloc _networksBlocsBloc;
  final ChatActiveChannelBloc _activeChannelBloc;
  final NetworkListBloc _networksListBloc;
  final ChatInitBloc _chatInitBloc;

  ChatDeepLinkBloc(
      this._backendService,
      this._chatInitBloc,
      this._networksListBloc,
      this._networksBlocsBloc,
      this._activeChannelBloc) {
    _chatInitBloc.stateStream.listen((newState) {
      if (newState == ChatInitState.finished) {
        _initUniLinks();
      }
    });

    var linksStream = getLinksStream();
    _logger.fine(() => "ChatDeepLinkBloc linksStream $linksStream");
    addDisposable(
      streamSubscription: linksStream.listen(
        (String link) {
          // Parse the link and warn the user, if it is not correct
          _logger.fine(() => "linksStream link $link");
          _onNewDeepLink(link);
        },
        onError: (err) {
          _logger.fine(() => "linksStream err $err");
          // Handle exception by warning the user their action did not succeed
        },
      ),
    );
  }

  Future _initUniLinks() async {
    _logger.fine(() => "initUniLinks()");
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      String initialLink = await getInitialLink();
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
      _logger.fine(() => "initialLink $initialLink");

      _onNewDeepLink(initialLink);
    } on Exception catch (e) {
      _logger.fine(() => "initialLink exception $e");
      // Handle exception by warning the user their action did not succeed
      // return?
    }
  }

  void _onNewDeepLink(String initialLink) {
    if (initialLink != null && initialLink.isNotEmpty) {
      var chatDeepLink = _parseLink(initialLink);

      var networks = _networksListBloc.networks;
      _logger.fine(() => "onNewDeepLink chatDeepLink $chatDeepLink");
      _logger.fine(() => "onNewDeepLink networks $networks");

      var networkForDeepLink = networks.firstWhere((network) {
        var serverPreferences = network.connectionPreferences.serverPreferences;
        return serverPreferences.serverHost == chatDeepLink.host &&
            serverPreferences.serverPort == chatDeepLink.port?.toString();
      }, orElse: () => null);

      if (_backendService.chatConfig.lockNetwork && networks.isNotEmpty) {
        // try join channel if can't join new network
        networkForDeepLink = networks.first;
      }

      _logger.fine(() => "onNewDeepLink networkForDeepLink $networkForDeepLink");

      var channelPreferences =
          ChannelPreferences.name(name: chatDeepLink.channel, password: null);
      if (networkForDeepLink != null) {
        _joinChannelFromDeepLink(
            networkForDeepLink, chatDeepLink, channelPreferences);
      } else {
        _joinNetworkWithChannelFromDeepLink(chatDeepLink, channelPreferences);
      }
    }
  }

  void _joinNetworkWithChannelFromDeepLink(
      ChatDeepLink chatDeepLink, ChannelPreferences channelPreferences) {
    var defaultNetwork = _backendService.chatConfig.defaultNetwork;
    var serverPreferences = NetworkPreferences(
        NetworkConnectionPreferences(
            userPreferences: defaultNetwork.userPreferences,
            serverPreferences: NetworkServerPreferences(
                name: chatDeepLink.host,
                serverHost: chatDeepLink.host,
                serverPort: chatDeepLink.port?.toString(),
                useTls: defaultNetwork.serverPreferences.useTls,
                useOnlyTrustedCertificates: defaultNetwork
                    .serverPreferences.useOnlyTrustedCertificates)),
        [channelPreferences]);

    _networksListBloc.joinNetwork(serverPreferences);
  }

  void _joinChannelFromDeepLink(Network networkForDeepLink,
      ChatDeepLink chatDeepLink, ChannelPreferences channelPreferences) {
    var channelsBloc = _networksListBloc.getChannelListBloc(networkForDeepLink);
    var channelForDeepLink = channelsBloc.channels.firstWhere((channel) {
      return channel.name == chatDeepLink.channel;
    }, orElse: () => null);

    if (channelForDeepLink != null) {
      _activeChannelBloc.changeActiveChanel(channelForDeepLink);
    } else {
      var networkBloc = _networksBlocsBloc.getNetworkBloc(networkForDeepLink);

      networkBloc.joinChannel(channelPreferences);
    }
  }

  ChatDeepLink _parseLink(String link) {
    ChatDeepLink deepLink;
    try {
      var uri = Uri.parse(link);
      var fragment = uri.fragment;
      if (fragment != null) {
        fragment = "#" + fragment;
      }
      deepLink = ChatDeepLink(uri.host, uri.port, fragment);
    } catch (e, stackTrace) {
      _logger.warning(() => "_parseLink", e, stackTrace);
    }
    return deepLink;
  }
}
