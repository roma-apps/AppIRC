import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/network/join_channel/network_join_channel_form_bloc.dart';
import 'package:flutter_appirc/app/network/join_channel/network_join_channel_form_widget.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_blocs_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/dialog/async/async_dialog.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_scaffold.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

var _logger = MyLogger(logTag: "network_join_channel_page.dart", enabled: true);

class NetworkJoinChannelPage extends StatefulWidget {
  final Network network;

  NetworkJoinChannelPage(this.network);

  @override
  State<StatefulWidget> createState() => NetworkJoinChannelPageState(network);
}

class NetworkJoinChannelPageState extends State<NetworkJoinChannelPage> {
  final Network network;

  NetworkJoinChannelPageState(this.network);

  @override
  Widget build(BuildContext context) {
    var channelJoinFormBloc = NetworkJoinChannelFormBloc();
    var networkBloc = NetworkBlocsBloc.of(context).getNetworkBloc(network);
    return buildPlatformScaffold(
      context,
      appBar: PlatformAppBar(
        title: Text(S.of(context).chat_network_join_channel_title),
      ),
      body: SafeArea(
        child: Provider<NetworkBloc>.value(
          value: networkBloc,
          child: Provider<NetworkJoinChannelFormBloc>.value(
            value: channelJoinFormBloc,
            child: ListView(
              children: <Widget>[
                NetworkJoinChannelFormWidget(
                  startChannelName: "",
                  startPassword: "",
                ),
                StreamBuilder<bool>(
                  stream: channelJoinFormBloc.dataValidStream,
                  builder: (context, snapshot) {
                    var dataValid = snapshot.data == true;

                    var pressed = dataValid
                        ? () async {
                            await _onJoinClicked(
                                context, channelJoinFormBloc, networkBloc);
                          }
                        : null;
                    return PlatformButton(
                      child: Text(
                        S.of(context).chat_network_join_channel_action_join,
                      ),
                      onPressed: pressed,
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _onJoinClicked(
      BuildContext context,
      NetworkJoinChannelFormBloc channelJoinFormBloc,
      NetworkBloc networkBloc) async {
    var dialogResult = await doAsyncOperationWithDialog(
        context: context,
        asyncCode: () async {
          var chatChannelPreferences = ChannelPreferences.name(
              name: channelJoinFormBloc.extractChannel(),
              password: channelJoinFormBloc.extractPassword());
          _logger.d(() => "startJoinChannel $chatChannelPreferences");
          var joinResult = await networkBloc.joinChannel(chatChannelPreferences,
              waitForResult: true);
          _logger.d(() => "startJoinChannel result $joinResult");
        },
        cancelable: true);

    if (dialogResult.success) {
      _dismissDialog(context);
      _goBack(context);
    }
  }

  void _dismissDialog(BuildContext context) {
    Navigator.pop(context);
  }

  void _goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
