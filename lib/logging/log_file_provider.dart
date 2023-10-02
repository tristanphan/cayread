import 'dart:io';

import 'package:cayread/file_structure/file_provider.dart';
import 'package:cayread/injection/injection.dart';
import 'package:collection/collection.dart' as collection;
import 'package:injectable/injectable.dart';

@singleton
class LogFileProvider {
  // Dependencies
  final FileProvider fileProvider = serviceLocator();

  // Constants
  static const _maxNumberOfLogFiles = 100;

  /// Returns a fresh new log file for the [date]
  Future<File> getNewLogFile(DateTime date) async {
    List<File> logFiles = await findExistingLogFiles();

    // Prune log files
    if (logFiles.length > _maxNumberOfLogFiles) {
      logFiles.sublist(0, logFiles.length - _maxNumberOfLogFiles).forEach((File file) => file.delete());
    }

    int nextNumber = 1;
    File? latestFile = logFiles.where((File file) => _isValidLogFileName(file.filename, forDate: date)).lastOrNull;
    if (latestFile != null) {
      RegExpMatch? match = _getLogFileRegex().firstMatch(latestFile.filename)!;
      nextNumber = int.parse(match.group(1)!) + 1;
    }
    return _getLogFile(date, nextNumber);
  }

  /// Returns the log file with the [date] and [number]
  /// $logDirectory/cayread_$dateTime_$number.log
  Future<File> _getLogFile(DateTime date, int number) async {
    Directory logDirectory = await fileProvider.getLogDirectory();

    String year = _padInt(date.year, 4);
    String month = _padInt(date.month, 2);
    String day = _padInt(date.day, 2);
    String fileName = "cayread_$year-$month-${day}_$number.log";

    File file = File("${logDirectory.path}$fileName");
    await file.create(recursive: true);
    return file;
  }

  /// Returns a set of all existing log files
  Future<List<File>> findExistingLogFiles() async {
    Directory logDirectory = await fileProvider.getLogDirectory();
    Stream<File> fileStream = logDirectory
        .list()
        .where((FileSystemEntity entity) => entity is File)
        .map((FileSystemEntity entity) => entity as File)
        .where((File file) => _isValidLogFileName(file.filename));
    List<File> files = (await fileStream.toList());
    files.sort((File a, File b) => collection.compareNatural(a.filename, b.filename));
    return files;
  }

  /// Identifies whether a [filename] follows the format of a log file,
  /// with the optional [forDate] constrictor
  bool _isValidLogFileName(String filename, {DateTime? forDate}) {
    RegExpMatch? match = _getLogFileRegex(forDate: forDate).firstMatch(filename);
    return (match != null && match.start == 0 && match.end == filename.length);
  }

  /// Generates the regex for the log file filename, with the optional [forDate] constrictor
  RegExp _getLogFileRegex({DateTime? forDate}) {
    String year, month, day;
    if (forDate == null) {
      [year, month, day] = [r"\d{4}", r"\d{2}", r"\d{2}"];
    } else {
      [year, month, day] = [
        _padInt(forDate.year, 4),
        _padInt(forDate.month, 2),
        _padInt(forDate.day, 2),
      ];
    }
    return RegExp("^cayread_$year-$month-${day}_(\\d+)\\.log\$");
  }

  /// Pads the integer [toPad] with zeroes to the left, to make it [desiredLength] digits long
  String _padInt(int toPad, int desiredLength) => toPad.toString().padLeft(desiredLength, "0");
}

extension FileNameExtension on File {
  String get filename => uri.pathSegments.last;
}
