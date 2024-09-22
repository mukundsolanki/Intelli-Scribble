import 'package:flutter/material.dart';
import 'package:intelliscribble/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_credentials.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseCredentials.url,
    anonKey: SupabaseCredentials.anonKey,
  );

  runApp(DrawingBoardApp());
}

class DrawingBoardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}
