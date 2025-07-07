/// Returns a simple BLoC setup for managing counter state using flutter_bloc.
String blocTemplate() => '''
import 'package:flutter_bloc/flutter_bloc.dart';

/// Events for the [CounterBloc]
abstract class CounterEvent {}

/// Event to increment the counter
class IncrementCounter extends CounterEvent {}

/// Event to reset the counter
class ResetCounter extends CounterEvent {}

/// Bloc that handles counter events and emits updated state
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<IncrementCounter>((event, emit) => emit(state + 1));
    on<ResetCounter>((event, emit) => emit(0));
  }
}
''';
