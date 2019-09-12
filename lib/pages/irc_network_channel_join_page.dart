import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/widgets/irc_network_command_join_widget.dart';
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
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(AppLocalizations.of(context).tr('join_channel.title')),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    child: IRCNetworkChannelJoinWidget(network, () {
                      Navigator.pop(context);
                    })),
              ],
            );
          },
        ),
      ),
    );
  }
}
