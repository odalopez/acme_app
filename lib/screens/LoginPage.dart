import 'dart:async';
import 'dart:convert';

import 'package:acme_app/models/encuesta_model.dart';
import 'package:acme_app/models/user_model.dart';
import 'package:acme_app/screens/encuesta.dart';
import 'package:acme_app/screens/llenaEncuesta.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  List<Usuario> usuarioList = [];
  List<Encuesta> encuestaList = [];
  bool _loandingCode = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formCodeKey = GlobalKey<FormState>();
  String userName = "";
  String password = "";
  String codigoEncuesta = "";
  String _errorMessage = "";
  late FocusNode usuarioFocus;
  late FocusNode passwordFocus;
  bool _obscureContrasena = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Chamitos App',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    //  padding: const EdgeInsets.symmetric(vertical: 150),
                    child: Text(
                      '¡Inicia sesión para crear encuestas!',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Colors.grey.shade800, fontSize: 18),
                    ),
                  ),
                  Center(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35, vertical: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              autocorrect: false,
                              decoration:
                                  const InputDecoration(labelText: "Usuario :"),
                              onSaved: (value) {
                                userName = value!;
                              },
                              validator: (value) {
                                if (value!.isEmpty || value == null) {
                                  return "Este campo es obligatorio";
                                } else {
                                  return null;
                                }
                              },
                              focusNode: usuarioFocus,
                              onEditingComplete: () =>
                                  requestFocus(context, passwordFocus),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Contraseña :",
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureContrasena
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureContrasena = !_obscureContrasena;
                                    });
                                  },
                                ),
                              ),
                              onSaved: (value) {
                                password = value!;
                              },
                              validator: (value) {
                                if (value!.isEmpty || value == null) {
                                  return "Este campo es obligatorio";
                                } else {
                                  return null;
                                }
                              },
                              obscureText: _obscureContrasena,
                              focusNode: passwordFocus,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade300,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                              onPressed: () {
                                _login(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Iniciar Sesión",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _registro(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Registrarse",
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 18)),
                                ],
                              ),
                            ),
                            if (_errorMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  _errorMessage,
                                  // ignore: prefer_const_constructors
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(
                              height: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            //  padding: const EdgeInsets.symmetric(vertical: 150),
            child: Text(
              '¿Ya tienes el código para entrar a una encuesta?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade800, fontSize: 18),
            ),
          ),
          Form(
              key: _formCodeKey,
              child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 35, vertical: 20),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        TextFormField(
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          textAlign: TextAlign.left,
                          onSaved: (value) => codigoEncuesta = value.toString(),
                          decoration: const InputDecoration(
                            hintText: 'Ingresa el código',
                            labelText: 'Código de encuesta',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'El código ingresado no coincide con ninguna encuesta creada';
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: () {
                            //_code(context);
                            _llenarEncuesta(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Empezar encuesta",
                                  style: TextStyle(color: Colors.white)),
                              if (_loandingCode)
                                Container(
                                  height: 20,
                                  width: 20,
                                  margin: const EdgeInsets.only(left: 20),
                                  child: const CircularProgressIndicator(),
                                )
                            ],
                          ),
                        ),
                      ]))))
        ],
      )),
    );
  }

  void _code(BuildContext context) {
    if (!_loandingCode) {
      if (_formCodeKey.currentState!.validate()) {
        _formCodeKey.currentState!.save();
        setState(() {
          _loandingCode = true;
          _errorMessage = "";
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LlenaEncuesta(
                    codigo: codigoEncuesta,
                  )),
        );
        setState(() {
          _loandingCode = false;
          _errorMessage = "";
        });
      }
    }
  }

  void _login(BuildContext context) async {
    bool existe = false;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      for (int i = 0; i < usuarioList.length; i++) {
        if (usuarioList[i].usuarioData!.usuario! == userName &&
            usuarioList[i].usuarioData!.password == generateSHA256(password)) {
          existe = true;
        }
      }
      if (existe) {
        // Navigator.pushReplacementNamed(context, "encuesta");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EncuestaPage(usuario: userName)),
        );
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                title: const Text(
                  'Credenciales inválidas',
                  textAlign: TextAlign.center,
                ),
                content: const Text(
                  'Verifica tus datos de inicio de sesión',
                  textAlign: TextAlign.center,
                ),
                actions: <Widget>[
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade300,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Intentar nuevamente',
                          textAlign: TextAlign.center,
                        )),
                  )
                ],
              );
            });
      }
    }
  }
  void _llenarEncuesta(BuildContext context) async {
    bool existe = false;
    if (_formCodeKey.currentState!.validate()) {
      _formCodeKey.currentState!.save();

      for (int i = 0; i < encuestaList.length; i++) {
        if (encuestaList[i].encuestaData!.codigo! == codigoEncuesta) {
          existe = true;
        }
      }
      if (existe) {
          Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LlenaEncuesta(
                    codigo: codigoEncuesta,
                  )),
        );
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                title: const Text(
                  'Código no válido',
                  textAlign: TextAlign.center,
                ),
                content: const Text(
                  'El código ingresado no coincide con ninguna encuesta.',
                  textAlign: TextAlign.center,
                ),
                actions: <Widget>[
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade300,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Intentar nuevamente',
                          textAlign: TextAlign.center,
                        )),
                  )
                ],
              );
            });
      }
    }
  }
  void _registro(BuildContext context) async {
    Navigator.pushReplacementNamed(context, "registro");
  }

  void requestFocus(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  @override
  void initState() {
    super.initState();
    usuarioFocus = FocusNode();
    passwordFocus = FocusNode();

    dbRef.child("Usuarios").onChildAdded.listen((data) {
      UsuarioData usuarioData =
          UsuarioData.fromJson(data.snapshot.value as Map);
      Usuario usuario =
          Usuario(key: data.snapshot.key, usuarioData: usuarioData);
      usuarioList.add(usuario);
    });

     dbRef.child("Encuestas").onChildAdded.listen((data) {
      EncuestaData encuestaData =
          EncuestaData.fromJson(data.snapshot.value as Map);
      Encuesta encuesta =
          Encuesta(key: data.snapshot.key, encuestaData: encuestaData);
      encuestaList.add(encuesta);
    });
  }

  @override
  void dispose() {
    usuarioFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }
}

String generateSHA256(String input) {
  var bytes1 = utf8.encode(input);
  var digest1 = sha256.convert(bytes1);
  var result = digest1.toString();
  return result;
}
