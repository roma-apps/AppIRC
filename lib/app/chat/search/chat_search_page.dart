import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/chat/search/chat_search_widget.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_scaffold.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ChatSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return buildPlatformScaffold(context,
        appBar: PlatformAppBar(
          leading: buildPlatformScaffoldAppBarBackButton(context),
          title: Text(AppLocalizations.of(context).tr("chat.search.title")),
        ),
        body: SafeArea(child: ChatSearchWidget()));
  }
}
