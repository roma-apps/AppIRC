import 'dart:async';
import 'dart:collection';
import 'package:rxdart/rxdart.dart';


import 'package:flutter_appirc/models/connection_model.dart';

import 'bloc.dart';


class ConnectionsBloc implements BlocBase {

  final Set<Connection> _connections = Set<Connection>();


  BehaviorSubject<List<Connection>> _connectionsController
    = new BehaviorSubject<List<Connection>>(seedValue: []);
  Sink<List<Connection>> get _inConnections =>_connectionsController.sink;
  Stream<List<Connection>> get outConnections =>_connectionsController.stream;


  BehaviorSubject<Connection> _connectionAddController = new BehaviorSubject<Connection>();
  Sink<Connection> get inAddConnection => _connectionAddController.sink;


  BehaviorSubject<Connection> _connectionRemoveController = new BehaviorSubject<Connection>();
  Sink<Connection> get inRemoveConnection => _connectionRemoveController.sink;

  BehaviorSubject<int> _connectionTotalController = new BehaviorSubject<int>(seedValue: 0);
  Sink<int> get _inTotalConnections => _connectionTotalController.sink;
  Stream<int> get outTotalConnections => _connectionTotalController.stream;

  ConnectionsBloc(){
    _connectionAddController.listen(_handleAddConnection);
    _connectionRemoveController.listen(_handleRemoveConnection);
  }

  void dispose(){
    _connectionAddController.close();
    _connectionRemoveController.close();
    _connectionTotalController.close();
    _connectionsController.close();
  }

  void _handleAddConnection(Connection Connection){
    // Add the movie to the list of connection ones
    _connections.add(Connection);

    _notify();
  }

  void _handleRemoveConnection(Connection Connection){
    _connections.remove(Connection);

    _notify();
  }

  void _notify(){

    _inTotalConnections.add(_connections.length);
    _inConnections.add(UnmodifiableListView(_connections));
  }
}
