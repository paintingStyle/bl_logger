## bl_logger
- Support different levvel log printing
- Support displaying different colors
- Support mobile phone shake to view logs

## Usage

```dart
dependencies:
  bl_logger: ^0.0.1

import 'package:bl_logger/bl_logger.dart';
```

```dart
LogConsoleOnShake(
    dark: true,
    debugOnly: env.isProduct ? true : false,
    showShareButton: true,
    child: AppWidget()
),

Logger.d('msg');
Logger.i('msg');
Logger.w('msg');
Logger.e('msg');
Logger.v('msg');
```

