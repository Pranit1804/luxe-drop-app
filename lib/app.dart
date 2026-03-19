import 'package:flutter/material.dart';
import 'package:luxe_drop/core/theme/app_theme.dart';
import 'package:luxe_drop/features/flash_drop/presentation/pages/flash_drop_page.dart';

class LuxeDropApp extends StatelessWidget {
  const LuxeDropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LuxeDrop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const FlashDropPage(),
    );
  }
}
