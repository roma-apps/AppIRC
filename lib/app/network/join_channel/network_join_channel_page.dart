import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/chat/networks/chat_networks_blocs_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/join_channel/network_join_channel_form_bloc.dart';
import 'package:flutter_appirc/app/network/join_channel/network_join_channel_form_widget.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

var _logger = MyLogger(logTag: "NetworkChannelJoinPage", enabled: true);

class NetworkChannelJoinPage extends StatefulWidget {
  final Network network;

  NetworkChannelJoinPage(this.network);

  @override
  State<StatefulWidget> createState() {
    return NetworkChannelJoinPageState(network);
  }
}

class NetworkChannelJoinPageState extends State<NetworkChannelJoinPage> {
  final Network network;

  NetworkChannelJoinPageState(this.network);

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    var networkChannelJoinFormBloc = NetworkChannelJoinFormBloc();
    var networkBloc = ChatNetworksBlocsBloc.of(context).getNetworkBloc(network);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(appLocalizations.tr('chat.network.join_channel.title')),
      ),
      body: SafeArea(
          child: Provider(
        providable: NetworkBlocProvider(networkBloc),
        child: Provider<NetworkChannelJoinFormBloc>(
          providable: networkChannelJoinFormBloc,
          child: ListView(children: <Widget>[
            NetworkChannelJoinFormWidget("", ""),
            StreamBuilder<bool>(
                stream: networkChannelJoinFormBloc.dataValidStream,
                builder: (context, snapshot) {
                  var dataValid = snapshot.data == true;

                  var pressed = dataValid
                      ? () async {
                          var dialogResult = await doAsyncOperationWithDialog(
                              context, asyncCode: () async {
                            var chatNetworkChannelPreferences =
                                ChatNetworkChannelPreferences.name(
                                    name: networkChannelJoinFormBloc
                                        .extractChannel(),
                                    password: networkChannelJoinFormBloc
                                        .extractPassword());
                            _logger.d(() =>
                                "startJoinChannel $chatNetworkChannelPreferences");
                            var joinResult =
                                await networkBloc.joinNetworkChannel(
                                    chatNetworkChannelPreferences,
                                    waitForResult: true);
                            _logger
                                .d(() => "startJoinChannel result $joinResult");
                          }, cancellationValue: null, isDismissible: true);

                          if (dialogResult.isNotCanceled) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        }
                      : null;
                  return createSkinnedPlatformButton(
                    context,
                    child: Text(
                      appLocalizations.tr('chat.network.join_channel.action.'
                          '.join'),
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: pressed,
                  );
                })
          ]),
        ),
      )),
    );
  }
}
