import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Adicionado
import 'app/app.dart';
import 'firebase_options.dart'; // Adicionado

void main() async {
  // Garante que o Flutter inicialize os recursos nativos antes do Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as configurações geradas pelo FlutterFire
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GoSchoolApp());
}
