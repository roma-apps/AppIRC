import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/form/lounge_connection_form_widget.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/lounge_connection_bloc.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_scaffold.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

typedef LoungePreferencesActionCallback = void Function(
    BuildContext context, LoungePreferences preferences);

abstract class LoungeConnectionPage extends StatefulWidget {
  @protected
  onSuccessTestConnectionWithGivenPreferences(
      BuildContext context, LoungePreferences preferences);

  @override
  State<StatefulWidget> createState() {
    return LoungeConnectionPageState();
  }
}

class LoungeConnectionPageState extends State<LoungeConnectionPage> {
  LoungeConnectionPageState();

  @override
  Widget build(BuildContext context) {
    LoungeConnectionBloc connectionBloc = Provider.of(context);
    var loungePreferences = connectionBloc.preferences;
    return buildPlatformScaffold(
      context,
      iosContentBottomPadding: true,
      iosContentPadding: false,
      appBar: PlatformAppBar(
        title:
            Text(tr('lounge.preferences.title')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: LoungeConnectionFormWidget(loungePreferences,
                    widget.onSuccessTestConnectionWithGivenPreferences),
              )
            ],
          ),
        ),
      ),
    );
  }
}
