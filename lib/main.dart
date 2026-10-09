import 'package:flutter/material.dart';
import 'package:notes_app/core/app_routes/app_rout_config.dart';
import 'package:notes_app/core/app_routes/app_rout_name.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutName.home,
      onGenerateRoute: AppRoutConfig.generateRoute,
    );
  }
}
