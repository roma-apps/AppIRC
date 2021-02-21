import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/chat/search/chat_search_bloc.dart';
import 'package:flutter_appirc/app/chat/search/chat_search_widget.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_scaffold.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class ChatSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var chatSearchBloc = Provider.of<ChatSearchBloc>(context);
    return buildPlatformScaffold(
      context,
      appBar: PlatformAppBar(
        leading: buildPlatformScaffoldAppBarBackButton(context),
        title: Text(
          S.of(context).chat_search_title(chatSearchBloc.channel.name),
        ),
      ),
      body: SafeArea(
        child: ChatSearchWidget(),
      ),
    );
  }
}
