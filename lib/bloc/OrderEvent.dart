

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
}

class OrderMoveAdded extends OrderEvent{

  final Map move;

  OrderMoveAdded({@required this.move});

  @override
  List<Object> get props => [move];

}

class OrderConnectivityIssueDetected extends OrderEvent{
  @override
  List<Object> get props => [];
}

class OrderInitialized extends OrderEvent{
  @override
  List<Object> get props => [];
}

class OrderInconsistencyDetected extends OrderEvent{
  @override
  List<Object> get props => [];
}
