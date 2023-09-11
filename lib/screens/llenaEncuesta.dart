import 'package:acme_app/models/encuesta_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

String nombreEncuesta = "";
String descripcionEncuesta = "";

final format = DateFormat("dd/MM/yyyy");

class LlenaEncuesta extends StatefulWidget {
  final String codigo;

  LlenaEncuesta({Key? key, required this.codigo}) : super(key: key);

  @override
  State<LlenaEncuesta> createState() => _LlenaEncuestaState(this.codigo);
}

class _LlenaEncuestaState extends State<LlenaEncuesta> {
  final String codigo;
  DatabaseReference dbRef = FirebaseDatabase.instance.reference();

  List<Campo> campoList = [];

  bool updateCampo = false;
  _LlenaEncuestaState(this.codigo);

  Map<String?, dynamic> valoresCampos = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    retrieveEncuestaData();
    retrieveCamposData();
    valoresCampos['codigo'] = codigo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Llenar encuesta"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 15,
          ),
          Text(nombreEncuesta,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(descripcionEncuesta, style: const TextStyle(fontSize: 18)),
          SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    for (int i = 0; i < campoList.length; i++)
                      if (campoList[i].campoData!.codigo! == codigo)
                        campoWidget(campoList[i])
                  ],
                )),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                dbRef
                    .child("Resultados")
                    .push()
                    .set(valoresCampos)
                    .then((value) {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          title: Text('Exito',textAlign: TextAlign.center,),
                          content: Text('Datos enviados correctamente'),
                          actions: <Widget>[
                            Container(
                                child: Center(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    textStyle: TextStyle(fontSize: 15),                                  
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50.0)),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Ok',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )),
                            ))
                          ],
                        );
                      });
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al enviar datos: $error')),
                  );
                });
              }
            },
            child: const Text("Enviar datos"),
          )
        ],
      ),
    );
  }

  void retrieveCamposData() {
    dbRef.child("Campos").onChildAdded.listen((data) {
      CampoData encuestaData = CampoData.fromJson(data.snapshot.value as Map);
      Campo encuesta = Campo(key: data.snapshot.key, campoData: encuestaData);
      campoList.add(encuesta);
      setState(() {});
    });
  }

  void retrieveEncuestaData() {
    dbRef.child("Encuestas").onChildAdded.listen((data) {
      EncuestaData encuestaData =
          EncuestaData.fromJson(data.snapshot.value as Map);
      Encuesta encuesta =
          Encuesta(key: data.snapshot.key, encuestaData: encuestaData);
      if (encuesta.encuestaData?.codigo == codigo) {
        nombreEncuesta = encuesta.encuestaData!.nombre!;
        descripcionEncuesta = encuesta.encuestaData!.descripcion!;
      }
      setState(() {});
    });
  }

  Widget campoWidget(Campo campo) {
    String? idCampo = campo.key;
    TextEditingController controller = TextEditingController();
    DateTime? selectedDate;

    controller.addListener(() {
      String? nombreCampo = campo.campoData!.nombre;
      valoresCampos[nombreCampo] = controller.text;
    });

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Card(
            margin: const EdgeInsets.only(top: 5, left: 10, right: 10),
            child: campo.campoData!.tipo == 'text' ||
                    campo.campoData!.tipo == 'number'
                ? TextFormField(
                    controller: controller,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: campo.campoData!.tipo == 'text'
                        ? TextInputType.text
                        : TextInputType.number,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      labelText: campo.campoData!.titulo!,
                      hoverColor: Colors.amber,
                    ),
                    validator: (value) {
                      if (campo.campoData!.requerido == 'true' &&
                          value!.isEmpty) {
                        return "Campo obligatorio";
                      } else {
                        return null;
                      }
                    },
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campo.campoData!.titulo!,
                        style: TextStyle(
                          color: Colors.black45,
                        ),
                      ),
                      DateTimeField(
                        format: format,
                        onShowPicker: (context, currentValue) {
                          return showDatePicker(
                            context: context,
                            firstDate: DateTime(1995),
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                        },
                        onSaved: (value) {
                          if (value != null) {
                            String dia = value.day.toString();
                            String mes = value.month.toString();

                            if (dia.length == 1) {
                              dia = "0${value.day}";
                            }
                            if (mes.length == 1) {
                              mes = "0${value.month}";
                            }

                            String? nombreCampo = campo.campoData!.nombre;
                            valoresCampos[nombreCampo] =
                                value.toLocal().toString();
                          }
                        },
                        validator: (value) {
                          if (campo.campoData!.requerido == 'true' &&
                              value == null) {
                            return "Campo obligatorio";
                          } else {
                            return null;
                          }
                        },
                      )
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class Campo {
  String? key;
  CampoData? campoData;

  Campo({this.key, this.campoData});
}

class CampoData {
  String? codigo;
  String? titulo;
  String? tipo;
  String? requerido;
  String? nombre;

  CampoData({this.codigo, this.titulo, this.tipo, this.requerido, this.nombre});

  CampoData.fromJson(Map<dynamic, dynamic> json) {
    codigo = json["codigo"];
    titulo = json["titulo"];
    tipo = json["tipo"];
    requerido = json["requerido"];
    nombre = json["nombre"];
  }
}
