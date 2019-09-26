import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';
import 'package:flutter_appirc/app/message/messages_special_skin_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildSpecialMessageWidget(
    BuildContext context, SpecialMessage specialMessage) {
  switch (specialMessage.specialType) {
    case SpecialMessageType.WHO_IS:
      throw ("not imlemented");
      break;
    case SpecialMessageType.CHANNELS_LIST_ITEM:
      var channelInfoItem =
          specialMessage.data as NetworkChannelInfoSpecialMessageBody;
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildChannelName(context, channelInfoItem),
                _buildUsersCount(context, channelInfoItem),
              ],
            ),
            _buildTopic(channelInfoItem.topic),
          ],
        ),
      );
      break;
    case SpecialMessageType.TEXT:
      var textSpecialMessage = specialMessage.data as TextSpecialMessageBody;
      return Text(textSpecialMessage.message);
  }
  throw Exception("Invalid message type $specialMessage");
}

Widget _buildUsersCount(BuildContext context,
    NetworkChannelInfoSpecialMessageBody channelInfoItem) {
  return Text(AppLocalizations.of(context).tr("channels_list.users",
      args: [channelInfoItem.usersCount.toString()]));
}

Widget _buildChannelName(BuildContext context,
    NetworkChannelInfoSpecialMessageBody channelInfoItem) {
  var channelName = channelInfoItem.name;
  var password = ""; // channels list contains only channels without password
  MessagesSpecialSkinBloc messagesSpecialSkinBloc =
      Provider.of<MessagesSpecialSkinBloc>(context);
  return GestureDetector(
      onTap: () {
        NetworkBloc networkBloc = Provider.of<NetworkBloc>(context);

        networkBloc.joinNetworkChannel(ChatNetworkChannelPreferences.name(
            name: channelName, password: password));
      },
      child: Text(
        channelName,
        style: TextStyle(color: messagesSpecialSkinBloc.linkColor),
      ));
}

Widget _buildTopic(String topic) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Linkify(
        onOpen: (link) async {
          if (await canLaunch(link.url)) {
            await launch(link.url);
          } else {
            throw 'Could not launch $link';
          }
        },
        text: topic),
  );
}
