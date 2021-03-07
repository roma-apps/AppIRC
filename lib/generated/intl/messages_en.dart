// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static m0(topic) => "${topic}:";

  static m1(count) => "${Intl.plural(count, one: '1 user has gone away', other: '${count} users has gone away')}";

  static m2(count) => "${Intl.plural(count, one: '1 user has come back', other: '${count} users has come back')}";

  static m3(count) => "${Intl.plural(count, one: '1 user has changed hostname', other: '${count} users has changed hostname')}";

  static m4(count) => "${Intl.plural(count, one: '1 user has joined', other: '${count} users has joined')}";

  static m5(count) => "${Intl.plural(count, one: '1 user was kicked', other: '${count} users were kicked')}";

  static m6(count) => "${Intl.plural(count, one: '1 mode was set', other: '${count} modes was set')}";

  static m7(count) => "${Intl.plural(count, one: '1 channel mode was set', other: '${count} channel mode were set')}";

  static m8(count) => "${Intl.plural(count, one: '1 user has changed nick', other: '${count} users has changed nick')}";

  static m9(count) => "${Intl.plural(count, one: '1 user has left', other: '${count} users has left')}";

  static m10(count) => "${Intl.plural(count, one: '1 user was quit', other: '${count} users was quit')}";

  static m11(shortMessage) => "Channel mode: ${shortMessage}";

  static m12(shortMessage) => "mode ${shortMessage}";

  static m13(shortMessage) => "motd: ${shortMessage}";

  static m14(newNick) => "change nick to ${newNick}";

  static m15(users) => "${users} users";

  static m16(user) => "Message from ${user}";

  static m17(count) => "Jump to latest messages (${count} new)";

  static m18(maxSize, actualSize) => "File exceeds maximum size ${maxSize}. Actual size is ${actualSize}";

  static m19(responseBody) => "Invalid http response body: ${responseBody}";

  static m20(responseCode) => "Invalid http code: ${responseCode}";

  static m21(channel) => "Search in ${channel}";

  static m22(errorMessage) => "An error has occurred. \n${errorMessage}";

  static m23(error) => "Can\'t connect to host. Error: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "app_init_fail" : MessageLookupByLibrary.simpleMessage("Failed to start app.\nTry restart or re-install app."),
    "app_name" : MessageLookupByLibrary.simpleMessage("AppIRC"),
    "chat_channel_action_leave" : MessageLookupByLibrary.simpleMessage("Leave"),
    "chat_channel_action_list_banned" : MessageLookupByLibrary.simpleMessage("List banned users"),
    "chat_channel_action_topic" : MessageLookupByLibrary.simpleMessage("Topic"),
    "chat_channel_action_user_information" : MessageLookupByLibrary.simpleMessage("User information"),
    "chat_channel_action_users" : MessageLookupByLibrary.simpleMessage("Users"),
    "chat_channel_topic_dialog_action_cancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "chat_channel_topic_dialog_action_change" : MessageLookupByLibrary.simpleMessage("Change"),
    "chat_channel_topic_dialog_field_edit_hint" : MessageLookupByLibrary.simpleMessage("Hey there!"),
    "chat_channel_topic_dialog_field_edit_label" : MessageLookupByLibrary.simpleMessage("Topic"),
    "chat_channel_topic_dialog_title" : m0,
    "chat_connection_public_reconnectNotSupported_action_restart" : MessageLookupByLibrary.simpleMessage("Restart"),
    "chat_connection_public_reconnectNotSupported_action_signOut" : MessageLookupByLibrary.simpleMessage("Sign out"),
    "chat_connection_public_reconnectNotSupported_description" : MessageLookupByLibrary.simpleMessage("The Lounge don\'t support reconnect in public mode."),
    "chat_message_action_copy" : MessageLookupByLibrary.simpleMessage("Copy text body"),
    "chat_message_preview_error_server" : MessageLookupByLibrary.simpleMessage("Server failed to fetch preview metadata"),
    "chat_message_preview_loading" : MessageLookupByLibrary.simpleMessage("Loading..."),
    "chat_message_preview_title" : MessageLookupByLibrary.simpleMessage("Preview"),
    "chat_message_regular_condensed_away" : m1,
    "chat_message_regular_condensed_back" : m2,
    "chat_message_regular_condensed_chghost" : m3,
    "chat_message_regular_condensed_join" : m4,
    "chat_message_regular_condensed_kick" : m5,
    "chat_message_regular_condensed_mode" : m6,
    "chat_message_regular_condensed_mode_channel" : m7,
    "chat_message_regular_condensed_nick" : m8,
    "chat_message_regular_condensed_part" : m9,
    "chat_message_regular_condensed_quit" : m10,
    "chat_message_regular_sub_message_away" : MessageLookupByLibrary.simpleMessage("away"),
    "chat_message_regular_sub_message_back" : MessageLookupByLibrary.simpleMessage("back"),
    "chat_message_regular_sub_message_channel_mode" : m11,
    "chat_message_regular_sub_message_chghost" : MessageLookupByLibrary.simpleMessage("changed host"),
    "chat_message_regular_sub_message_ctcp" : MessageLookupByLibrary.simpleMessage("CTCP"),
    "chat_message_regular_sub_message_ctcp_request" : MessageLookupByLibrary.simpleMessage("CTCP request"),
    "chat_message_regular_sub_message_error" : MessageLookupByLibrary.simpleMessage("error"),
    "chat_message_regular_sub_message_invite" : MessageLookupByLibrary.simpleMessage("invite"),
    "chat_message_regular_sub_message_join" : MessageLookupByLibrary.simpleMessage("joined"),
    "chat_message_regular_sub_message_kick" : MessageLookupByLibrary.simpleMessage("kick"),
    "chat_message_regular_sub_message_mode_long" : MessageLookupByLibrary.simpleMessage("mode"),
    "chat_message_regular_sub_message_mode_short" : m12,
    "chat_message_regular_sub_message_motd" : m13,
    "chat_message_regular_sub_message_nick" : m14,
    "chat_message_regular_sub_message_notice" : MessageLookupByLibrary.simpleMessage("notice"),
    "chat_message_regular_sub_message_part" : MessageLookupByLibrary.simpleMessage("part"),
    "chat_message_regular_sub_message_quit" : MessageLookupByLibrary.simpleMessage("quit"),
    "chat_message_regular_sub_message_topic" : MessageLookupByLibrary.simpleMessage("Topic"),
    "chat_message_regular_sub_message_topic_set_by" : MessageLookupByLibrary.simpleMessage("set topic"),
    "chat_message_regular_sub_message_unknown" : MessageLookupByLibrary.simpleMessage("unknown"),
    "chat_message_regular_sub_message_who_is" : MessageLookupByLibrary.simpleMessage("(who is)"),
    "chat_message_special_channels_list_users" : m15,
    "chat_message_special_who_is_account" : MessageLookupByLibrary.simpleMessage("Account:"),
    "chat_message_special_who_is_actual_hostname" : MessageLookupByLibrary.simpleMessage("Actual hostname:"),
    "chat_message_special_who_is_channels" : MessageLookupByLibrary.simpleMessage("Channels:"),
    "chat_message_special_who_is_connected_at" : MessageLookupByLibrary.simpleMessage("Connected at:"),
    "chat_message_special_who_is_connected_to" : MessageLookupByLibrary.simpleMessage("Connected to:"),
    "chat_message_special_who_is_hostmask" : MessageLookupByLibrary.simpleMessage("Hostmask:"),
    "chat_message_special_who_is_idle_since" : MessageLookupByLibrary.simpleMessage("Idle since:"),
    "chat_message_special_who_is_real_name" : MessageLookupByLibrary.simpleMessage("Real Name:"),
    "chat_message_special_who_is_secure_connection" : MessageLookupByLibrary.simpleMessage("Secure connection:"),
    "chat_message_title_from" : m16,
    "chat_message_title_simple" : MessageLookupByLibrary.simpleMessage("Message"),
    "chat_messages_list_empty_connected" : MessageLookupByLibrary.simpleMessage("This channel doesn\'t have any messages yet"),
    "chat_messages_list_empty_not_connected" : MessageLookupByLibrary.simpleMessage("Server not connected to channel on remote IRC server. Try connect again"),
    "chat_messages_list_jump_to_latest_no_messages" : MessageLookupByLibrary.simpleMessage("Jump to latest messages"),
    "chat_messages_list_jump_to_latest_with_new_messages" : m17,
    "chat_messages_list_load_more_action" : MessageLookupByLibrary.simpleMessage("Load more"),
    "chat_messages_list_load_more_not_available" : MessageLookupByLibrary.simpleMessage("More history not available"),
    "chat_messages_list_loading" : MessageLookupByLibrary.simpleMessage("Loading messages..."),
    "chat_network_action_connect" : MessageLookupByLibrary.simpleMessage("Connect"),
    "chat_network_action_disconnect" : MessageLookupByLibrary.simpleMessage("Disconnect"),
    "chat_network_action_edit" : MessageLookupByLibrary.simpleMessage("Edit"),
    "chat_network_action_exit" : MessageLookupByLibrary.simpleMessage("Exit"),
    "chat_network_action_join_channel" : MessageLookupByLibrary.simpleMessage("Join channel"),
    "chat_network_action_list_all_channels" : MessageLookupByLibrary.simpleMessage("List all channels"),
    "chat_network_action_list_ignored_users" : MessageLookupByLibrary.simpleMessage("List ignored users"),
    "chat_network_join_channel_action_join" : MessageLookupByLibrary.simpleMessage("Join"),
    "chat_network_join_channel_field_channel_hint" : MessageLookupByLibrary.simpleMessage("#channel"),
    "chat_network_join_channel_field_channel_label" : MessageLookupByLibrary.simpleMessage("Channel"),
    "chat_network_join_channel_field_password_hint" : MessageLookupByLibrary.simpleMessage("(optional)"),
    "chat_network_join_channel_field_password_label" : MessageLookupByLibrary.simpleMessage("Password"),
    "chat_network_join_channel_title" : MessageLookupByLibrary.simpleMessage("Join channel"),
    "chat_networks_list_empty" : MessageLookupByLibrary.simpleMessage("No networks found"),
    "chat_new_message_attach_action_audio" : MessageLookupByLibrary.simpleMessage("Audio"),
    "chat_new_message_attach_action_camera" : MessageLookupByLibrary.simpleMessage("Camera"),
    "chat_new_message_attach_action_file" : MessageLookupByLibrary.simpleMessage("File"),
    "chat_new_message_attach_action_image" : MessageLookupByLibrary.simpleMessage("Image"),
    "chat_new_message_attach_action_photo" : MessageLookupByLibrary.simpleMessage("Photo"),
    "chat_new_message_attach_action_video" : MessageLookupByLibrary.simpleMessage("Video"),
    "chat_new_message_attach_error_cant_access_file" : MessageLookupByLibrary.simpleMessage("Can\'t access file"),
    "chat_new_message_attach_error_file_size" : m18,
    "chat_new_message_attach_error_http_body" : m19,
    "chat_new_message_attach_error_http_code" : m20,
    "chat_new_message_attach_error_http_timeout" : MessageLookupByLibrary.simpleMessage("Timeout during uploading"),
    "chat_new_message_attach_error_server_auth" : MessageLookupByLibrary.simpleMessage("Server don\'t accept new files"),
    "chat_new_message_attach_error_title" : MessageLookupByLibrary.simpleMessage("Upload error"),
    "chat_new_message_field_enter_message_hint" : MessageLookupByLibrary.simpleMessage("Enter message..."),
    "chat_search_field_filter_hint" : MessageLookupByLibrary.simpleMessage("Text, nickname, or status..."),
    "chat_search_nothing_found" : MessageLookupByLibrary.simpleMessage("Nothing found"),
    "chat_search_title" : m21,
    "chat_settings_title" : MessageLookupByLibrary.simpleMessage("Settings"),
    "chat_state_active_channel_not_selected" : MessageLookupByLibrary.simpleMessage("Active channel not selected"),
    "chat_state_connection_action_reconnect" : MessageLookupByLibrary.simpleMessage("Reconnect"),
    "chat_state_connection_status_connected" : MessageLookupByLibrary.simpleMessage("Connected to server"),
    "chat_state_connection_status_connecting" : MessageLookupByLibrary.simpleMessage("Connecting to server"),
    "chat_state_connection_status_disconnected" : MessageLookupByLibrary.simpleMessage("Not connected to server"),
    "chat_state_init" : MessageLookupByLibrary.simpleMessage("Loading metadata from the server"),
    "chat_title" : MessageLookupByLibrary.simpleMessage("Chat"),
    "chat_user_action_direct_messages" : MessageLookupByLibrary.simpleMessage("Direct Messages"),
    "chat_user_action_information" : MessageLookupByLibrary.simpleMessage("User information"),
    "chat_users_list_loading" : MessageLookupByLibrary.simpleMessage("Loading..."),
    "chat_users_list_search_field_filter_hint" : MessageLookupByLibrary.simpleMessage("Nickname"),
    "chat_users_list_search_field_filter_label" : MessageLookupByLibrary.simpleMessage("Search"),
    "chat_users_list_search_users_not_found" : MessageLookupByLibrary.simpleMessage("Users not found"),
    "chat_users_list_title" : MessageLookupByLibrary.simpleMessage("Users"),
    "dialog_action_cancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "dialog_action_no" : MessageLookupByLibrary.simpleMessage("No"),
    "dialog_action_ok" : MessageLookupByLibrary.simpleMessage("OK"),
    "dialog_action_yes" : MessageLookupByLibrary.simpleMessage("Yes"),
    "dialog_alert_action_ok" : MessageLookupByLibrary.simpleMessage("OK"),
    "dialog_async_action_cancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "dialog_async_title" : MessageLookupByLibrary.simpleMessage("Operation in progress"),
    "dialog_error_content" : m22,
    "dialog_error_title" : MessageLookupByLibrary.simpleMessage("Something wrong"),
    "dialog_progress_action_cancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "dialog_progress_content" : MessageLookupByLibrary.simpleMessage("Loading..."),
    "form_field_text_error_empty_field" : MessageLookupByLibrary.simpleMessage("Field should be not empty"),
    "form_field_text_error_no_whitespace" : MessageLookupByLibrary.simpleMessage("Field should not have whitespaces"),
    "form_field_text_error_not_unique" : MessageLookupByLibrary.simpleMessage("Should be unique"),
    "irc_connection_edit_action_save" : MessageLookupByLibrary.simpleMessage("Save"),
    "irc_connection_edit_title" : MessageLookupByLibrary.simpleMessage("Edit IRC network connection"),
    "irc_connection_new_action_connect" : MessageLookupByLibrary.simpleMessage("Connect"),
    "irc_connection_new_title" : MessageLookupByLibrary.simpleMessage("New IRC network connection"),
    "irc_connection_preferences_field_channels_hint" : MessageLookupByLibrary.simpleMessage("#channel1, #channel2"),
    "irc_connection_preferences_field_channels_label" : MessageLookupByLibrary.simpleMessage("Channels"),
    "irc_connection_preferences_server_field_host_hint" : MessageLookupByLibrary.simpleMessage("chat.freenode.net"),
    "irc_connection_preferences_server_field_host_label" : MessageLookupByLibrary.simpleMessage("Host"),
    "irc_connection_preferences_server_field_name_error_not_unique_name" : MessageLookupByLibrary.simpleMessage("Name already in use"),
    "irc_connection_preferences_server_field_name_hint" : MessageLookupByLibrary.simpleMessage("Freenode"),
    "irc_connection_preferences_server_field_name_label" : MessageLookupByLibrary.simpleMessage("Name"),
    "irc_connection_preferences_server_field_port_hint" : MessageLookupByLibrary.simpleMessage("6697"),
    "irc_connection_preferences_server_field_port_label" : MessageLookupByLibrary.simpleMessage("Port"),
    "irc_connection_preferences_server_field_trusted_only_label" : MessageLookupByLibrary.simpleMessage("Only allow trusted certificates"),
    "irc_connection_preferences_server_field_use_tls_label" : MessageLookupByLibrary.simpleMessage("Use TLS"),
    "irc_connection_preferences_server_title" : MessageLookupByLibrary.simpleMessage("Network preferences"),
    "irc_connection_preferences_user_field_commands_hint" : MessageLookupByLibrary.simpleMessage("One raw command per line, each command will be executed on new login"),
    "irc_connection_preferences_user_field_commands_label" : MessageLookupByLibrary.simpleMessage("Commands"),
    "irc_connection_preferences_user_field_nick_hint" : MessageLookupByLibrary.simpleMessage("AwesomeNick"),
    "irc_connection_preferences_user_field_nick_label" : MessageLookupByLibrary.simpleMessage("Nickname"),
    "irc_connection_preferences_user_field_password_hint" : MessageLookupByLibrary.simpleMessage("(optional)"),
    "irc_connection_preferences_user_field_password_label" : MessageLookupByLibrary.simpleMessage("Password"),
    "irc_connection_preferences_user_field_real_name_hint" : MessageLookupByLibrary.simpleMessage("John Smith"),
    "irc_connection_preferences_user_field_real_name_label" : MessageLookupByLibrary.simpleMessage("Real name"),
    "irc_connection_preferences_user_field_user_name_hint" : MessageLookupByLibrary.simpleMessage("John Smith"),
    "irc_connection_preferences_user_field_user_name_label" : MessageLookupByLibrary.simpleMessage("User name"),
    "irc_connection_preferences_user_title" : MessageLookupByLibrary.simpleMessage("User preferences"),
    "lounge_dialog_connection_error_content_no_exception" : MessageLookupByLibrary.simpleMessage("Can\'t connect to host"),
    "lounge_dialog_connection_error_content_with_exception" : m23,
    "lounge_dialog_connection_error_title" : MessageLookupByLibrary.simpleMessage("Connection error"),
    "lounge_dialog_invalid_response_error_content" : MessageLookupByLibrary.simpleMessage("Correct response not received. Maybe remote server have unsupported Lounge version."),
    "lounge_dialog_invalid_response_error_title" : MessageLookupByLibrary.simpleMessage("Invalid server response"),
    "lounge_dialog_timeout_content" : MessageLookupByLibrary.simpleMessage("Check your network connection"),
    "lounge_dialog_timeout_title" : MessageLookupByLibrary.simpleMessage("Response timeout"),
    "lounge_preferences_action_switch_to_sign_in" : MessageLookupByLibrary.simpleMessage("Switch to Sign In"),
    "lounge_preferences_action_switch_to_sign_up" : MessageLookupByLibrary.simpleMessage("Switch to Sign Up"),
    "lounge_preferences_auth_field_password_hint" : MessageLookupByLibrary.simpleMessage("(required)"),
    "lounge_preferences_auth_field_password_label" : MessageLookupByLibrary.simpleMessage("Password"),
    "lounge_preferences_auth_field_username_hint" : MessageLookupByLibrary.simpleMessage("username"),
    "lounge_preferences_auth_field_username_label" : MessageLookupByLibrary.simpleMessage("Username"),
    "lounge_preferences_auth_title" : MessageLookupByLibrary.simpleMessage("Authentication"),
    "lounge_preferences_edit_dialog_confirm_action_cancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "lounge_preferences_edit_dialog_confirm_action_save_reload" : MessageLookupByLibrary.simpleMessage("Save & Reload"),
    "lounge_preferences_edit_dialog_confirm_content" : MessageLookupByLibrary.simpleMessage("You will be disconnected from current Lounge server and all local history will be cleared"),
    "lounge_preferences_edit_dialog_confirm_title" : MessageLookupByLibrary.simpleMessage("Are you sure?"),
    "lounge_preferences_edit_title" : MessageLookupByLibrary.simpleMessage("Edit lounge connection"),
    "lounge_preferences_host_action_connect" : MessageLookupByLibrary.simpleMessage("Connect"),
    "lounge_preferences_host_field_host_hint" : MessageLookupByLibrary.simpleMessage("https://demo.thelounge.chat"),
    "lounge_preferences_host_field_host_label" : MessageLookupByLibrary.simpleMessage("Host"),
    "lounge_preferences_host_title" : MessageLookupByLibrary.simpleMessage("Connection (The Lounge 4.x or 3.x)"),
    "lounge_preferences_login_action_login" : MessageLookupByLibrary.simpleMessage("Login"),
    "lounge_preferences_login_dialog_login_fail_content" : MessageLookupByLibrary.simpleMessage("Invalid username or password"),
    "lounge_preferences_login_dialog_login_fail_title" : MessageLookupByLibrary.simpleMessage("Auth failed"),
    "lounge_preferences_login_title" : MessageLookupByLibrary.simpleMessage("Sign in"),
    "lounge_preferences_new_title" : MessageLookupByLibrary.simpleMessage("New Lounge connection"),
    "lounge_preferences_registration_action_register" : MessageLookupByLibrary.simpleMessage("Register"),
    "lounge_preferences_registration_dialog_error_already_exist_content" : MessageLookupByLibrary.simpleMessage("User already exist"),
    "lounge_preferences_registration_dialog_error_already_exist_title" : MessageLookupByLibrary.simpleMessage("Sign Up failed"),
    "lounge_preferences_registration_dialog_error_invalid_content" : MessageLookupByLibrary.simpleMessage("Invalid username or password"),
    "lounge_preferences_registration_dialog_error_invalid_title" : MessageLookupByLibrary.simpleMessage("Sign Up failed"),
    "lounge_preferences_registration_dialog_error_unknown_content" : MessageLookupByLibrary.simpleMessage("Unknown error"),
    "lounge_preferences_registration_dialog_error_unknown_title" : MessageLookupByLibrary.simpleMessage("Sign Up failed"),
    "lounge_preferences_registration_dialog_success_content" : MessageLookupByLibrary.simpleMessage("You can sign in now"),
    "lounge_preferences_registration_dialog_success_title" : MessageLookupByLibrary.simpleMessage("Success Sign Up"),
    "lounge_preferences_registration_title" : MessageLookupByLibrary.simpleMessage("Sign up"),
    "lounge_preferences_title" : MessageLookupByLibrary.simpleMessage("Lounge preferences")
  };
}
