import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/user/user_widget.dart';
import 'package:flutter_appirc/app/user/users_list_bloc.dart';
import 'package:flutter_appirc/colored_nicknames/colored_nicknames_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/text_skin_bloc.dart';

class ChannelUsersListWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChannelUsersListWidgetState();
}

class ChannelUsersListWidgetState extends State<ChannelUsersListWidget> {
  TextEditingController filterController;

  @override
  void initState() {
    super.initState();
    filterController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    filterController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);

    TextSkinBloc textSkinBloc = Provider.of(context);
    ColoredNicknamesBloc coloredNicknamesBloc = Provider.of(context);
    ChannelUsersListBloc channelUsersListBloc =
        Provider.of<ChannelUsersListBloc>(context);

    return StreamBuilder<List<NetworkChannelUser>>(
        stream: channelUsersListBloc.usersStream,
        initialData: channelUsersListBloc.users,
        builder: (BuildContext context,
            AsyncSnapshot<List<NetworkChannelUser>> snapshot) {
          var users = snapshot.data;

          if (users != null) {
            Widget body;
            if (users.isEmpty) {
              body = Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Text(
                        appLocalizations.tr("chat.users_list.search"
                            ".users_not_found"),
                        style: textSkinBloc.defaultTextStyle)),
              );
            } else {
              body = Flexible(
                child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildUserListItem(
                          context, users[index], coloredNicknamesBloc);
                    }),
              );
            }
            return Column(
              children: <Widget>[
                buildFormTextField(
                  context: context,
                  bloc: channelUsersListBloc.filterFieldBloc,
                  controller: filterController,
                  label: AppLocalizations.of(context)
                      .tr("chat.users_list.search.field.filter.label"),
                  hint: AppLocalizations.of(context)
                      .tr("chat.users_list.search.field.filter.hint"),
                ),
                body,
              ],
            );
          } else {
            return Center(
                child: Text(appLocalizations.tr("chat.users_list.loading"),
                    style: textSkinBloc.defaultTextStyle));
          }
        });
  }
}

Widget _buildUserListItem(BuildContext context, NetworkChannelUser user,
    ColoredNicknamesBloc coloredNicknamesBloc) {
  var nick = user.nick;
  var color = coloredNicknamesBloc.getColorForNick(nick);

  var child = Text("${user.mode}$nick", style: TextStyle(color: color));

  NetworkChannelBloc channelBloc = NetworkChannelBloc.of(context);
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: buildUserNickWithPopupMenu(context, child, nick, channelBloc,
        actionCallback: (_) {
      Navigator.pop(context);
    }),
  );
}
