import 'package:flutter/material.dart';
import 'package:flutter_application_1/pagina_login/Login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugInvertOversizedImages = false;
    return const MaterialApp(
      home: Login(),
    );
  }
}
