import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/chat/networks/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_form_widget.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_validation.dart';
import 'package:flutter_appirc/form/form_validation.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

abstract class ChatNetworkPreferencesPage extends StatefulWidget {
  final ChatNetworkPreferences startValues;

  successCallback(BuildContext context, ChatNetworkPreferences preferences);

  final bool isNeedShowChannels;
  final bool isNeedShowCommands;
  final bool serverPreferencesEnabled;
  final bool serverPreferencesVisible;
  final String buttonText;
  final String titleText;

  ChatNetworkPreferencesPage.name(
      {@required this.titleText,
      @required this.startValues,
      @required this.isNeedShowChannels,
      @required this.isNeedShowCommands,
      @required this.serverPreferencesEnabled,
      @required this.serverPreferencesVisible,
      @required this.buttonText});

  @override
  State<StatefulWidget> createState() {
    return ChatNetworkPreferencesPageState(
        titleText,
        startValues,
        successCallback,
        isNeedShowChannels,
        isNeedShowCommands,
        serverPreferencesEnabled,
        serverPreferencesVisible,
        buttonText);
  }
}

class ChatNetworkPreferencesPageState
    extends State<ChatNetworkPreferencesPage> {
  final ChatNetworkPreferences startValues;
  final Function(BuildContext context, ChatNetworkPreferences preferences) callback;
  final String buttonText;

  ChatNetworkPreferencesFormBloc networkPreferencesFormBloc;

  final String titleText;

  ChatNetworkPreferencesPageState(
      this.titleText,
      this.startValues,
      this.callback,
      bool isNeedShowChannels,
      bool isNeedShowCommands,
      bool serverPreferencesEnabled,
      bool serverPreferencesVisible,
      this.buttonText) {
    networkPreferencesFormBloc = ChatNetworkPreferencesFormBloc(
        startValues,
        isNeedShowChannels,
        isNeedShowCommands,
        serverPreferencesEnabled,
        serverPreferencesVisible);
  }

  @override
  void dispose() {
    super.dispose();
    networkPreferencesFormBloc?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatNetworksListBloc chatBloc =
        Provider.of<ChatNetworksListBloc>(context);
    networkPreferencesFormBloc.networkValidator =
        CustomValidator((networkName) async {
      var alreadyExist = await chatBloc.isNetworkWithNameExist(networkName);
      ValidationError error;
      if (alreadyExist) {
        error = NotUniqueTextValidationError();
      }
      return error;
    });

    return PlatformScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: false,
      appBar: PlatformAppBar(
        title: Text(titleText),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Provider(
            providable: networkPreferencesFormBloc,
            child: ChatNetworkPreferencesFormWidget(
                startValues, callback, buttonText),
          ),
        ),
      ),
    );
  }
}
