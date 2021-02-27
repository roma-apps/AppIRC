import 'package:flutter/material.dart' show Divider;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/list/network_list_item_widget.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_blocs_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:provider/provider.dart';

class NetworkListWidget extends StatelessWidget {
  final VoidCallback onActionCallback;

  NetworkListWidget(this.onActionCallback);

  @override
  Widget build(BuildContext context) {
    var networkListBloc = Provider.of<NetworkListBloc>(context);

    return StreamBuilder<List<Network>>(
      stream: networkListBloc.networksStream,
      initialData: networkListBloc.networks,
      builder: (BuildContext context, AsyncSnapshot<List<Network>> snapshot) {
        var networks = snapshot.data ?? [];

        if (networks.isNotEmpty) {
          return Provider.value(
            value: networks,
            child: NetworksListBodyWidget(
              onActionCallback: onActionCallback,
            ),
          );
        } else {
          return const _NetworkListEmptyWidget();
        }
      },
    );
  }
}

class _NetworkListEmptyWidget extends StatelessWidget {
  const _NetworkListEmptyWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        S.of(context).chat_networks_list_empty,
        style: IAppIrcUiTextTheme.of(context).mediumDarkGrey,
      ),
    );
  }
}

class NetworksListBodyWidget extends StatelessWidget {
  final VoidCallback onActionCallback;

  const NetworksListBodyWidget({
    @required this.onActionCallback,
  });

  @override
  Widget build(BuildContext context) {
    var networks = Provider.of<List<Network>>(context);
    var networkBlocsBloc = NetworkBlocsBloc.of(context);

    return ListView.separated(
      shrinkWrap: true,
      itemCount: networks.length,
      separatorBuilder: (context, index) => Divider(
        color: IAppIrcUiColorTheme.of(context).grey,
      ),
      itemBuilder: (BuildContext context, int index) {
        var network = networks[index];
        return Provider.value(
          value: network,
          child: ProxyProvider<Network, NetworkBloc>(
            update: (context, network, _) =>
                networkBlocsBloc.getNetworkBloc(network),
            child: NetworkListItemWidget(
              onActionCallback: onActionCallback,
            ),
          ),
        );
      },
    );
  }
}
