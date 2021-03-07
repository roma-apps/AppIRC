import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => PlatformScaffold(
        backgroundColor: Color(0x424242),
        body: SafeArea(
          child: _SplashPageBody(),
        ),
      );

  const SplashPage();
}

class _SplashPageBody extends StatelessWidget {
  const _SplashPageBody({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image(
              image: AssetImage(
                'assets/images/logo.png',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
