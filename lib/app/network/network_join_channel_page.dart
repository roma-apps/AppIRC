import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_join_channel_form_bloc.dart';
import 'package:flutter_appirc/app/network/network_join_channel_form_widget.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class IRCNetworkChannelJoinPage extends StatefulWidget {
  final Network network;

  IRCNetworkChannelJoinPage(this.network);

  @override
  State<StatefulWidget> createState() {
    return IRCNetworkChannelJoinPageState(network);
  }
}

class IRCNetworkChannelJoinPageState extends State<IRCNetworkChannelJoinPage> {
  final Network network;

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
        providable: IRCNetworkChannelJoinFormBloc(),
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
//                          var formBloc =
//                              Provider.of<IRCNetworkChannelJoinFormBloc>(
//                                  context);
//                          return await Provider.of<NetworkBloc>(context)
//                              .joinChannel(formBloc.extractChannel(),
//                                  formBloc.extractPassword());
                        });
                      }
                    : null;
                return createSkinnedPlatformButton(
                  context,
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
