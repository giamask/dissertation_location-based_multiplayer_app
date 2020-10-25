

import 'package:equatable/equatable.dart';

abstract class OrderState extends Equatable {
  const OrderState();
}

class OrderUpToDate extends OrderState {
  @override
  List<Object> get props => [];
}


class OrderUpdateInProcess extends OrderState {
  @override
  List<Object> get props => [];
}

