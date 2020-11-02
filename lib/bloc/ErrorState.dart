
import 'package:equatable/equatable.dart';

abstract class ErrorState extends Equatable {
  const ErrorState();
}

class ErrorInitial extends ErrorState {
  @override
  List<Object> get props => [];
}
