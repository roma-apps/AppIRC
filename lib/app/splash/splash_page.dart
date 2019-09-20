import 'dart:async';

import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

var _logger = MyLogger(logTag:  "SplashPage", enabled: true);

class SplashPage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    return PlatformScaffold(
        body: Center(
          child: SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PlatformCircularProgressIndicator(),
                  )
                ]),
          ),
        ));
  }

}
