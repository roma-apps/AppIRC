import 'dart:async';
import 'dart:collection';

import 'package:flutter_appirc/blocs/bloc.dart';
import 'package:flutter_appirc/models/connection_model.dart';
import 'package:rxdart/rxdart.dart';

class ConnectionsBloc implements BlocBase {
  final Set<ChannelsConnection> _connections = Set<ChannelsConnection>();

  BehaviorSubject<List<ChannelsConnection>> _connectionsController =
      new BehaviorSubject<List<ChannelsConnection>>(seedValue: []);

  Sink<List<ChannelsConnection>> get _inConnections =>
      _connectionsController.sink;

  Stream<List<ChannelsConnection>> get outConnections =>
      _connectionsController.stream;

  BehaviorSubject<ChannelsConnection> _connectionAddController =
      new BehaviorSubject<ChannelsConnection>();

  Sink<ChannelsConnection> get inAddConnection => _connectionAddController.sink;

  BehaviorSubject<ChannelsConnection> _connectionRemoveController =
      new BehaviorSubject<ChannelsConnection>();

  Sink<ChannelsConnection> get inRemoveConnection =>
      _connectionRemoveController.sink;

  BehaviorSubject<int> _connectionTotalController =
      new BehaviorSubject<int>(seedValue: 0);

  Sink<int> get _inTotalConnections => _connectionTotalController.sink;

  Stream<int> get outTotalConnections => _connectionTotalController.stream;

  ConnectionsBloc() {
    _connectionAddController.listen(_handleAddConnection);
    _connectionRemoveController.listen(_handleRemoveConnection);
  }

  void dispose() {
    _connectionAddController.close();
    _connectionRemoveController.close();
    _connectionTotalController.close();
    _connectionsController.close();
  }

  void _handleAddConnection(ChannelsConnection Connection) {
    // Add the movie to the list of connection ones
    _connections.add(Connection);

    _notify();
  }

  void _handleRemoveConnection(ChannelsConnection Connection) {
    _connections.remove(Connection);

    _notify();
  }

  void _notify() {
    _inTotalConnections.add(_connections.length);
    _inConnections.add(UnmodifiableListView(_connections));
  }
}
