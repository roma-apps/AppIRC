import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/form/lounge_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/form/lounge_preferences_form_widget.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

typedef LoungePreferencesActionCallback = void Function(
    BuildContext context, LoungePreferences preferences);

abstract class LoungePreferencesPage extends StatefulWidget {
  final LoungePreferences _startPreferences;

  @protected
  onSuccessTestConnectionWithGivenPreferences(
      BuildContext context, LoungePreferences preferences);

  LoungePreferencesPage(this._startPreferences);

  @override
  State<StatefulWidget> createState() {
    return LoungePreferencesPageState(
        _startPreferences, onSuccessTestConnectionWithGivenPreferences);
  }
}

class LoungePreferencesPageState extends State<LoungePreferencesPage> {
  final LoungePreferencesActionCallback _actionCallback;
  final LoungePreferences _startPreferences;

  LoungePreferencesFormBloc _preferencesFormBloc;

  LoungePreferencesPageState(this._startPreferences, this._actionCallback) {
    _preferencesFormBloc = LoungePreferencesFormBloc(_startPreferences);
  }

  @override
  void dispose() {
    super.dispose();
    _preferencesFormBloc?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: false,
      appBar: PlatformAppBar(
        title:
            Text(AppLocalizations.of(context).tr('lounge.preferences.title')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Provider<LoungePreferencesFormBloc>(
            providable: _preferencesFormBloc,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: LoungePreferencesFormWidget(
                      _startPreferences,
                      _actionCallback,
                      AppLocalizations.of(context)
                          .tr('lounge.preferences.new.action.connect')),
                ),
                _buildTestButtons(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestButtons(BuildContext context) {
    var hostBloc = _preferencesFormBloc.connectionFormBloc.hostFieldBloc;
    var connectionPreferences = _startPreferences.connectionPreferences;
    return Column(
      children: <Widget>[
        createSkinnedPlatformButton(context, onPressed: () {
          hostBloc.onNewValue("https://irc.pleroma.social/");
          connectionPreferences.host = "https://irc.pleroma.social/";
          setState(() {});
        }, child: Text("Fill for pleroma server")),
        createSkinnedPlatformButton(context, onPressed: () {
          connectionPreferences.host = "https://demo.thelounge.chat/";
          hostBloc.onNewValue("https://demo.thelounge.chat/");

          setState(() {});
        }, child: Text("Fill for lounge demo server")),
        createSkinnedPlatformButton(context, onPressed: () {
          showPlatformDialog(
              context: context,
              builder: (_) => PlatformAlertDialog(
                    content: _buildTestServerInfo(),
                    actions: <Widget>[
                      PlatformDialogAction(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
              androidBarrierDismissible: true);

          connectionPreferences.host = "http://167.71.55.184:9000/";
          hostBloc.onNewValue("http://167.71.55.184:9000/");
          setState(() {});
        },
            child: Text("Fill for test server with push "
                "notifications"))
      ],
    );
  }

  Widget _buildTestServerInfo() {
    return Column(
      children: <Widget>[
        Text("Test server supports push notifications for Android & iOS"),
        Text("Push notifications works only in private mode"),
        Text("Lounge support registration for private mode only from command "
            "line on server"),
        Text("You can use one listed credentials for login: "),
        Text("Username: test1, Password: test1"),
        Text("Username: test2, Password: test2"),
        Text("Username: test3, Password: test3"),
        Text("Username: test4, Password: test4"),
        Text("Username: test5, Password: test5"),
        Text("Note: Currently, push notifications works only for latest device "
            "connected "
            "per credential. "),
        Text("So notifications will not work if you or someone else use "
            "credentials after your connection to lounge"),
      ],
    );
  }
}
