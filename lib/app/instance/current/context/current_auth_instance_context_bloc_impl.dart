import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_blocs_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/list/unread_count/channel_list_unread_count_bloc.dart';
import 'package:flutter_appirc/app/channel/state/channel_states_bloc.dart';
import 'package:flutter_appirc/app/chat/active_channel/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/db/chat_database.dart';
import 'package:flutter_appirc/app/chat/db/chat_database_service.dart';
import 'package:flutter_appirc/app/chat/deep_link/chat_deep_link_bloc.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_bloc.dart';
import 'package:flutter_appirc/app/chat/preferences/chat_preferences_bloc.dart';
import 'package:flutter_appirc/app/chat/preferences/chat_preferences_model.dart';
import 'package:flutter_appirc/app/chat/preferences/chat_preferences_saver_bloc.dart';
import 'package:flutter_appirc/app/chat/push_notifications/chat_push_notifications.dart';
import 'package:flutter_appirc/app/chat/upload/chat_upload_bloc.dart';
import 'package:flutter_appirc/app/context/app_context_bloc_impl.dart';
import 'package:flutter_appirc/app/instance/current/context/current_auth_instance_context_bloc.dart';
import 'package:flutter_appirc/app/instance/current/current_auth_instance_bloc.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_condensed_bloc.dart';
import 'package:flutter_appirc/app/message/message_manager_bloc.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_blocs_bloc.dart';
import 'package:flutter_appirc/app/network/state/network_states_bloc.dart';
import 'package:flutter_appirc/local_preferences/local_preferences_service.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider_context_bloc_impl.dart';
import 'package:flutter_appirc/push/fcm/fcm_push_service.dart';
import 'package:flutter_appirc/socket_io/socket_io_service.dart';
import 'package:logging/logging.dart';

var _logger = Logger("current_auth_instance_context_bloc_imp.dart");

