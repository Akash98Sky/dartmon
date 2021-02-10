import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

import 'package:ansicolor/ansicolor.dart';

AnsiPen green = AnsiPen()..green(bold: true);
AnsiPen blue = AnsiPen()..blue();
AnsiPen red = AnsiPen()..red();

List<String> ignores;

bool isIgnore(String entityPath) => ignores.any(
      (ignore) => ignore.isEmpty ? false : path.equals(ignore, entityPath),
    );

Stream<FileSystemEntity> listEntities(FileSystemEntity parent) async* {
  if (parent is Directory) {
    yield parent;
    await for (final entity in parent.list(followLinks: false)) {
      if (!isIgnore(entity.path)) {
        yield* listEntities(entity);
      }
    }
  }
}

String get time => DateTime.now().toLocal().toString().split(' ').last;

Future<void> main(List<String> arguments) async {
  Process lastProcess;
  Timer timer;
  final filename = arguments.isNotEmpty ? arguments[0] : './main.dart';
  var debug = false;

  if (arguments.contains('--debug')) debug = true;

  if (!File(filename).existsSync()) {
    print(red('File ${filename} not found.'));
    exit(1);
  }

  // Load ignore list
  ignores = await File('.gitignore').readAsLines();
  ignores.addAll(['.git', '.gitignore']);

  void startProcess(String reason) async {
    lastProcess?.kill();

    print(green(reason));
    lastProcess = await Process.start('dart', [filename, ...arguments.skip(1)]);

    lastProcess.stdout.transform(utf8.decoder).listen((data) {
      print(data.trim());
    });

    lastProcess.stderr.transform(utf8.decoder).listen((data) {
      print(data.trim());
    });
  }

  void addWatcher(FileSystemEntity entity) async {
    if (debug) print(blue('Watching on ${entity.path}...'));
    final stream = entity.watch();

    await for (var event in stream) {
      if (event.type == FileSystemEvent.create && event.isDirectory) {
        if (!isIgnore(event.path)) addWatcher(Directory(event.path));
      } else {
        if (timer != null && timer.isActive) timer.cancel();

        timer = Timer(
          const Duration(milliseconds: 300),
          () => startProcess(
              '\n[ $time ] >>> Found changes in ${event.path}. Reloading...'),
        );
      }
    }
  }

  startProcess('[ $time ] >>> Running $filename...');

  listEntities(Directory(path.current)).listen(addWatcher);
}
