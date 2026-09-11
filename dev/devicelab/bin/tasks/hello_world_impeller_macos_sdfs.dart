// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_devicelab/framework/devices.dart';
import 'package:flutter_devicelab/framework/framework.dart';
import 'package:flutter_devicelab/framework/task_result.dart';
import 'package:flutter_devicelab/framework/utils.dart';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart';

<<<<<<< HEAD
Future<TaskResult> run() async {
  deviceOperatingSystem = DeviceOperatingSystem.macos;

  final Directory appDir = dir(path.join(flutterDirectory.path, 'examples/hello_world'));
=======
Future<void> _runDefaultTest() async {
  // Test running by default. Since macOS always uses SDF rendering when Impeller is enabled,
  // we should see "Using the Impeller rendering backend (MetalSDF)." in the output by default.
  final Process process = await startFlutter('run', options: <String>['-d', 'macos']);

  final completer = Completer<void>();
  var sawMetalSdfsMessage = false;

  final StreamSubscription<String> subscription = process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((String line) {
        print('[STDOUT]: $line');
        if (line.contains('Using the Impeller rendering backend (MetalSDF).')) {
          sawMetalSdfsMessage = true;
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      });

  await Future.any(<Future<void>>[
    completer.future,
    Future<void>.delayed(const Duration(minutes: 2)),
  ]);

  process.stdin.writeln('q');
  await process.exitCode;
  await subscription.cancel();

  if (!sawMetalSdfsMessage) {
    throw StateError('Did not see "Using the Impeller rendering backend (MetalSDF)." in output');
  }
}

Future<void> _runNoEnableImpellerTest() async {
  // Test running with --no-enable-impeller. Since macOS uses Skia when Impeller is disabled,
  // we should see "Using the Skia rendering backend (Metal)." in the output.
  final Process process = await startFlutter(
    'run',
    options: <String>['--no-enable-impeller', '-d', 'macos'],
  );

  final completer = Completer<void>();
  var sawSkiaMessage = false;

  final StreamSubscription<String> subscription = process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((String line) {
        print('[STDOUT 2]: $line');
        if (line.contains('Using the Skia rendering backend (Metal).')) {
          sawSkiaMessage = true;
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      });

  await Future.any(<Future<void>>[
    completer.future,
    Future<void>.delayed(const Duration(minutes: 2)),
  ]);

  process.stdin.writeln('q');
  await process.exitCode;
  await subscription.cancel();

  if (!sawSkiaMessage) {
    throw StateError(
      'Did not see "Using the Skia rendering backend (Metal)." in output when --no-enable-impeller was passed',
    );
  }
}

Future<void> _runPlistDisabledTest(Directory appDir) async {
>>>>>>> e8113bf45620cbeb8aff64947ee4c93e16adb4cf
  final String plistPath = path.join(appDir.path, 'macos', 'Runner', 'Info.plist');
  final plistFile = File(plistPath);

  if (!plistFile.existsSync()) {
<<<<<<< HEAD
    return TaskResult.failure('Info.plist not found at $plistPath');
  }

  var res = TaskResult.success(null);

  try {
    await inDirectory(appDir, () async {
      await flutter('packages', options: <String>['get']);

      // Step 1: Test without flag
      final Process process1 = await startFlutter(
        'run',
        options: <String>['--enable-impeller', '-d', 'macos'],
      );

      final completer1 = Completer<void>();
      var sawMetalMessage = false;

      final StreamSubscription<String> subscription1 = process1.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((String line) {
            print('[STDOUT 1]: $line');
            if (line.contains('Using the Impeller rendering backend (Metal).')) {
              sawMetalMessage = true;
              if (!completer1.isCompleted) {
                completer1.complete();
              }
            }
          });

      await Future.any(<Future<void>>[
        completer1.future,
        Future<void>.delayed(const Duration(minutes: 2)),
      ]);

      process1.stdin.writeln('q');
      await process1.exitCode;
      await subscription1.cancel();

      if (!sawMetalMessage) {
        res = TaskResult.failure(
          'Did not see "Using the Impeller rendering backend (Metal)." in output',
        );
        return; // Exit early if first step fails
      }

      // Step 2: Modify Info.plist to enable SDFS
      final String xmlStr = plistFile.readAsStringSync();
      final xmlDoc = XmlDocument.parse(xmlStr);
      final XmlElement dictNode = xmlDoc.findAllElements('dict').first;

      dictNode.children.add(
        XmlElement(XmlName('key'), <XmlAttribute>[], <XmlNode>[
          XmlText('FLTEnableSDFs'),
        ], /*isSelfClosing=*/ false),
      );
      dictNode.children.add(XmlElement(XmlName('true')));

      plistFile.writeAsStringSync(xmlDoc.toXmlString(pretty: true, indent: '    '));

      // Run again with flag
      final Process process2 = await startFlutter(
        'run',
        options: <String>['--enable-impeller', '-d', 'macos'],
      );

      final completer2 = Completer<void>();
      var sawSdfsMessage = false;

      final StreamSubscription<String> subscription2 = process2.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((String line) {
            print('[STDOUT 2]: $line');
            if (line.contains('Using the Impeller rendering backend (MetalSDF).')) {
              sawSdfsMessage = true;
              if (!completer2.isCompleted) {
                completer2.complete();
              }
            }
          });

      await Future.any(<Future<void>>[
        completer2.future,
        Future<void>.delayed(const Duration(minutes: 2)),
      ]);

      process2.stdin.writeln('q');
      await process2.exitCode;
      await subscription2.cancel();

      if (!sawSdfsMessage) {
        res = TaskResult.failure(
          'Did not see "Using the Impeller rendering backend (MetalSDF)." in output',
        );
      }
    });
  } catch (e) {
    res = TaskResult.failure('Test failed with exception: $e');
=======
    throw StateError('Info.plist not found at $plistPath');
  }

  try {
    // Modify Info.plist to set FLTEnableImpeller to false
    final String xmlStr = plistFile.readAsStringSync();
    final xmlDoc = XmlDocument.parse(xmlStr);
    final XmlElement dictNode = xmlDoc.findAllElements('dict').first;

    dictNode.children.add(
      XmlElement(XmlName('key'), <XmlAttribute>[], <XmlNode>[
        XmlText('FLTEnableImpeller'),
      ], /*isSelfClosing=*/ false),
    );
    dictNode.children.add(XmlElement(XmlName('false')));

    plistFile.writeAsStringSync(xmlDoc.toXmlString(pretty: true, indent: '    '));

    // Test running with FLTEnableImpeller set to false in Info.plist.
    // Since macOS should respect the Info.plist setting and disable Impeller,
    // we should see "Using the Skia rendering backend (Metal)." in the output by default.
    final Process process = await startFlutter('run', options: <String>['-d', 'macos']);

    final completer = Completer<void>();
    var sawSkiaMessage = false;

    final StreamSubscription<String> subscription = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((String line) {
          print('[STDOUT 3]: $line');
          if (line.contains('Using the Skia rendering backend (Metal).')) {
            sawSkiaMessage = true;
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        });

    await Future.any(<Future<void>>[
      completer.future,
      Future<void>.delayed(const Duration(minutes: 2)),
    ]);

    process.stdin.writeln('q');
    await process.exitCode;
    await subscription.cancel();

    if (!sawSkiaMessage) {
      throw StateError(
        'Did not see "Using the Skia rendering backend (Metal)." in output when FLTEnableImpeller was set to false in Info.plist',
      );
    }
>>>>>>> e8113bf45620cbeb8aff64947ee4c93e16adb4cf
  } finally {
    // Restore Info.plist
    if (plistFile.existsSync()) {
      await exec('git', <String>['checkout', plistPath]);
    }
  }
<<<<<<< HEAD

  return res;
=======
}

Future<TaskResult> run() async {
  deviceOperatingSystem = DeviceOperatingSystem.macos;

  final Directory appDir = dir(path.join(flutterDirectory.path, 'examples/hello_world'));

  try {
    await inDirectory(appDir, () async {
      await flutter('packages', options: <String>['get']);
      await _runDefaultTest();
      await _runNoEnableImpellerTest();
      await _runPlistDisabledTest(appDir);
    });
    return TaskResult.success(null);
  } catch (e) {
    return TaskResult.failure('Test failed with exception: $e');
  }
>>>>>>> e8113bf45620cbeb8aff64947ee4c93e16adb4cf
}

Future<void> main() async {
  await task(run);
}
