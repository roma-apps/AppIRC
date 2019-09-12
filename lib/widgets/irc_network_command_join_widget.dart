import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_command_join_channel_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/widgets/button_loading_widget.dart';

import 'form_widgets.dart';

class IRCNetworkChannelJoinWidget extends StatefulWidget {
  final IRCNetwork network;
  final VoidCallback _joinCallback;

  IRCNetworkChannelJoinWidget(this.network, this._joinCallback);

  @override
  State<StatefulWidget> createState() =>
      IRCNetworkChannelJoinState(network, _joinCallback);
}

class IRCNetworkChannelJoinState extends State<IRCNetworkChannelJoinWidget> {
  final IRCNetwork network;
  final VoidCallback _connectCallback;

  IRCNetworkChannelJoinState(this.network, this._connectCallback);

  final _passwordController = TextEditingController();
  final _channelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final LoungeService loungeService = Provider.of<LoungeService>(context);

    var joinChannelBloc =
        IRCNetworkCommandJoinChannelBloc(loungeService, network);

    var appLocalizations = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        buidFormTextRow(appLocalizations.tr('join_channel.channel'),
            _channelController, (value) {}),
        buidFormTextRow(appLocalizations.tr('join_channel.password'),
            _passwordController, (value) {}),
        Provider<AsyncOperationBloc>(
          bloc: joinChannelBloc,
          child: ButtonLoadingWidget(
            child: Text(appLocalizations.tr('join_channel.join')),
            onPressed: () {
              _sendJoinChannelMessage(joinChannelBloc);
            },
          ),
        )
      ],
    );
  }

  _sendJoinChannelMessage(
      IRCNetworkCommandJoinChannelBloc joinChannelBloc) async {
    var password = _passwordController.text;
    var channelName = _channelController.text;

    await joinChannelBloc.sendJoinIRCCommand(
        channelName: channelName, password: password);
    _connectCallback();
  }
}
