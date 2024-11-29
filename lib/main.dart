import 'package:flutter/material.dart';

///import 'package:shared_preferences/shared_preferences.dart';
import 'features/presentation/pages/views.dart';

///import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/core.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegúrate de inicializar los bindings
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,//pal banner debug feo ese
      title: 'Oirs UTEM',
      theme: AppTheme.getLight(context),
      darkTheme: AppTheme.getDark(context),
      home: const LoginPage(),
    );
  }
}
