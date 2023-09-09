import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:vista_app/Class/User.dart';
// import 'package:vista_app/Common/Validate.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  bool _loanding = false;
  bool _loandingCode = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formCodeKey = GlobalKey<FormState>();
  String userName = "";
  String password = "";
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
                            Theme(
                              data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.fromSwatch()
                                      .copyWith(secondary: Colors.white)),
                              child: ElevatedButton(
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
                                    if (_loanding)
                                      Container(
                                        height: 20,
                                        width: 20,
                                        margin: const EdgeInsets.only(left: 20),
                                        child:
                                            const CircularProgressIndicator(),
                                      )
                                  ],
                                ),
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
          const SizedBox(height: 50),
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
                          // onSaved: (value) => prealerta.description = value.toString(),
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
                            _code(context);
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
  void _code(BuildContext context){
    if (!_loandingCode) {
      if (_formCodeKey.currentState!.validate()) {
        _formCodeKey.currentState!.save();
        setState(() {
          _loandingCode = true;
          _errorMessage = "";
        });}
    }
  }
  void _login(BuildContext context) async {
Navigator.pushReplacementNamed(context, "encuesta");

  }

  void requestFocus(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  @override
  void initState() {
    super.initState();
    usuarioFocus = FocusNode();
    passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    usuarioFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }
}
