import 'package:flutter/material.dart';
import 'package:notes_app/core/app_routes/app_rout_name.dart';
import 'package:notes_app/core/modules/lay_out_view_feature/presentation/pages/home_screen.dart';

class AppRoutConfig {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutName.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

        default:
          return MaterialPageRoute(
            builder: (_) =>  Scaffold(
              body: Center(
                child: Text('No route for ${settings.name}'),
              ),
            ),
          );
    }
  }
}