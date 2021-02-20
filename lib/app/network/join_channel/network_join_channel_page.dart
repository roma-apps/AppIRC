import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/network/join_channel/network_join_channel_form_bloc.dart';
import 'package:flutter_appirc/app/network/join_channel/network_join_channel_form_widget.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc_provider.dart';
import 'package:flutter_appirc/app/network/network_blocs_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_scaffold.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

var _logger = MyLogger(logTag: "network_join_channel_page.dart", enabled: true);

class NetworkJoinChannelPage extends StatefulWidget {
  final Network network;

  NetworkJoinChannelPage(this.network);

  @override
  State<StatefulWidget> createState() {
    return NetworkJoinChannelPageState(network);
  }
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
        title: Text(tr('chat.network.join_channel.title')),
      ),
      body: SafeArea(
        child: Provider(
          providable: NetworkBlocProvider(networkBloc),
          child: Provider<NetworkJoinChannelFormBloc>(
            providable: channelJoinFormBloc,
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
                    return createSkinnedPlatformButton(
                      context,
                      child: Text(
                        tr('chat.network.join_channel.action.join'),
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
        cancellationValue: null,
        isDismissible: true);

    if (dialogResult.isNotCanceled) {
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
