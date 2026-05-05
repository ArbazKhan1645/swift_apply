import 'package:flutter/material.dart';
import 'package:swift_apply/app/app.dart';
import 'package:swift_apply/app/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const SwiftApplyApp());
}
