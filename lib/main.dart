import 'package:acme_app/screens/LoginPage.dart';
import 'package:acme_app/screens/addCampos.dart';
import 'package:acme_app/screens/encuesta.dart';
import 'package:acme_app/screens/llenaEncuesta.dart';
import 'package:acme_app/screens/registro.dart';
import 'package:acme_app/screens/resultado.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chamitos',
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(builder: (BuildContext context) {
          switch (settings.name) {
            case "/":
              return const LoginPage();
            case "registro":
              return const Registro();
            case "encuesta":
              return const EncuestaPage(usuario: '',);
            case "campos":
              return  CamposPage(codigo: '',);
            case "llenaEncuesta":
              return  LlenaEncuesta(codigo: '',);
             case "resultados":
              return  VerResultados(codigo: '', nombre: '',);
            default:
              return const LoginPage();
            // case "/home":
            //   User userLoggend = settings.arguments;
            //   return HomePage(userLoggend);
          }
        });
      },
    );
  }
}
