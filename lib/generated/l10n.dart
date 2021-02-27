// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Failed to start app.\nTry restart or re-install app.`
  String get app_init_fail {
    return Intl.message(
      'Failed to start app.\nTry restart or re-install app.',
      name: 'app_init_fail',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get dialog_progress_content {
    return Intl.message(
      'Loading...',
      name: 'dialog_progress_content',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get dialog_progress_action_cancel {
    return Intl.message(
      'Cancel',
      name: 'dialog_progress_action_cancel',
      desc: '',
      args: [],
    );
  }

  /// `AppIRC`
  String get app_name {
    return Intl.message(
      'AppIRC',
      name: 'app_name',
      desc: '',
      args: [],
    );
  }

  /// `Field should be not empty`
  String get form_field_text_error_empty_field {
    return Intl.message(
      'Field should be not empty',
      name: 'form_field_text_error_empty_field',
      desc: '',
      args: [],
    );
  }

  /// `Field should not have whitespaces`
  String get form_field_text_error_no_whitespace {
    return Intl.message(
      'Field should not have whitespaces',
      name: 'form_field_text_error_no_whitespace',
      desc: '',
      args: [],
    );
  }

  /// `Should be unique`
  String get form_field_text_error_not_unique {
    return Intl.message(
      'Should be unique',
      name: 'form_field_text_error_not_unique',
      desc: '',
      args: [],
    );
  }

  /// `Operation in progress`
  String get dialog_async_title {
    return Intl.message(
      'Operation in progress',
      name: 'dialog_async_title',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get dialog_async_action_cancel {
    return Intl.message(
      'Cancel',
      name: 'dialog_async_action_cancel',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get dialog_alert_action_ok {
    return Intl.message(
      'OK',
      name: 'dialog_alert_action_ok',
      desc: '',
      args: [],
    );
  }

  /// `Something wrong`
  String get dialog_error_title {
    return Intl.message(
      'Something wrong',
      name: 'dialog_error_title',
      desc: '',
      args: [],
    );
  }

  /// `An error has occurred. \n{errorMessage}`
  String dialog_error_content(Object errorMessage) {
    return Intl.message(
      'An error has occurred. \n$errorMessage',
      name: 'dialog_error_content',
      desc: '',
      args: [errorMessage],
    );
  }

  /// `Yes`
  String get dialog_action_yes {
    return Intl.message(
      'Yes',
      name: 'dialog_action_yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get dialog_action_no {
    return Intl.message(
      'No',
      name: 'dialog_action_no',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get dialog_action_ok {
    return Intl.message(
      'OK',
      name: 'dialog_action_ok',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get dialog_action_cancel {
    return Intl.message(
      'Cancel',
      name: 'dialog_action_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Response timeout`
  String get lounge_dialog_timeout_title {
    return Intl.message(
      'Response timeout',
      name: 'lounge_dialog_timeout_title',
      desc: '',
      args: [],
    );
  }

  /// `Check your network connection`
  String get lounge_dialog_timeout_content {
    return Intl.message(
      'Check your network connection',
      name: 'lounge_dialog_timeout_content',
      desc: '',
      args: [],
    );
  }

  /// `Connection error`
  String get lounge_dialog_connection_error_title {
    return Intl.message(
      'Connection error',
      name: 'lounge_dialog_connection_error_title',
      desc: '',
      args: [],
    );
  }

  /// `Can't connect to host`
  String get lounge_dialog_connection_error_content_no_exception {
    return Intl.message(
      'Can\'t connect to host',
      name: 'lounge_dialog_connection_error_content_no_exception',
      desc: '',
      args: [],
    );
  }

  /// `Can't connect to host. Error: {error}`
  String lounge_dialog_connection_error_content_with_exception(Object error) {
    return Intl.message(
      'Can\'t connect to host. Error: $error',
      name: 'lounge_dialog_connection_error_content_with_exception',
      desc: '',
      args: [error],
    );
  }

  /// `Invalid server response`
  String get lounge_dialog_invalid_response_error_title {
    return Intl.message(
      'Invalid server response',
      name: 'lounge_dialog_invalid_response_error_title',
      desc: '',
      args: [],
    );
  }

  /// `Correct response not received. Maybe remote server have unsupported Lounge version.`
  String get lounge_dialog_invalid_response_error_content {
    return Intl.message(
      'Correct response not received. Maybe remote server have unsupported Lounge version.',
      name: 'lounge_dialog_invalid_response_error_content',
      desc: '',
      args: [],
    );
  }

  /// `Lounge preferences`
  String get lounge_preferences_title {
    return Intl.message(
      'Lounge preferences',
      name: 'lounge_preferences_title',
      desc: '',
      args: [],
    );
  }

  /// `Connection`
  String get lounge_preferences_host_title {
    return Intl.message(
      'Connection',
      name: 'lounge_preferences_host_title',
      desc: '',
      args: [],
    );
  }

  /// `Host`
  String get lounge_preferences_host_field_host_label {
    return Intl.message(
      'Host',
      name: 'lounge_preferences_host_field_host_label',
      desc: '',
      args: [],
    );
  }

  /// `https://demo.thelounge.chat`
  String get lounge_preferences_host_field_host_hint {
    return Intl.message(
      'https://demo.thelounge.chat',
      name: 'lounge_preferences_host_field_host_hint',
      desc: '',
      args: [],
    );
  }

  /// `Connect`
  String get lounge_preferences_host_action_connect {
    return Intl.message(
      'Connect',
      name: 'lounge_preferences_host_action_connect',
      desc: '',
      args: [],
    );
  }

  /// `Authentication`
  String get lounge_preferences_auth_title {
    return Intl.message(
      'Authentication',
      name: 'lounge_preferences_auth_title',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get lounge_preferences_auth_field_username_label {
    return Intl.message(
      'Username',
      name: 'lounge_preferences_auth_field_username_label',
      desc: '',
      args: [],
    );
  }

  /// `username`
  String get lounge_preferences_auth_field_username_hint {
    return Intl.message(
      'username',
      name: 'lounge_preferences_auth_field_username_hint',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get lounge_preferences_auth_field_password_label {
    return Intl.message(
      'Password',
      name: 'lounge_preferences_auth_field_password_label',
      desc: '',
      args: [],
    );
  }

  /// `(required)`
  String get lounge_preferences_auth_field_password_hint {
    return Intl.message(
      '(required)',
      name: 'lounge_preferences_auth_field_password_hint',
      desc: '',
      args: [],
    );
  }

  /// `Switch to Sign In`
  String get lounge_preferences_action_switch_to_sign_in {
    return Intl.message(
      'Switch to Sign In',
      name: 'lounge_preferences_action_switch_to_sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Switch to Sign Up`
  String get lounge_preferences_action_switch_to_sign_up {
    return Intl.message(
      'Switch to Sign Up',
      name: 'lounge_preferences_action_switch_to_sign_up',
      desc: '',
      args: [],
    );
  }

  /// `Sign in`
  String get lounge_preferences_login_title {
    return Intl.message(
      'Sign in',
      name: 'lounge_preferences_login_title',
      desc: '',
      args: [],
    );
  }

  /// `Auth failed`
  String get lounge_preferences_login_dialog_login_fail_title {
    return Intl.message(
      'Auth failed',
      name: 'lounge_preferences_login_dialog_login_fail_title',
      desc: '',
      args: [],
    );
  }

  /// `Invalid username or password`
  String get lounge_preferences_login_dialog_login_fail_content {
    return Intl.message(
      'Invalid username or password',
      name: 'lounge_preferences_login_dialog_login_fail_content',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get lounge_preferences_login_action_login {
    return Intl.message(
      'Login',
      name: 'lounge_preferences_login_action_login',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get lounge_preferences_registration_title {
    return Intl.message(
      'Sign up',
      name: 'lounge_preferences_registration_title',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up failed`
  String get lounge_preferences_registration_dialog_error_invalid_title {
    return Intl.message(
      'Sign Up failed',
      name: 'lounge_preferences_registration_dialog_error_invalid_title',
      desc: '',
      args: [],
    );
  }

  /// `Invalid username or password`
  String get lounge_preferences_registration_dialog_error_invalid_content {
    return Intl.message(
      'Invalid username or password',
      name: 'lounge_preferences_registration_dialog_error_invalid_content',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up failed`
  String get lounge_preferences_registration_dialog_error_already_exist_title {
    return Intl.message(
      'Sign Up failed',
      name: 'lounge_preferences_registration_dialog_error_already_exist_title',
      desc: '',
      args: [],
    );
  }

  /// `User already exist`
  String get lounge_preferences_registration_dialog_error_already_exist_content {
    return Intl.message(
      'User already exist',
      name: 'lounge_preferences_registration_dialog_error_already_exist_content',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up failed`
  String get lounge_preferences_registration_dialog_error_unknown_title {
    return Intl.message(
      'Sign Up failed',
      name: 'lounge_preferences_registration_dialog_error_unknown_title',
      desc: '',
      args: [],
    );
  }

  /// `Unknown error`
  String get lounge_preferences_registration_dialog_error_unknown_content {
    return Intl.message(
      'Unknown error',
      name: 'lounge_preferences_registration_dialog_error_unknown_content',
      desc: '',
      args: [],
    );
  }

  /// `Success Sign Up`
  String get lounge_preferences_registration_dialog_success_title {
    return Intl.message(
      'Success Sign Up',
      name: 'lounge_preferences_registration_dialog_success_title',
      desc: '',
      args: [],
    );
  }

  /// `You can sign in now`
  String get lounge_preferences_registration_dialog_success_content {
    return Intl.message(
      'You can sign in now',
      name: 'lounge_preferences_registration_dialog_success_content',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get lounge_preferences_registration_action_register {
    return Intl.message(
      'Register',
      name: 'lounge_preferences_registration_action_register',
      desc: '',
      args: [],
    );
  }

  /// `New Lounge connection`
  String get lounge_preferences_new_title {
    return Intl.message(
      'New Lounge connection',
      name: 'lounge_preferences_new_title',
      desc: '',
      args: [],
    );
  }

  /// `Edit lounge connection`
  String get lounge_preferences_edit_title {
    return Intl.message(
      'Edit lounge connection',
      name: 'lounge_preferences_edit_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure?`
  String get lounge_preferences_edit_dialog_confirm_title {
    return Intl.message(
      'Are you sure?',
      name: 'lounge_preferences_edit_dialog_confirm_title',
      desc: '',
      args: [],
    );
  }

  /// `You will be disconnected from current Lounge server and all local history will be cleared`
  String get lounge_preferences_edit_dialog_confirm_content {
    return Intl.message(
      'You will be disconnected from current Lounge server and all local history will be cleared',
      name: 'lounge_preferences_edit_dialog_confirm_content',
      desc: '',
      args: [],
    );
  }

  /// `Save & Reload`
  String get lounge_preferences_edit_dialog_confirm_action_save_reload {
    return Intl.message(
      'Save & Reload',
      name: 'lounge_preferences_edit_dialog_confirm_action_save_reload',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get lounge_preferences_edit_dialog_confirm_action_cancel {
    return Intl.message(
      'Cancel',
      name: 'lounge_preferences_edit_dialog_confirm_action_cancel',
      desc: '',
      args: [],
    );
  }

  /// `New IRC network connection`
  String get irc_connection_new_title {
    return Intl.message(
      'New IRC network connection',
      name: 'irc_connection_new_title',
      desc: '',
      args: [],
    );
  }

  /// `Connect`
  String get irc_connection_new_action_connect {
    return Intl.message(
      'Connect',
      name: 'irc_connection_new_action_connect',
      desc: '',
      args: [],
    );
  }

  /// `Edit IRC network connection`
  String get irc_connection_edit_title {
    return Intl.message(
      'Edit IRC network connection',
      name: 'irc_connection_edit_title',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get irc_connection_edit_action_save {
    return Intl.message(
      'Save',
      name: 'irc_connection_edit_action_save',
      desc: '',
      args: [],
    );
  }

  /// `Network preferences`
  String get irc_connection_preferences_server_title {
    return Intl.message(
      'Network preferences',
      name: 'irc_connection_preferences_server_title',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get irc_connection_preferences_server_field_name_label {
    return Intl.message(
      'Name',
      name: 'irc_connection_preferences_server_field_name_label',
      desc: '',
      args: [],
    );
  }

  /// `Freenode`
  String get irc_connection_preferences_server_field_name_hint {
    return Intl.message(
      'Freenode',
      name: 'irc_connection_preferences_server_field_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Name already in use`
  String get irc_connection_preferences_server_field_name_error_not_unique_name {
    return Intl.message(
      'Name already in use',
      name: 'irc_connection_preferences_server_field_name_error_not_unique_name',
      desc: '',
      args: [],
    );
  }

  /// `Host`
  String get irc_connection_preferences_server_field_host_label {
    return Intl.message(
      'Host',
      name: 'irc_connection_preferences_server_field_host_label',
      desc: '',
      args: [],
    );
  }

  /// `chat.freenode.net`
  String get irc_connection_preferences_server_field_host_hint {
    return Intl.message(
      'chat.freenode.net',
      name: 'irc_connection_preferences_server_field_host_hint',
      desc: '',
      args: [],
    );
  }

  /// `Port`
  String get irc_connection_preferences_server_field_port_label {
    return Intl.message(
      'Port',
      name: 'irc_connection_preferences_server_field_port_label',
      desc: '',
      args: [],
    );
  }

  /// `6697`
  String get irc_connection_preferences_server_field_port_hint {
    return Intl.message(
      '6697',
      name: 'irc_connection_preferences_server_field_port_hint',
      desc: '',
      args: [],
    );
  }

  /// `Use TLS`
  String get irc_connection_preferences_server_field_use_tls_label {
    return Intl.message(
      'Use TLS',
      name: 'irc_connection_preferences_server_field_use_tls_label',
      desc: '',
      args: [],
    );
  }

  /// `Only allow trusted certificates`
  String get irc_connection_preferences_server_field_trusted_only_label {
    return Intl.message(
      'Only allow trusted certificates',
      name: 'irc_connection_preferences_server_field_trusted_only_label',
      desc: '',
      args: [],
    );
  }

  /// `User preferences`
  String get irc_connection_preferences_user_title {
    return Intl.message(
      'User preferences',
      name: 'irc_connection_preferences_user_title',
      desc: '',
      args: [],
    );
  }

  /// `Nickname`
  String get irc_connection_preferences_user_field_nick_label {
    return Intl.message(
      'Nickname',
      name: 'irc_connection_preferences_user_field_nick_label',
      desc: '',
      args: [],
    );
  }

  /// `AwesomeNick`
  String get irc_connection_preferences_user_field_nick_hint {
    return Intl.message(
      'AwesomeNick',
      name: 'irc_connection_preferences_user_field_nick_hint',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get irc_connection_preferences_user_field_password_label {
    return Intl.message(
      'Password',
      name: 'irc_connection_preferences_user_field_password_label',
      desc: '',
      args: [],
    );
  }

  /// `(optional)`
  String get irc_connection_preferences_user_field_password_hint {
    return Intl.message(
      '(optional)',
      name: 'irc_connection_preferences_user_field_password_hint',
      desc: '',
      args: [],
    );
  }

  /// `Real name`
  String get irc_connection_preferences_user_field_real_name_label {
    return Intl.message(
      'Real name',
      name: 'irc_connection_preferences_user_field_real_name_label',
      desc: '',
      args: [],
    );
  }

  /// `John Smith`
  String get irc_connection_preferences_user_field_real_name_hint {
    return Intl.message(
      'John Smith',
      name: 'irc_connection_preferences_user_field_real_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `User name`
  String get irc_connection_preferences_user_field_user_name_label {
    return Intl.message(
      'User name',
      name: 'irc_connection_preferences_user_field_user_name_label',
      desc: '',
      args: [],
    );
  }

  /// `John Smith`
  String get irc_connection_preferences_user_field_user_name_hint {
    return Intl.message(
      'John Smith',
      name: 'irc_connection_preferences_user_field_user_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Commands`
  String get irc_connection_preferences_user_field_commands_label {
    return Intl.message(
      'Commands',
      name: 'irc_connection_preferences_user_field_commands_label',
      desc: '',
      args: [],
    );
  }

  /// `One raw command per line, each command will be executed on new login`
  String get irc_connection_preferences_user_field_commands_hint {
    return Intl.message(
      'One raw command per line, each command will be executed on new login',
      name: 'irc_connection_preferences_user_field_commands_hint',
      desc: '',
      args: [],
    );
  }

  /// `Channels`
  String get irc_connection_preferences_field_channels_label {
    return Intl.message(
      'Channels',
      name: 'irc_connection_preferences_field_channels_label',
      desc: '',
      args: [],
    );
  }

  /// `#channel1, #channel2`
  String get irc_connection_preferences_field_channels_hint {
    return Intl.message(
      '#channel1, #channel2',
      name: 'irc_connection_preferences_field_channels_hint',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chat_title {
    return Intl.message(
      'Chat',
      name: 'chat_title',
      desc: '',
      args: [],
    );
  }

  /// `Search in {channel}`
  String chat_search_title(Object channel) {
    return Intl.message(
      'Search in $channel',
      name: 'chat_search_title',
      desc: '',
      args: [channel],
    );
  }

  /// `Text, nickname, or status...`
  String get chat_search_field_filter_hint {
    return Intl.message(
      'Text, nickname, or status...',
      name: 'chat_search_field_filter_hint',
      desc: '',
      args: [],
    );
  }

  /// `Nothing found`
  String get chat_search_nothing_found {
    return Intl.message(
      'Nothing found',
      name: 'chat_search_nothing_found',
      desc: '',
      args: [],
    );
  }

  /// `Connected to server`
  String get chat_state_connection_status_connected {
    return Intl.message(
      'Connected to server',
      name: 'chat_state_connection_status_connected',
      desc: '',
      args: [],
    );
  }

  /// `Connecting to server`
  String get chat_state_connection_status_connecting {
    return Intl.message(
      'Connecting to server',
      name: 'chat_state_connection_status_connecting',
      desc: '',
      args: [],
    );
  }

  /// `Not connected to server`
  String get chat_state_connection_status_disconnected {
    return Intl.message(
      'Not connected to server',
      name: 'chat_state_connection_status_disconnected',
      desc: '',
      args: [],
    );
  }

  /// `Reconnect`
  String get chat_state_connection_action_reconnect {
    return Intl.message(
      'Reconnect',
      name: 'chat_state_connection_action_reconnect',
      desc: '',
      args: [],
    );
  }

  /// `Active channel not selected`
  String get chat_state_active_channel_not_selected {
    return Intl.message(
      'Active channel not selected',
      name: 'chat_state_active_channel_not_selected',
      desc: '',
      args: [],
    );
  }

  /// `Loading metadata from the server`
  String get chat_state_init {
    return Intl.message(
      'Loading metadata from the server',
      name: 'chat_state_init',
      desc: '',
      args: [],
    );
  }

  /// `Join channel`
  String get chat_network_join_channel_title {
    return Intl.message(
      'Join channel',
      name: 'chat_network_join_channel_title',
      desc: '',
      args: [],
    );
  }

  /// `Channel`
  String get chat_network_join_channel_field_channel_label {
    return Intl.message(
      'Channel',
      name: 'chat_network_join_channel_field_channel_label',
      desc: '',
      args: [],
    );
  }

  /// `#channel`
  String get chat_network_join_channel_field_channel_hint {
    return Intl.message(
      '#channel',
      name: 'chat_network_join_channel_field_channel_hint',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get chat_network_join_channel_field_password_label {
    return Intl.message(
      'Password',
      name: 'chat_network_join_channel_field_password_label',
      desc: '',
      args: [],
    );
  }

  /// `(optional)`
  String get chat_network_join_channel_field_password_hint {
    return Intl.message(
      '(optional)',
      name: 'chat_network_join_channel_field_password_hint',
      desc: '',
      args: [],
    );
  }

  /// `Join`
  String get chat_network_join_channel_action_join {
    return Intl.message(
      'Join',
      name: 'chat_network_join_channel_action_join',
      desc: '',
      args: [],
    );
  }

  /// `Join channel`
  String get chat_network_action_join_channel {
    return Intl.message(
      'Join channel',
      name: 'chat_network_action_join_channel',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get chat_network_action_edit {
    return Intl.message(
      'Edit',
      name: 'chat_network_action_edit',
      desc: '',
      args: [],
    );
  }

  /// `List all channels`
  String get chat_network_action_list_all_channels {
    return Intl.message(
      'List all channels',
      name: 'chat_network_action_list_all_channels',
      desc: '',
      args: [],
    );
  }

  /// `List ignored users`
  String get chat_network_action_list_ignored_users {
    return Intl.message(
      'List ignored users',
      name: 'chat_network_action_list_ignored_users',
      desc: '',
      args: [],
    );
  }

  /// `Disconnect`
  String get chat_network_action_disconnect {
    return Intl.message(
      'Disconnect',
      name: 'chat_network_action_disconnect',
      desc: '',
      args: [],
    );
  }

  /// `Connect`
  String get chat_network_action_connect {
    return Intl.message(
      'Connect',
      name: 'chat_network_action_connect',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get chat_network_action_exit {
    return Intl.message(
      'Exit',
      name: 'chat_network_action_exit',
      desc: '',
      args: [],
    );
  }

  /// `No networks found`
  String get chat_networks_list_empty {
    return Intl.message(
      'No networks found',
      name: 'chat_networks_list_empty',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get chat_settings_title {
    return Intl.message(
      'Settings',
      name: 'chat_settings_title',
      desc: '',
      args: [],
    );
  }

  /// `{topic}:`
  String chat_channel_topic_dialog_title(Object topic) {
    return Intl.message(
      '$topic:',
      name: 'chat_channel_topic_dialog_title',
      desc: '',
      args: [topic],
    );
  }

  /// `Topic`
  String get chat_channel_topic_dialog_field_edit_label {
    return Intl.message(
      'Topic',
      name: 'chat_channel_topic_dialog_field_edit_label',
      desc: '',
      args: [],
    );
  }

  /// `Hey there!`
  String get chat_channel_topic_dialog_field_edit_hint {
    return Intl.message(
      'Hey there!',
      name: 'chat_channel_topic_dialog_field_edit_hint',
      desc: '',
      args: [],
    );
  }

  /// `Change`
  String get chat_channel_topic_dialog_action_change {
    return Intl.message(
      'Change',
      name: 'chat_channel_topic_dialog_action_change',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get chat_channel_topic_dialog_action_cancel {
    return Intl.message(
      'Cancel',
      name: 'chat_channel_topic_dialog_action_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Leave`
  String get chat_channel_action_leave {
    return Intl.message(
      'Leave',
      name: 'chat_channel_action_leave',
      desc: '',
      args: [],
    );
  }

  /// `Users`
  String get chat_channel_action_users {
    return Intl.message(
      'Users',
      name: 'chat_channel_action_users',
      desc: '',
      args: [],
    );
  }

  /// `List banned users`
  String get chat_channel_action_list_banned {
    return Intl.message(
      'List banned users',
      name: 'chat_channel_action_list_banned',
      desc: '',
      args: [],
    );
  }

  /// `Topic`
  String get chat_channel_action_topic {
    return Intl.message(
      'Topic',
      name: 'chat_channel_action_topic',
      desc: '',
      args: [],
    );
  }

  /// `User information`
  String get chat_channel_action_user_information {
    return Intl.message(
      'User information',
      name: 'chat_channel_action_user_information',
      desc: '',
      args: [],
    );
  }

  /// `Load more`
  String get chat_messages_list_load_more_action {
    return Intl.message(
      'Load more',
      name: 'chat_messages_list_load_more_action',
      desc: '',
      args: [],
    );
  }

  /// `More history not available`
  String get chat_messages_list_load_more_not_available {
    return Intl.message(
      'More history not available',
      name: 'chat_messages_list_load_more_not_available',
      desc: '',
      args: [],
    );
  }

  /// `This channel doesn't have any messages yet`
  String get chat_messages_list_empty_connected {
    return Intl.message(
      'This channel doesn\'t have any messages yet',
      name: 'chat_messages_list_empty_connected',
      desc: '',
      args: [],
    );
  }

  /// `Server not connected to channel on remote IRC server. Try connect again`
  String get chat_messages_list_empty_not_connected {
    return Intl.message(
      'Server not connected to channel on remote IRC server. Try connect again',
      name: 'chat_messages_list_empty_not_connected',
      desc: '',
      args: [],
    );
  }

  /// `Jump to latest messages ({count} new)`
  String chat_messages_list_jump_to_latest_with_new_messages(Object count) {
    return Intl.message(
      'Jump to latest messages ($count new)',
      name: 'chat_messages_list_jump_to_latest_with_new_messages',
      desc: '',
      args: [count],
    );
  }

  /// `Jump to latest messages`
  String get chat_messages_list_jump_to_latest_no_messages {
    return Intl.message(
      'Jump to latest messages',
      name: 'chat_messages_list_jump_to_latest_no_messages',
      desc: '',
      args: [],
    );
  }

  /// `Loading messages...`
  String get chat_messages_list_loading {
    return Intl.message(
      'Loading messages...',
      name: 'chat_messages_list_loading',
      desc: '',
      args: [],
    );
  }

  /// `Message`
  String get chat_message_title_simple {
    return Intl.message(
      'Message',
      name: 'chat_message_title_simple',
      desc: '',
      args: [],
    );
  }

  /// `Message from {user}`
  String chat_message_title_from(Object user) {
    return Intl.message(
      'Message from $user',
      name: 'chat_message_title_from',
      desc: '',
      args: [user],
    );
  }

  /// `Copy text body`
  String get chat_message_action_copy {
    return Intl.message(
      'Copy text body',
      name: 'chat_message_action_copy',
      desc: '',
      args: [],
    );
  }

  /// `, `
  String get chat_message_condensed_join_separator {
    return Intl.message(
      ', ',
      name: 'chat_message_condensed_join_separator',
      desc: '',
      args: [],
    );
  }

  /// `{users} users`
  String chat_message_special_channels_list_users(Object users) {
    return Intl.message(
      '$users users',
      name: 'chat_message_special_channels_list_users',
      desc: '',
      args: [users],
    );
  }

  /// `Hostmask:`
  String get chat_message_special_who_is_hostmask {
    return Intl.message(
      'Hostmask:',
      name: 'chat_message_special_who_is_hostmask',
      desc: '',
      args: [],
    );
  }

  /// `Actual hostname:`
  String get chat_message_special_who_is_actual_hostname {
    return Intl.message(
      'Actual hostname:',
      name: 'chat_message_special_who_is_actual_hostname',
      desc: '',
      args: [],
    );
  }

  /// `Real Name:`
  String get chat_message_special_who_is_real_name {
    return Intl.message(
      'Real Name:',
      name: 'chat_message_special_who_is_real_name',
      desc: '',
      args: [],
    );
  }

  /// `Channels:`
  String get chat_message_special_who_is_channels {
    return Intl.message(
      'Channels:',
      name: 'chat_message_special_who_is_channels',
      desc: '',
      args: [],
    );
  }

  /// `Secure connection:`
  String get chat_message_special_who_is_secure_connection {
    return Intl.message(
      'Secure connection:',
      name: 'chat_message_special_who_is_secure_connection',
      desc: '',
      args: [],
    );
  }

  /// `Account:`
  String get chat_message_special_who_is_account {
    return Intl.message(
      'Account:',
      name: 'chat_message_special_who_is_account',
      desc: '',
      args: [],
    );
  }

  /// `Connected at:`
  String get chat_message_special_who_is_connected_at {
    return Intl.message(
      'Connected at:',
      name: 'chat_message_special_who_is_connected_at',
      desc: '',
      args: [],
    );
  }

  /// `Connected to:`
  String get chat_message_special_who_is_connected_to {
    return Intl.message(
      'Connected to:',
      name: 'chat_message_special_who_is_connected_to',
      desc: '',
      args: [],
    );
  }

  /// `Idle since:`
  String get chat_message_special_who_is_idle_since {
    return Intl.message(
      'Idle since:',
      name: 'chat_message_special_who_is_idle_since',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{1 user has gone away} other{{count} users has gone away}}`
  String chat_message_regular_condensed_away(num count) {
    return Intl.plural(
      count,
      one: '1 user has gone away',
      other: '$count users has gone away',
      name: 'chat_message_regular_condensed_away',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 user has come back} other{{count} users has come back}}`
  String chat_message_regular_condensed_back(num count) {
    return Intl.plural(
      count,
      one: '1 user has come back',
      other: '$count users has come back',
      name: 'chat_message_regular_condensed_back',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 user has changed hostname} other{{count} users has changed hostname}}`
  String chat_message_regular_condensed_chghost(num count) {
    return Intl.plural(
      count,
      one: '1 user has changed hostname',
      other: '$count users has changed hostname',
      name: 'chat_message_regular_condensed_chghost',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 user has joined} other{{count} users has joined}}`
  String chat_message_regular_condensed_join(num count) {
    return Intl.plural(
      count,
      one: '1 user has joined',
      other: '$count users has joined',
      name: 'chat_message_regular_condensed_join',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 user has left} other{{count} users has left}}`
  String chat_message_regular_condensed_part(num count) {
    return Intl.plural(
      count,
      one: '1 user has left',
      other: '$count users has left',
      name: 'chat_message_regular_condensed_part',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 user was quit} other{{count} users was quit}}`
  String chat_message_regular_condensed_quit(num count) {
    return Intl.plural(
      count,
      one: '1 user was quit',
      other: '$count users was quit',
      name: 'chat_message_regular_condensed_quit',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 user has changed nick} other{{count} users has changed nick}}`
  String chat_message_regular_condensed_nick(num count) {
    return Intl.plural(
      count,
      one: '1 user has changed nick',
      other: '$count users has changed nick',
      name: 'chat_message_regular_condensed_nick',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 user was kicked} other{{count} users were kicked}}`
  String chat_message_regular_condensed_kick(num count) {
    return Intl.plural(
      count,
      one: '1 user was kicked',
      other: '$count users were kicked',
      name: 'chat_message_regular_condensed_kick',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 mode was set} other{{count} modes was set}}`
  String chat_message_regular_condensed_mode(num count) {
    return Intl.plural(
      count,
      one: '1 mode was set',
      other: '$count modes was set',
      name: 'chat_message_regular_condensed_mode',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 channel mode was set} other{{count} channel mode were set}}`
  String chat_message_regular_condensed_mode_channel(num count) {
    return Intl.plural(
      count,
      one: '1 channel mode was set',
      other: '$count channel mode were set',
      name: 'chat_message_regular_condensed_mode_channel',
      desc: '',
      args: [count],
    );
  }

  /// `mode {shortMessage}`
  String chat_message_regular_sub_message_mode_short(Object shortMessage) {
    return Intl.message(
      'mode $shortMessage',
      name: 'chat_message_regular_sub_message_mode_short',
      desc: '',
      args: [shortMessage],
    );
  }

  /// `mode`
  String get chat_message_regular_sub_message_mode_long {
    return Intl.message(
      'mode',
      name: 'chat_message_regular_sub_message_mode_long',
      desc: '',
      args: [],
    );
  }

  /// `notice`
  String get chat_message_regular_sub_message_notice {
    return Intl.message(
      'notice',
      name: 'chat_message_regular_sub_message_notice',
      desc: '',
      args: [],
    );
  }

  /// `joined`
  String get chat_message_regular_sub_message_join {
    return Intl.message(
      'joined',
      name: 'chat_message_regular_sub_message_join',
      desc: '',
      args: [],
    );
  }

  /// `motd: {shortMessage}`
  String chat_message_regular_sub_message_motd(Object shortMessage) {
    return Intl.message(
      'motd: $shortMessage',
      name: 'chat_message_regular_sub_message_motd',
      desc: '',
      args: [shortMessage],
    );
  }

  /// `(who is)`
  String get chat_message_regular_sub_message_who_is {
    return Intl.message(
      '(who is)',
      name: 'chat_message_regular_sub_message_who_is',
      desc: '',
      args: [],
    );
  }

  /// `away`
  String get chat_message_regular_sub_message_away {
    return Intl.message(
      'away',
      name: 'chat_message_regular_sub_message_away',
      desc: '',
      args: [],
    );
  }

  /// `back`
  String get chat_message_regular_sub_message_back {
    return Intl.message(
      'back',
      name: 'chat_message_regular_sub_message_back',
      desc: '',
      args: [],
    );
  }

  /// `error`
  String get chat_message_regular_sub_message_error {
    return Intl.message(
      'error',
      name: 'chat_message_regular_sub_message_error',
      desc: '',
      args: [],
    );
  }

  /// `set topic`
  String get chat_message_regular_sub_message_topic_set_by {
    return Intl.message(
      'set topic',
      name: 'chat_message_regular_sub_message_topic_set_by',
      desc: '',
      args: [],
    );
  }

  /// `Topic`
  String get chat_message_regular_sub_message_topic {
    return Intl.message(
      'Topic',
      name: 'chat_message_regular_sub_message_topic',
      desc: '',
      args: [],
    );
  }

  /// `unknown`
  String get chat_message_regular_sub_message_unknown {
    return Intl.message(
      'unknown',
      name: 'chat_message_regular_sub_message_unknown',
      desc: '',
      args: [],
    );
  }

  /// `quit`
  String get chat_message_regular_sub_message_quit {
    return Intl.message(
      'quit',
      name: 'chat_message_regular_sub_message_quit',
      desc: '',
      args: [],
    );
  }

  /// `part`
  String get chat_message_regular_sub_message_part {
    return Intl.message(
      'part',
      name: 'chat_message_regular_sub_message_part',
      desc: '',
      args: [],
    );
  }

  /// `change nick to {newNick}`
  String chat_message_regular_sub_message_nick(Object newNick) {
    return Intl.message(
      'change nick to $newNick',
      name: 'chat_message_regular_sub_message_nick',
      desc: '',
      args: [newNick],
    );
  }

  /// `Channel mode: {shortMessage}`
  String chat_message_regular_sub_message_channel_mode(Object shortMessage) {
    return Intl.message(
      'Channel mode: $shortMessage',
      name: 'chat_message_regular_sub_message_channel_mode',
      desc: '',
      args: [shortMessage],
    );
  }

  /// `CTCP request`
  String get chat_message_regular_sub_message_ctcp_request {
    return Intl.message(
      'CTCP request',
      name: 'chat_message_regular_sub_message_ctcp_request',
      desc: '',
      args: [],
    );
  }

  /// `changed host`
  String get chat_message_regular_sub_message_chghost {
    return Intl.message(
      'changed host',
      name: 'chat_message_regular_sub_message_chghost',
      desc: '',
      args: [],
    );
  }

  /// `kick`
  String get chat_message_regular_sub_message_kick {
    return Intl.message(
      'kick',
      name: 'chat_message_regular_sub_message_kick',
      desc: '',
      args: [],
    );
  }

  /// `invite`
  String get chat_message_regular_sub_message_invite {
    return Intl.message(
      'invite',
      name: 'chat_message_regular_sub_message_invite',
      desc: '',
      args: [],
    );
  }

  /// `CTCP`
  String get chat_message_regular_sub_message_ctcp {
    return Intl.message(
      'CTCP',
      name: 'chat_message_regular_sub_message_ctcp',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get chat_message_preview_title {
    return Intl.message(
      'Preview',
      name: 'chat_message_preview_title',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get chat_message_preview_loading {
    return Intl.message(
      'Loading...',
      name: 'chat_message_preview_loading',
      desc: '',
      args: [],
    );
  }

  /// `Server failed to fetch preview metadata`
  String get chat_message_preview_error_server {
    return Intl.message(
      'Server failed to fetch preview metadata',
      name: 'chat_message_preview_error_server',
      desc: '',
      args: [],
    );
  }

  /// `Enter message...`
  String get chat_new_message_field_enter_message_hint {
    return Intl.message(
      'Enter message...',
      name: 'chat_new_message_field_enter_message_hint',
      desc: '',
      args: [],
    );
  }

  /// `File`
  String get chat_new_message_attach_action_file {
    return Intl.message(
      'File',
      name: 'chat_new_message_attach_action_file',
      desc: '',
      args: [],
    );
  }

  /// `Audio`
  String get chat_new_message_attach_action_audio {
    return Intl.message(
      'Audio',
      name: 'chat_new_message_attach_action_audio',
      desc: '',
      args: [],
    );
  }

  /// `Video`
  String get chat_new_message_attach_action_video {
    return Intl.message(
      'Video',
      name: 'chat_new_message_attach_action_video',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get chat_new_message_attach_action_camera {
    return Intl.message(
      'Camera',
      name: 'chat_new_message_attach_action_camera',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get chat_new_message_attach_action_image {
    return Intl.message(
      'Image',
      name: 'chat_new_message_attach_action_image',
      desc: '',
      args: [],
    );
  }

  /// `Photo`
  String get chat_new_message_attach_action_photo {
    return Intl.message(
      'Photo',
      name: 'chat_new_message_attach_action_photo',
      desc: '',
      args: [],
    );
  }

  /// `Upload error`
  String get chat_new_message_attach_error_title {
    return Intl.message(
      'Upload error',
      name: 'chat_new_message_attach_error_title',
      desc: '',
      args: [],
    );
  }

  /// `Can't access file`
  String get chat_new_message_attach_error_cant_access_file {
    return Intl.message(
      'Can\'t access file',
      name: 'chat_new_message_attach_error_cant_access_file',
      desc: '',
      args: [],
    );
  }

  /// `Server don't accept new files`
  String get chat_new_message_attach_error_server_auth {
    return Intl.message(
      'Server don\'t accept new files',
      name: 'chat_new_message_attach_error_server_auth',
      desc: '',
      args: [],
    );
  }

  /// `File exceeds maximum size {maxSize}. Actual size is {actualSize}`
  String chat_new_message_attach_error_file_size(Object maxSize, Object actualSize) {
    return Intl.message(
      'File exceeds maximum size $maxSize. Actual size is $actualSize',
      name: 'chat_new_message_attach_error_file_size',
      desc: '',
      args: [maxSize, actualSize],
    );
  }

  /// `Invalid http code: {responseCode}`
  String chat_new_message_attach_error_http_code(Object responseCode) {
    return Intl.message(
      'Invalid http code: $responseCode',
      name: 'chat_new_message_attach_error_http_code',
      desc: '',
      args: [responseCode],
    );
  }

  /// `Invalid http response body: {responseBody}`
  String chat_new_message_attach_error_http_body(Object responseBody) {
    return Intl.message(
      'Invalid http response body: $responseBody',
      name: 'chat_new_message_attach_error_http_body',
      desc: '',
      args: [responseBody],
    );
  }

  /// `Timeout during uploading`
  String get chat_new_message_attach_error_http_timeout {
    return Intl.message(
      'Timeout during uploading',
      name: 'chat_new_message_attach_error_http_timeout',
      desc: '',
      args: [],
    );
  }

  /// `Users`
  String get chat_users_list_title {
    return Intl.message(
      'Users',
      name: 'chat_users_list_title',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get chat_users_list_loading {
    return Intl.message(
      'Loading...',
      name: 'chat_users_list_loading',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get chat_users_list_search_field_filter_label {
    return Intl.message(
      'Search',
      name: 'chat_users_list_search_field_filter_label',
      desc: '',
      args: [],
    );
  }

  /// `Nickname`
  String get chat_users_list_search_field_filter_hint {
    return Intl.message(
      'Nickname',
      name: 'chat_users_list_search_field_filter_hint',
      desc: '',
      args: [],
    );
  }

  /// `Users not found`
  String get chat_users_list_search_users_not_found {
    return Intl.message(
      'Users not found',
      name: 'chat_users_list_search_users_not_found',
      desc: '',
      args: [],
    );
  }

  /// `User information`
  String get chat_user_action_information {
    return Intl.message(
      'User information',
      name: 'chat_user_action_information',
      desc: '',
      args: [],
    );
  }

  /// `Direct Messages`
  String get chat_user_action_direct_messages {
    return Intl.message(
      'Direct Messages',
      name: 'chat_user_action_direct_messages',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}