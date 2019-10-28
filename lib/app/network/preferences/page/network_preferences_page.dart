import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_form_widget.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/form/form_validation.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

abstract class NetworkPreferencesPage extends StatefulWidget {
  final NetworkPreferences startValues;

  successCallback(BuildContext context, NetworkPreferences preferences);

  final bool isNeedShowChannels;
  final bool isNeedShowCommands;
  final bool serverPreferencesEnabled;
  final bool serverPreferencesVisible;
  final String buttonText;
  final String titleText;

  NetworkPreferencesPage.name(
      {@required this.titleText,
      @required this.startValues,
      @required this.isNeedShowChannels,
      @required this.isNeedShowCommands,
      @required this.serverPreferencesEnabled,
      @required this.serverPreferencesVisible,
      @required this.buttonText});

  @override
  State<StatefulWidget> createState() {
    return NetworkPreferencesPageState(
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

class NetworkPreferencesPageState extends State<NetworkPreferencesPage> {
  final NetworkPreferences startValues;
  final Function(BuildContext context, NetworkPreferences preferences) callback;
  final String buttonText;

  NetworkPreferencesFormBloc networkPreferencesFormBloc;

  final String titleText;
  final bool isNeedShowChannels;
  final bool isNeedShowCommands;
  final bool serverPreferencesEnabled;
  final bool serverPreferencesVisible;

  NetworkPreferencesPageState(
      this.titleText,
      this.startValues,
      this.callback,
      this.isNeedShowChannels,
      this.isNeedShowCommands,
      this.serverPreferencesEnabled,
      this.serverPreferencesVisible,
      this.buttonText);

  @override
  void initState() {
    super.initState();
    new Future.delayed(Duration.zero, () {
      // we need valid context
      final NetworkListBloc chatBloc = Provider.of<NetworkListBloc>(context);
      CustomValidator<String> networkValidator =
          buildNetworkValidator(chatBloc);

      networkPreferencesFormBloc = NetworkPreferencesFormBloc.name(
          preferences: startValues,
          isNeedShowChannels: isNeedShowChannels,
          isNeedShowCommands: isNeedShowCommands,
          serverPreferencesEnabled: serverPreferencesEnabled,
          serverPreferencesVisible: serverPreferencesVisible,
          networkValidator: networkValidator);
    });
  }

  @override
  void dispose() {
    super.dispose();
    networkPreferencesFormBloc?.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child:
                NetworkPreferencesFormWidget(startValues, callback, buttonText),
          ),
        ),
      ),
    );
  }
}