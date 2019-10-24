import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
