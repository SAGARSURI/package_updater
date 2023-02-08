import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:package_updater/src/commands/commands.dart';
import 'package:package_updater/src/version.dart';

const executableName = 'package_updater';
const packageName = 'package_updater';
const description =
    '''A dart package which will upgrade an existing package using the correct package manager''';

/// {@template package_updater_command_runner}
/// A [CommandRunner] for the CLI.
///
/// ```
/// $ package_updater --version
/// ```
/// {@endtemplate}
class PackageUpdaterCommandRunner extends CommandRunner<int> {
  /// {@macro package_updater_command_runner}
  PackageUpdaterCommandRunner({Logger? logger})
      : _logger = logger ?? Logger(),
        super(executableName, description) {
    // Add root options and flags
    argParser
      ..addFlag(
        'version',
        abbr: 'v',
        negatable: false,
        help: 'Print the current version.',
      )
      ..addFlag(
        'verbose',
        help: 'Noisy logging, including all shell commands executed.',
      );

    // Add sub commands
    addCommand(SampleCommand(logger: _logger));
    addCommand(UpdateCommand(logger: _logger));
  }

  @override
  void printUsage() => _logger.info(usage);

  final Logger _logger;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final topLevelResults = parse(args);
      if (topLevelResults['verbose'] == true) {
        _logger.level = Level.verbose;
      }

      _logger
        ..detail('Argument information:')
        ..detail('  Top level options:');
      for (final option in topLevelResults.options) {
        if (topLevelResults.wasParsed(option)) {
          _logger.detail('  - $option: ${topLevelResults[option]}');
        }
      }
      if (topLevelResults.command != null) {
        final commandResult = topLevelResults.command!;
        _logger
          ..detail('  Command: ${commandResult.name}')
          ..detail('    Command options:');
        for (final option in commandResult.options) {
          if (commandResult.wasParsed(option)) {
            _logger.detail('    - $option: ${commandResult[option]}');
          }
        }
      }

      return ExitCode.success.code;
    } on FormatException catch (e, stackTrace) {
      // On format errors, show the commands error message, root usage and
      // exit with an error code
      _logger
        ..err(e.message)
        ..err('$stackTrace')
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      // On usage errors, show the commands usage message and
      // exit with an error code
      _logger
        ..err(e.message)
        ..info('')
        ..info(e.usage);
      return ExitCode.usage.code;
    }
  }
}
