import 'package:equatable/equatable.dart';
import 'ScanBloc.dart';

abstract class ScanState extends Equatable {
  const ScanState();
}


class ScanUpdateSuccess extends ScanState {
  final List<Scan> scanList;

  ScanUpdateSuccess(this.scanList);
  @override
  List<Object> get props => scanList;
}



class ScanInitial extends ScanState {

  @override
  List<Object> get props => [];
}
