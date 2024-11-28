import 'package:appcm202402/NOTMODULARIZED/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase core package
import 'NOTMODULARIZED/utils/user_data.dart'; // UserModel

void main() async {
  // Asegúrate de inicializar los bindings de Flutter antes de Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase antes de correr la aplicación
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oirs UTEM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
