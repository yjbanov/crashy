import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

dynamic main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    print('FlutterError.onError caught: $details');
  };

  final ultimateErrorCatcher = new RawReceivePort((dynamic error) {
    print('Isolate.current.addErrorListener caught: $error');
  });
  Isolate.current.addErrorListener(ultimateErrorCatcher.sendPort);

  runZoned<Future<Null>>(() async {
    runApp(new CrashyApp());
  }, onError: (error, stackTrace) {
    print('Zone caught: $error\n$stackTrace');
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