class CurrentAuthInstanceContextBloc extends ProviderContextBloc
    implements ICurrentAuthInstanceContextBloc {
  final AppContextBloc appContextBloc;

  final LoungePreferences currentInstance;

  CurrentAuthInstanceContextBloc({
    @required this.appContextBloc,
    @required this.currentInstance,
  });

  @override
  Future internalAsyncInit() async {
    _logger.fine(() => "internalAsyncInit");

    ChatDatabaseService chatDatabaseService =
    appContextBloc.get<ChatDatabaseService>();
    ChatDatabase database = chatDatabaseService.chatDatabase;

    var globalProviderService = this;

    var currentAuthInstanceBloc =
    appContextBloc.get<ICurrentAuthInstanceBloc>();

    var socketIoService = appContextBloc.get<SocketIOService>();
    var fcmPushService = appContextBloc.get<IFcmPushService>();
    var localPreferenceService = appContextBloc.get<ILocalPreferencesService>();

    var loungeBackendService = LoungeBackendService(
      socketIoService: socketIoService,
      loungePreferences: currentInstance,
    );

    await globalProviderService
        .asyncInitAndRegister<LoungeBackendService>(loungeBackendService);

    await globalProviderService
        .asyncInitAndRegister<ChatBackendService>(loungeBackendService);

    ChatActiveChannelBloc activeChannelBloc;
    Channel Function() currentChannelExtractor = () {
      return activeChannelBloc?.activeChannel;
    };

    await loungeBackendService.init(
      currentChannelExtractor: currentChannelExtractor,
      lastMessageRemoteIdExtractor: () async {
        var newestMessage =
        (await database.regularMessagesDao.getNewestAllChannelsMessage());

        _logger.finest(() => " newestMessage $newestMessage");

        return newestMessage?.messageRemoteId;
      },
    );

    var chatPreferencesBloc = ChatPreferencesBloc(
      localPreferenceService,
    );

    await globalProviderService
        .asyncInitAndRegister<ChatPreferencesBloc>(chatPreferencesBloc);

    var networkListBloc = NetworkListBloc(
      loungeBackendService,
      nextNetworkIdGenerator: chatPreferencesBloc.getNextNetworkLocalId,
      nextChannelIdGenerator: chatPreferencesBloc.getNextChannelLocalId,
    );

    await globalProviderService
        .asyncInitAndRegister<NetworkListBloc>(networkListBloc);

    var messageCondensedBloc = MessageCondensedBloc();

    await globalProviderService
        .asyncInitAndRegister<MessageCondensedBloc>(messageCondensedBloc);

    var networkStatesBloc = NetworkStatesBloc(
      backendService: loungeBackendService,
      networkListBloc: networkListBloc,
    );

    await globalProviderService
        .asyncInitAndRegister<NetworkStatesBloc>(networkStatesBloc);

    var startPreferences = chatPreferencesBloc.value ?? ChatPreferences.empty;

    var connectionBloc = ChatConnectionBloc(loungeBackendService);

    await globalProviderService
        .asyncInitAndRegister<ChatConnectionBloc>(connectionBloc);

    var chatInitBloc = ChatInitBloc(
      backendService: loungeBackendService,
      connectionBloc: connectionBloc,
      networkListBloc: networkListBloc,
      startPreferences: startPreferences,
    );

    await globalProviderService
        .asyncInitAndRegister<ChatInitBloc>(chatInitBloc);

    var chatPushesService = ChatPushesService(
      fcmPushService: fcmPushService,
      backendService: loungeBackendService,
      chatInitBloc: chatInitBloc,
    );

    await globalProviderService
        .asyncInitAndRegister<ChatPushesService>(chatPushesService);

    activeChannelBloc = ChatActiveChannelBloc(
      backendService: loungeBackendService,
      chatInitBloc: chatInitBloc,
      networksListBloc: networkListBloc,
      preferencesService: localPreferenceService,
      pushesService: chatPushesService,
    );

    await globalProviderService
        .asyncInitAndRegister<ChatActiveChannelBloc>(activeChannelBloc);

    var channelsStatesBloc = ChannelStatesBloc(
      backendService: loungeBackendService,
      db: database,
      networksListBloc: networkListBloc,
      activeChannelBloc: activeChannelBloc,
    );

    await globalProviderService
        .asyncInitAndRegister<ChannelStatesBloc>(channelsStatesBloc);

    var channelsBlocsBloc = ChannelBlocsBloc(
      backendService: loungeBackendService,
      chatPushesService: chatPushesService,
      networksListBloc: networkListBloc,
      channelsStatesBloc: channelsStatesBloc,
    );

    await globalProviderService
        .asyncInitAndRegister<ChannelBlocsBloc>(channelsBlocsBloc);

    var networksBlocsBloc = NetworkBlocsBloc(
      backendService: loungeBackendService,
      networkListBloc: networkListBloc,
      networkStatesBloc: networkStatesBloc,
      channelsStatesBloc: channelsStatesBloc,
      activeChannelBloc: activeChannelBloc,
    );

    await globalProviderService
        .asyncInitAndRegister<NetworkBlocsBloc>(networksBlocsBloc);

    var chatDeepLinkBloc = ChatDeepLinkBloc(
      loungeBackendService,
      chatInitBloc,
      networkListBloc,
      networksBlocsBloc,
      activeChannelBloc,
    );

    await globalProviderService
        .asyncInitAndRegister<ChatDeepLinkBloc>(chatDeepLinkBloc);

    var chatUploadBloc = ChatUploadBloc(
      backendService: loungeBackendService,
    );

    await globalProviderService
        .asyncInitAndRegister<ChatUploadBloc>(chatUploadBloc);

    var chatUnreadBloc = ChannelListUnreadCountBloc(
      channelsStateBloc: channelsStatesBloc,
    );

    await globalProviderService
        .asyncInitAndRegister<ChannelListUnreadCountBloc>(chatUnreadBloc);

    var chatPreferencesSaverBloc = ChatPreferencesSaverBloc(
      backendService: loungeBackendService,
      stateBloc: networkStatesBloc,
      networksListBloc: networkListBloc,
      chatPreferencesBloc: chatPreferencesBloc,
      initBloc: chatInitBloc,
    );

    await globalProviderService.asyncInitAndRegister<ChatPreferencesSaverBloc>(
        chatPreferencesSaverBloc);

    var messageManagerBloc = MessageManagerBloc(
      backendService: loungeBackendService,
      networksListBloc: networkListBloc,
      db: database,
    );

    await globalProviderService
        .asyncInitAndRegister<MessageManagerBloc>(messageManagerBloc);

    addDisposable(
      disposable: loungeBackendService.listenForSignOut(
            () async {
          await messageManagerBloc.clearAllMessages();

          chatPreferencesSaverBloc.reset();

          await currentAuthInstanceBloc.logoutCurrentInstance();
        },
      ),
    );
  }
}
