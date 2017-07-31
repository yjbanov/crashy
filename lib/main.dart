// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// This is a sample Flutter app that demonstrates to to catch various kinds
/// of errors in Flutter apps and report them to Sentry.io.
/// 
/// Explanations are provided in the inline comments in the code below.
library crashy;

import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// This import the Dart Sentry.io client that sends crash reports to Sentry.io.
import 'package:sentry/sentry.dart';

// This file does not exist in the repository and is .gitignored. In your local
// clone of this repository, create this file and add a top-level [String]
// constant containing the DSN value issued by Sentry.io to your project.
//
// This method of supplying DSN is only for demo purposes. In a real app you
// might want to get it using a more robust method, such as via environment
// variables, a configuration file or a platform-specific secret key storage.
import 'dsn.dart';

/// Sentry.io client used to send crash reports (or more generally "events").
/// 
/// This client uses the default client parameters. For example, it uses a
/// plain HTTP client that does not retry failed report attempts and does
/// not support offline mode. You might want to use a different HTTP client,
/// one that has these features. Please read the documentation for the
/// [SentryClient] constructor to learn how you can customize it.
/// 
/// [SentryClient.environmentAttributes] are particularly useful in a real
/// app. Use them to specify attributes of your app that do not change from
/// one event to another, such as operating system type and verion, the
/// version of Flutter, and [device information][1].
/// 
/// [1]: https://github.com/flutter/plugins/tree/master/packages/device_info
final SentryClient _sentry = new SentryClient(dsn: dsn);

/// Reports [error] along with its [stackTrace] to Sentry.io.
Future<Null> _reportError(dynamic error, dynamic stackTrace) async {
  print('Caught error: $error');

  // Errors thrown in development mode are unlikely to be interesting. You can
  // check if you are running in dev mode using an assertion and omit sending
  // the report.
  bool inDevMode = false;
  assert(inDevMode = true);
  if (inDevMode) {
    print('In dev mode. Not sending report.');
    return;
  }

  print('Reporting to Sentry.io...');

  final SentryResponse response = await _sentry.captureException(
    exception: error,
    stackTrace: stackTrace,
  );

  if (response.isSuccessful) {
    print('Success! Event ID: ${response.eventId}');
  } else {
    print('Failed to report to Sentry.io: ${response.error}');
  }
}

Future<Null> main() async {
  // This captures errors reported by the Flutter framework.
  FlutterError.onError = (FlutterErrorDetails details) async {
    await _reportError(details.exception, details.stack);
  };

  // This captures errors not caught by the Flutter framework, such as those
  // thrown from [Timer]s and microtasks. It works by running the app in a
  // custom [Zone], which tracks all events and microtasks and forwards all
  // errors to a custom `onError` handler, which forwards it to `_reportError`.
  //
  // More about zones:
  //
  // - https://api.dartlang.org/stable/1.24.2/dart-async/Zone-class.html
  // - https://www.dartlang.org/articles/libraries/zones
  runZoned<Future<Null>>(() async {
    runApp(new CrashyApp());
  }, onError: (error, stackTrace) async {
    await _reportError(error, stackTrace);
  });
}

class CrashyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Crashy',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Crashy'),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new RaisedButton(
              child: new Text('Dart exception'),
              elevation: 1.0,
              onPressed: () {
                throw new StateError('This is a Dart exception.');
              },
            ),
            new RaisedButton(
              child: new Text('Java exception'),
              elevation: 1.0,
              onPressed: () async {
                final channel = const MethodChannel('crashy-custom-channel');
                await channel.invokeMethod('blah');
              },
            ),
          ],
        ),
      ),
    );
  }
}
