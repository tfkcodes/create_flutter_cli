/// Returns a Riverpod-based state management template using `StateNotifier`.
///
/// This is a simple example to get started with Riverpod's `StateNotifierProvider`.
String riverpodTemplate() => '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A simple state class for holding counter value.
/// Extend or replace this with your own model/state.
class AppState {
  final int count;

  AppState({this.count = 0});

  /// Returns a copy with updated values (useful for immutability).
  AppState copyWith({int? count}) {
    return AppState(count: count ?? this.count);
  }
}

/// A [StateNotifier] that manages the [AppState].
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState());

  /// Increments the counter.
  void increment() {
    state = state.copyWith(count: state.count + 1);
  }

  /// Resets the state to default.
  void reset() {
    state = AppState();
  }
}

/// A global provider that exposes the [AppStateNotifier].
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);
''';
