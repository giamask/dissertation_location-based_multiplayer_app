import 'package:equatable/equatable.dart';

import 'ScanBloc.dart';

abstract class ScanEvent extends Equatable {
  const ScanEvent();
}

class ScanExecuted extends ScanEvent {
  final Scan scan;

  ScanExecuted(this.scan,);
  @override
  List<Object> get props => [scan];
}

class ScanInitialized extends ScanEvent {
  ScanInitialized();
  @override
  List<Object> get props => [];
}