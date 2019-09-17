import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

var _logger = MyLogger(logTag: "SplashPage", enabled: true);

class SplashPage extends StatefulWidget {
  Function(BuildContext context) init;


  SplashPage(this.init);

  @override
  State<StatefulWidget> createState() => SplashScreenState(init);
}

class SplashScreenState extends State<SplashPage> {
  Function(BuildContext context) init;

  bool isAlreadyInit = false;

  SplashScreenState(this.init);

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    if(!isAlreadyInit) {
      Future.delayed(Duration(milliseconds: 100), () {
        init(context);
      });
    }
    isAlreadyInit = true;

    return PlatformScaffold(
        appBar: PlatformAppBar(title: Text(appLocalizations.tr("app_name"))),
        body: Center(
          child: SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(appLocalizations.tr("splash.loading")),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PlatformCircularProgressIndicator(),
                  )
                ]),
          ),
        ));
  }

}
