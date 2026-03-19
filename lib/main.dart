import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luxe_drop/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Eagerly load Google Fonts BEFORE the first frame.
  // Without awaiting, fonts download async and cause re-layout jank
  // when they resolve mid-render.
  await GoogleFonts.pendingFonts([
    GoogleFonts.playfairDisplay(),
    GoogleFonts.inter(),
  ]);

  runApp(const LuxeDropApp());
}

