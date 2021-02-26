import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/list/channel_list_bloc.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';

abstract class NetworkListListenerBloc extends DisposableOwner {
  final NetworkListBloc networkListBloc;

  NetworkListListenerBloc({
    @required this.networkListBloc,
}) {
    addDisposable(
      disposable: networkListBloc.listenForNetworkJoin(
        (networkWithState) {
          var network = networkWithState.network;

          addDisposable(
            disposable: networkListBloc.listenForNetworkLeave(
              network,
              () {
                onNetworkLeaved(network);
              },
            ),
          );

          onNetworkJoined(networkWithState);
        },
      ),
    );
  }

  @mustCallSuper
  @protected
  void onNetworkJoined(NetworkWithState networkWithState);

  @mustCallSuper
  @protected
  void onNetworkLeaved(Network network);

  ChannelListBloc getChannelListBloc(Network network) {
    var chatChannelsListBloc = networkListBloc.getChannelListBloc(network);

    return chatChannelsListBloc;
  }
}
