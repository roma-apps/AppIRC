import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/user/user_model.dart';

class ChannelUserInfosWidget extends StatefulWidget {
  final Stream<List<ChannelUserInfo>> usersStream;
  final List<ChannelUserInfo> usersStreamInitialValue;

  ChannelUserInfosWidget(this.usersStream, this.usersStreamInitialValue);

  @override
  State<StatefulWidget> createState() =>
      ChannelUserInfosState(usersStream, usersStreamInitialValue);
}

class ChannelUserInfosState extends State<ChannelUserInfosWidget> {
  final Stream<List<ChannelUserInfo>> usersStream;
  final List<ChannelUserInfo> usersStreamInitialValue;

  ChannelUserInfosState(this.usersStream, this.usersStreamInitialValue);

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    return StreamBuilder<List<ChannelUserInfo>>(
        stream: usersStream,
        initialData: usersStreamInitialValue,
        builder: (BuildContext context,
            AsyncSnapshot<List<ChannelUserInfo>> snapshot) {
          var users = snapshot.data;

          if (users != null && users.isNotEmpty) {
            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildUserListItem(context, users[index]);
                });
          } else {
            return Center(
                child: Text(appLocalizations.tr("chat.users.loading")));
          }
        });
  }
}

Widget _buildUserListItem(BuildContext context, ChannelUserInfo user) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(user.mode),
        Text(user.nick),
      ],
    ),
  );
}
