import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/user/list/user_list_bloc.dart';
import 'package:flutter_appirc/app/user/user_widget.dart';
import 'package:flutter_appirc/colored_nicknames/colored_nicknames_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/text_skin_bloc.dart';

class ChannelUsersListWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChannelUsersListWidgetState();
}

class ChannelUsersListWidgetState extends State<ChannelUsersListWidget> {
  TextEditingController _filterController;

  @override
  void initState() {
    super.initState();
    _filterController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _filterController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColoredNicknamesBloc coloredNicknamesBloc = Provider.of(context);
    ChannelUsersListBloc channelUsersListBloc =
        Provider.of<ChannelUsersListBloc>(context);

    return StreamBuilder<List<ChannelUser>>(
        stream: channelUsersListBloc.usersStream,
        initialData: channelUsersListBloc.users,
        builder: (BuildContext context,
            AsyncSnapshot<List<ChannelUser>> snapshot) {
          var users = snapshot.data;

          if (users != null) {
            Widget body;
            if (users.isEmpty) {
              body = _buildEmptyListWidget(context);
            } else {
              body = _buildUserListWidget(users, coloredNicknamesBloc);
            }
            return _buildSearchableUserListWidget(
                context, channelUsersListBloc, body);
          } else {
            return _buildLoadingWidget(context);
          }
        });
  }

  Center _buildLoadingWidget(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);

    TextSkinBloc textSkinBloc = Provider.of(context);
    return Center(
        child: Text(appLocalizations.tr("chat.users_list.loading"),
            style: textSkinBloc.defaultTextStyle));
  }

  Column _buildSearchableUserListWidget(BuildContext context,
      ChannelUsersListBloc channelUsersListBloc, Widget body) {
    return Column(
      children: <Widget>[
        buildFormTextField(
          context: context,
          bloc: channelUsersListBloc.filterFieldBloc,
          controller: _filterController,
          label: AppLocalizations.of(context)
              .tr("chat.users_list.search.field.filter.label"),
          hint: AppLocalizations.of(context)
              .tr("chat.users_list.search.field.filter.hint"),
        ),
        body,
      ],
    );
  }

  Flexible _buildUserListWidget(List<ChannelUser> users,
      ColoredNicknamesBloc coloredNicknamesBloc) {
    return Flexible(
      child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildUserListItem(
                context, users[index], coloredNicknamesBloc);
          }),
    );
  }

  Padding _buildEmptyListWidget(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);

    TextSkinBloc textSkinBloc = Provider.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
          child: Text(
              appLocalizations.tr("chat.users_list.search.users_not_found"),
              style: textSkinBloc.defaultTextStyle)),
    );
  }
}

Widget _buildUserListItem(BuildContext context, ChannelUser user,
    ColoredNicknamesBloc coloredNicknamesBloc) {
  var nick = user.nick;

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: buildUserNickWithPopupMenu(
        context: context,
        nick: nick,
        actionCallback: (_) {
          Navigator.pop(context);
        }),
  );
}
