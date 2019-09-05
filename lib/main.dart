import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/chat_bloc.dart';
import 'package:flutter_appirc/pages/new_connection_page.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/service/socketio_service.dart';
import 'package:flutter_appirc/service/thelounge_service.dart';
import 'package:logger_flutter/logger_flutter.dart';

//const String URI = "https://demo.thelounge.chat/";
const String URI = "http://192.168.0.103:9000";
var socketIOManager = SocketIOManager();
var socketIOService = SocketIOService(socketIOManager, URI);
var loungeService = TheLoungeService(socketIOService);

Future main() async {
  await socketIOService.init();
  loungeService.connect();
  LogConsole.init(bufferSize: 100);
  runApp(EasyLocalization(child: AppIRC()));
}

class AppIRC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;

    return Provider(
      bloc: loungeService,
      child: EasyLocalizationProvider(
        data: data,
        child: Provider<ChatBloc>(
            bloc: ChatBloc(loungeService),
            child: MaterialApp(
              title: 'App IRC',
              localizationsDelegates: [
                //app-specific localization
                EasylocaLizationDelegate(
                    locale: data.locale, path: 'assets/langs'),
              ],
              supportedLocales: [Locale('en', 'US')],
              locale: data.savedLocale,
              theme: ThemeData(
                primarySwatch: Colors.red,
              ),
              home: NewConnectionPage(isOpenedFromAppStart: true),
            )),
      ),
    );
  }
}
