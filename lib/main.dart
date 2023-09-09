import 'package:acme_app/screens/LoginPage.dart';
import 'package:acme_app/screens/addCampos.dart';
import 'package:acme_app/screens/encuesta.dart';
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
            case "encuesta":
              return const EncuestaPage();
            case "campos":
              return  CamposPage(codigo: '',);
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
