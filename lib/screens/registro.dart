import 'dart:convert';

import 'package:acme_app/models/campo_model.dart';
import 'package:acme_app/models/encuesta_model.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Registro extends StatefulWidget {
  const Registro({Key? key}) : super(key: key);

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final GlobalKey<FormState> _formRegistro = GlobalKey<FormState>();
  bool _hidePassword = true;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<Encuesta> encuestaList = [];
  List<Campo> campoList = [];

  bool updateEncuesta = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrate"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
             Navigator.pushReplacementNamed(context, "/");
          },
        )
      ),
      body: SingleChildScrollView(
        child: Form(
            key: _formRegistro,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: _usuarioField(),
                ),
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: _passwordField(),
                ),
                const SizedBox(height: 50),
                _saveButton()
              ],
            )),
      ),
    );
  }

  Widget _usuarioField() {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      onSaved: (value) => _usuarioController.text = value.toString(),
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
          labelText: 'Usuario:',
          icon:  Icon(
            Icons.person,
          ),
          labelStyle: TextStyle(color: Colors.black, fontSize: 15)),
      validator: (value) {
        if (value!.isEmpty) {
          return "Ingresa el usuario";
        } else {
          return null;
        }
      },
    );
  }

  Widget _passwordField() {
    return TextFormField(
      obscureText: _hidePassword,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.text,
      onSaved: (value) => _passwordController.text = value.toString(),
      decoration: InputDecoration(
        labelText: 'Contraseña:',
        icon: const Icon(
            Icons.security,
          ),
        suffixIcon: IconButton(
          icon: Icon(
            _hidePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _hidePassword = !_hidePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "Ingresa la contraseña";
        } else {
          return null;
        }
      },
    );
  }

  Widget _saveButton() {
    return ElevatedButton(
        onPressed: () {
          if (_formRegistro.currentState!.validate()) {
            _formRegistro.currentState!.save();

            Map<String, dynamic> data = {
              "usuario": _usuarioController.text.toString(),
              "password": generateSHA256(_passwordController.text.toString())
            };

            dbRef.child("Usuarios").push().set(data).then((value) {});
              Navigator.pushReplacementNamed(context, "/");
          }
        },
        child: const Text("Registrarme"));
  }
}

String generateSHA256(String input) {
  var bytes1 = utf8.encode(input);
  var digest1 = sha256.convert(bytes1);
  var result = digest1.toString();
  return result;
}
