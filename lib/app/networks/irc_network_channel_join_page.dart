import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/chat/network_bloc.dart';
import 'package:flutter_appirc/app/networks/irc_network_command_join_form_bloc.dart';
import 'package:flutter_appirc/app/networks/irc_network_command_join_form_widget.dart';
import 'package:flutter_appirc/app/networks/irc_network_model.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class IRCNetworkChannelJoinPage extends StatefulWidget {
  final IRCNetwork network;

  IRCNetworkChannelJoinPage(this.network);

  @override
  State<StatefulWidget> createState() {
    return IRCNetworkChannelJoinPageState(network);
  }
}

class IRCNetworkChannelJoinPageState extends State<IRCNetworkChannelJoinPage> {
  final IRCNetwork network;

  IRCNetworkChannelJoinPageState(this.network);

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(appLocalizations.tr('join_channel.title')),
      ),
      body: SafeArea(
          child: Provider<IRCNetworkChannelJoinFormBloc>(
        bloc: IRCNetworkChannelJoinFormBloc(),
        child: ListView(children: <Widget>[
          IRCNetworkChannelJoinFormWidget("", ""),
          StreamBuilder<bool>(
              stream: Provider.of<IRCNetworkChannelJoinFormBloc>(context)
                  .dataValidStream,
              builder: (context, snapshot) {
                var dataValid = snapshot.data;

                var pressed = dataValid
                    ? () {
                        doAsyncOperationWithDialog(context, () async {
                          var formBloc =
                              Provider.of<IRCNetworkChannelJoinFormBloc>(
                                  context);
                          return await Provider.of<NetworkBloc>(context)
                              .joinChannel(formBloc.extractChannel(),
                                  formBloc.extractPassword());
                        });
                      }
                    : null;
                return PlatformButton(
                  child: Text(
                    appLocalizations.tr('join_channel.join'),
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: pressed,
                );
              })
        ]),
      )),
    );
  }
}
