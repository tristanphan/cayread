import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cayread/injection/injection.dart';
import 'package:cayread/logging/log_file_provider.dart';
import 'package:intl/intl.dart';
import 'package:synchronized/synchronized.dart';

/// Per-class or per-use interface for dispatching log requests
class Logger {
  final String _identifier;

  Logger.forType(Type type) : _identifier = type.toString();

  void debug(String message) => _Worker.instance.log(_identifier, LogLevel.debug, message);

  void info(String message) => _Worker.instance.log(_identifier, LogLevel.info, message);

  void warn(String message) => _Worker.instance.log(_identifier, LogLevel.warn, message);

  void error(String message) => _Worker.instance.log(_identifier, LogLevel.error, message);

  /// If the [condition] is false, throws an [AssertionError] with the [errorMessage]
  void assertThat(bool condition, {required String errorMessage}) {
    if (!condition) {
      error(errorMessage);
      throw AssertionError(errorMessage);
    }
  }
}

/// An internal-use singleton used to manage log requests
class _Worker {
  static final _Worker instance = _Worker._create();

  _Worker._create() {
    _writeLock.synchronized(() async => _replaceLogFile(initial: true));
  }

  // Constants (Runtime or Compile-time)
  static final int _logLevelWidth = LogLevel.values.map((LogLevel level) => level.name.length).reduce(max);
  static const int _idealLogFileSize = 1024 * 1024 * 2; // 2 MB

  // Static Dependencies
  static final LogFileProvider _logFileProvider = serviceLocator();

  // Log file details
  late File _logFile;
  late DateTime _logFileDate;
  late IOSink _logFileWriter;
  final Lock _writeLock = Lock();

  /// Logs the [message] along with the [identifier] and [level] to the [_logFile]
  void log(String identifier, LogLevel level, String message) {
    DateTime date = DateTime.now().toUtc();
    String line = _formatMessageContent(identifier, level, message, date);

    _writeLock.synchronized(() async {
      if (_shouldReplaceLogFile(date)) await _replaceLogFile();
      _logFileWriter.writeln(line);
    });
  }

  /// Returns the formatted log line using the [identifier], [level], [message], and [date]
  String _formatMessageContent(String identifier, LogLevel level, String message, DateTime date) {
    DateFormat dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String displayDateTime = dateFormatter.format(date);
    String displayLevel = "[${level.name.toUpperCase()}]".padRight(_logLevelWidth);

    return "$displayDateTime $displayLevel $identifier - $message";
  }

  /// Determines whether the current file should be replaced, depending on the [date] and [_logFile] size
  bool _shouldReplaceLogFile(DateTime date) {
    // Not synchronized, should be called from within a synchronized block
    bool isDifferentDate =
        (_logFileDate.year != date.year || _logFileDate.month != date.month || _logFileDate.day != date.day);
    late bool isFileTooLarge = (_logFile.lengthSync()) > _idealLogFileSize;
    return isDifferentDate || isFileTooLarge;
  }

  /// Closes the current file sink (if not [initial]) and prepares a new file
  Future<void> _replaceLogFile({bool initial = false}) async {
    // Not synchronized, should be called from within a synchronized block
    if (!initial) await _logFileWriter.close();
    _logFileDate = DateTime.now().toUtc();
    _logFile = await _logFileProvider.getNewLogFile(_logFileDate);
    _logFileWriter = _logFile.openWrite(encoding: utf8, mode: FileMode.writeOnlyAppend);
  }
}

enum LogLevel {
  debug,
  info,
  warn,
  error,
}
