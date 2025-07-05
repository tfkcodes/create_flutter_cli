import 'package:create_flutter_cli/src/generator.dart';
import 'package:interact/interact.dart';

void main(List<String> arguments) {
  final projectName = Input(prompt: 'Enter your project name').interact();

  final state = Select(
    prompt: 'Select state management',
    options: ['none', 'provider', 'bloc', 'getx', 'riverpod'],
  ).interact();

  final theme = Confirm(
    prompt: 'Add light/dark theme support?',
    defaultValue: true,
  ).interact();

  final network = Select(
    prompt: 'Select networking type',
    options: ['none', 'rest', 'graphql'],
  ).interact();

  final routing = Confirm(
    prompt: 'Add routing support?',
    defaultValue: true,
  ).interact();

  final structure = Confirm(
    prompt: 'Generate folder structure?',
    defaultValue: true,
  ).interact();

  List<String> apis = [];
  if (network == 1) {
    // REST
    final endpointStr = Input(
      prompt: 'Enter comma-separated REST endpoints (e.g. login,register)',
    ).interact();
    apis = endpointStr.split(',').map((e) => e.trim()).toList();
  }

  final config = GeneratorConfig(
    state: state == 0
        ? null
        : ['none', 'provider', 'bloc', 'getx', 'riverpod'][state],
    theme: theme,
    network: network == 0 ? null : ['none', 'rest', 'graphql'][network],
    routing: routing,
    structure: structure,
    apis: apis,
  );

  Generator(projectName, config).generate();
}
