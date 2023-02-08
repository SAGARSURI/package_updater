import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';

/// {@template update_command}
/// A command which updates the CLI.
/// {@endtemplate}
class UpdateCommand extends Command<int> {
  /// {@macro update_command}
  UpdateCommand({
    required Logger logger,
    PubUpdater? pubUpdater,
  })  : _logger = logger,
        _pubUpdater = pubUpdater ?? PubUpdater() {
    argParser
      ..addOption(
        'packageName',
        abbr: 'p',
        help: 'Name of the package that needs to be update',
      )
      ..addFlag(
        'versionNumber',
        abbr: 'v',
        help:
            '''Specific version to update the package to. Pass --no-versionNumber to update to the latest''',
        negatable: false,
      );
  }

  final Logger _logger;
  final PubUpdater _pubUpdater;

  @override
  String get description => 'Update the installed package.';

  static const String commandName = 'update';

  @override
  String get name => commandName;

  @override
  Future<int> run() async {
    final updateCheckProgress = _logger.progress('Checking for updates');
    final packageName = argResults?['packageName'] as String?;
    if (packageName == null || packageName.isEmpty) {
      updateCheckProgress.fail();
      _logger.err('Please provide a package name');
      return ExitCode.usage.code;
    }

    if (!_isValidPackageName(packageName)) {
      updateCheckProgress.fail();
      _logger.err('Please provide a valid package name');
      return ExitCode.usage.code;
    }

    if (Platform.isMacOS) {
      _updatePackage();
    } else if (Platform.isWindows) {
    } else if (Platform.isLinux) {}

    // late final String latestVersion;
    //
    // try {
    //   latestVersion = await _pubUpdater.getLatestVersion(packageName);
    // } catch (error) {
    //   updateCheckProgress.fail();
    //   _logger.err('$error');
    //   return ExitCode.software.code;
    // }
    // updateCheckProgress.complete('Checked for updates');
    //
    // final isUpToDate = packageVersion == latestVersion;
    // if (isUpToDate) {
    //   _logger.info('CLI is already at the latest version.');
    //   return ExitCode.success.code;
    // }
    //
    // final updateProgress = _logger.progress('Updating to $latestVersion');
    //
    // late final ProcessResult result;
    // try {
    //   result = await _pubUpdater.update(
    //     packageName: packageName,
    //     versionConstraint: latestVersion,
    //   );
    // } catch (error) {
    //   updateProgress.fail();
    //   _logger.err('$error');
    //   return ExitCode.software.code;
    // }
    //
    // if (result.exitCode != ExitCode.success.code) {
    //   updateProgress.fail();
    //   _logger.err('Error updating CLI: ${result.stderr}');
    //   return ExitCode.software.code;
    // }

    // updateProgress.complete('Updated to $latestVersion');

    return ExitCode.success.code;
  }

  void _updatePackage() {}

  // TODO(SAGARSURI): Fix this with brew ls --versions packageName
  bool _isValidPackageName(String packageName) {
    Process.runSync('brew', ['ls', '--versions', packageName, '&>/dev/null']);
    final output = Process.runSync('bash', ['-c', r'echo "$?"']);
    final result = output.stdout.toString().trim();
    _logger..info(result)
    ..info("${result.isNotEmpty && result == '0'}");
    return result.isNotEmpty && result == '0';
  }
}

enum PackageManager { brew }
