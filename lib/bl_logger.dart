library bl_logger;

import 'dart:developer' as developer;
import 'package:logger/logger.dart' as logger;
import 'log_console.dart';

export './log_console_on_shake.dart';

class Logger {
  static final Logger _singleton = Logger._();
  factory Logger() => _singleton;

  String logName = 'Logger';
  bool cacheLog = true;
  final List<String> logs = [];

  late logger.Logger _logger;

  static void d(dynamic message) => _singleton._debug(message);
  static void i(dynamic message) => _singleton._info(message);
  static void w(dynamic message) => _singleton._warning(message);
  static void e(dynamic message) => _singleton._error(message);
  static void v(dynamic message) => _singleton._verbose(message);

  void _debug(dynamic message) {
    if (cacheLog) {
      toLogConsole(logger.Level.debug, message);
    }

    _logger.d(message);
  }

  void _info(dynamic message) {
    if (cacheLog) {
      toLogConsole(logger.Level.info, message);
    }
    _logger.i(message);
  }

  void _warning(dynamic message) {
    if (cacheLog) {
      toLogConsole(logger.Level.warning, message);
    }
    _logger.w(message);
  }

  void _error(dynamic message) {
    if (cacheLog) {
      toLogConsole(logger.Level.error, message);
    }
    _logger.e(message);
  }

  void _verbose(dynamic message) {
    if (cacheLog) {
      toLogConsole(logger.Level.verbose, message);
    }
    _logger.v(message);
  }

  void toLogConsole(logger.Level level, dynamic message) {
    final printer = CustomPrinter(displayColor: false);
    final logEvent = logger.LogEvent(level, message, null, null);
    List<String> outputs = printer.log(logEvent);
    final outputEvent = logger.OutputEvent(logEvent, outputs);

    LogConsole.add(outputEvent);
  }

  Logger._() {
    _logger = logger.Logger(
      output: CustomConsoleOutput(),
      printer: CustomPrinter(displayColor: true),
    );
  }
}

class CustomConsoleOutput extends logger.LogOutput {
  @override
  void output(logger.OutputEvent event) {
    const bool isProd = bool.fromEnvironment("dart.vm.product");
    if (isProd) return;
    for (var item in event.lines) {
      developer.log(item, name: Logger._singleton.logName);
    }
  }
}

class CustomPrinter extends logger.LogPrinter {
  CustomPrinter({required this.displayColor});
  final bool displayColor;

  @override
  List<String> log(logger.LogEvent event) {
    String color = _levelColor(event.level);
    String level = _levelString(event.level);
    String time = _timeKey();
    String levelIcon = _levelIcon(event.level);

    var output = displayColor
        ? StringBuffer('$color$level[$time]$levelIcon ')
        : StringBuffer('$level[$time]$levelIcon ');
    if (event.message is String) {
      output.write('${event.message}');
    } else if (event.message is Map) {
      event.message.entries.forEach((entry) {
        if (entry.value is num) {
          output.write(' ${entry.key}=${entry.value}');
        } else {
          output.write(' ${entry.key}="${entry.value}"');
        }
      });
    }

    return [output.toString()];
  }

  static String closeAllPropertiesKey = '\x1b[0m\x1b[1m';
  static String underlineKey = '\x1b[4m';

  static final levelPrefixes = {
    logger.Level.verbose: '[V]',
    logger.Level.debug: '[D]',
    logger.Level.info: '[I]',
    logger.Level.warning: '[W]',
    logger.Level.error: '[E]',
    logger.Level.wtf: '[W]',
  };

  static final levelPrefixeIcons = {
    logger.Level.verbose: '',
    logger.Level.debug: '🐛 ',
    logger.Level.info: '💡 ',
    logger.Level.warning: '❕❕ ',
    logger.Level.error: '⛔⛔⛔ ',
    logger.Level.wtf: '',
  };

  static final levelColors = {
    logger.Level.verbose: '',
    logger.Level.debug: '$closeAllPropertiesKey\x1B[36m',
    logger.Level.info: '$closeAllPropertiesKey\x1B[32m',
    logger.Level.warning: '$closeAllPropertiesKey\x1B[35m',
    logger.Level.error: '$closeAllPropertiesKey$underlineKey\x1B[31m',
    logger.Level.wtf: '$closeAllPropertiesKey\x1b[37m',
  };

  String _levelString(logger.Level level) {
    return levelPrefixes[level] ?? '';
  }

  String _levelIcon(logger.Level level) {
    return levelPrefixeIcons[level] ?? '';
  }

  String _levelColor(logger.Level level) {
    return levelColors[level] ?? '';
  }

  String _timeKey() {
    DateTime now = DateTime.now();
    return '${now.month}'
        '-${now.day}'
        ' ${now.hour}'
        ':${now.minute}'
        ':${now.second}'
        ':${now.millisecond}';
  }
}
