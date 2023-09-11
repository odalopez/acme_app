import 'package:acme_app/models/campo_model.dart';
import 'package:acme_app/models/encuesta_model.dart';
import 'package:acme_app/screens/addCampos.dart';
import 'package:acme_app/screens/resultado.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_realtime_database_crud_tutorial/models/encuesta_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EncuestaPage extends StatefulWidget {
  final String usuario;
  const EncuestaPage({Key? key, required this.usuario}) : super(key: key);

  @override
  State<EncuestaPage> createState() => _EncuestaPageState(this.usuario);
}

class _EncuestaPageState extends State<EncuestaPage> {
  final String usuario;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  final TextEditingController _nombreEncuestaController =
      TextEditingController();
  final TextEditingController _descripcionEncuestaController =
      TextEditingController();

  List<Encuesta> encuestaList = [];
  List<Campo> campoList = [];

  bool updateEncuesta = false;
  _EncuestaPageState(this.usuario);
  @override
  void initState() {
    super.initState();

    retrieveEncuestaData();
    retrieveCamposData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Mis Encuestas"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/");
            },
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (int i = 0; i < encuestaList.length; i++)
              if (encuestaList[i].encuestaData!.usuario! == usuario)
                encuestaWidget(encuestaList[i])
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _nombreEncuestaController.text = "";
          _descripcionEncuestaController.text = "";
          updateEncuesta = false;

          EncuestaData encuestaData = EncuestaData(
            nombre: "",
            codigo: "",
            descripcion: "",
          );
          Encuesta encuestaDatos = Encuesta(
            encuestaData: encuestaData,
          );
          encuestaDialog(encuesta: encuestaDatos);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void encuestaDialog({String? key, required Encuesta encuesta}) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nombreEncuestaController,
                    decoration: const InputDecoration(labelText: "Nombre"),
                  ),
                  TextField(
                      controller: _descripcionEncuestaController,
                      decoration:
                          const InputDecoration(labelText: "Descripción")),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(children: [
                    SizedBox(width: 20),
                    Expanded(
                        flex: 1,
                        child: updateEncuesta
                            ? ElevatedButton(
                                onPressed: () {
                                  Map<String, dynamic> data1 = {
                                    "nombre": _nombreEncuestaController.text
                                        .toString(),
                                    "codigo": encuesta.encuestaData!.codigo,
                                    "descripcion":
                                        _descripcionEncuestaController.text
                                            .toString(),
                                    "usuario": usuario
                                  };
                                  dbRef
                                      .child("Encuestas")
                                      .child(key!)
                                      .update(data1)
                                      .then((value) {
                                    int index = encuestaList.indexWhere(
                                        (element) => element.key == key);
                                    encuestaList.removeAt(index);
                                    encuestaList.insert(
                                        index,
                                        Encuesta(
                                            key: key,
                                            encuestaData:
                                                EncuestaData.fromJson(data1)));
                                    setState(() {});
                                    Navigator.of(context).pop();
                                  });
                                },
                                child: const Text("Actualizar datos"))
                            : ElevatedButton(
                                onPressed: () {
                                  var codigo = generarCodigo();
                                  Map<String, dynamic> data = {
                                    "nombre": _nombreEncuestaController.text
                                        .toString(),
                                    "codigo": codigo,
                                    "descripcion":
                                        _descripcionEncuestaController.text
                                            .toString(),
                                    "usuario": usuario
                                  };

                                  dbRef
                                      .child("Encuestas")
                                      .push()
                                      .set(data)
                                      .then((value) {
                                    // Navigator.of(context).pop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CamposPage(
                                                codigo: codigo,
                                              )),
                                    );
                                  });
                                },
                                child: Text("Guardar"))),
                    SizedBox(width: 20),
                    if (updateEncuesta)
                      Expanded(
                          flex: 1,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CamposPage(
                                            codigo:
                                                encuesta.encuestaData!.codigo!,
                                          )),
                                );
                              },
                              child: Text("Ver campos")))
                  ]),
                  if (updateEncuesta)
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VerResultados(
                                      codigo: encuesta.encuestaData!.codigo!,
                                      nombre: encuesta.encuestaData!.nombre!,
                                    )),
                          );
                        },
                        child: Text("Ver Resultados"))
                ],
              ),
            ),
          );
        });
  }

  void retrieveEncuestaData() {
    dbRef.child("Encuestas").onChildAdded.listen((data) {
      EncuestaData encuestaData =
          EncuestaData.fromJson(data.snapshot.value as Map);
      Encuesta encuesta =
          Encuesta(key: data.snapshot.key, encuestaData: encuestaData);
      encuestaList.add(encuesta);
      setState(() {});
    });
  }

  void retrieveCamposData() {
    dbRef.child("Campos").onChildAdded.listen((data) {
      CampoData encuestaData = CampoData.fromJson(data.snapshot.value as Map);
      Campo encuesta = Campo(key: data.snapshot.key, campoData: encuestaData);
      campoList.add(encuesta);
      setState(() {});
    });
  }

  Widget encuestaWidget(Encuesta encuesta) {
    return InkWell(
      onTap: () {
        _nombreEncuestaController.text = encuesta.encuestaData!.nombre!;
        _descripcionEncuestaController.text =
            encuesta.encuestaData!.descripcion!;
        updateEncuesta = true;
        encuestaDialog(key: encuesta.key, encuesta: encuesta);
      },
      child: Card(
          child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.only(top: 5, left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Código de encuesta: ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 15),
                    children: <TextSpan>[
                      TextSpan(
                          text: encuesta.encuestaData!.codigo,
                          style:
                              const TextStyle(fontWeight: FontWeight.normal)),
                      const TextSpan(
                        text: '\nNombre: ',
                      ),
                      TextSpan(
                          text: encuesta.encuestaData!.nombre,
                          style:
                              const TextStyle(fontWeight: FontWeight.normal)),
                      const TextSpan(
                        text: '\nDescripción: ',
                      ),
                      TextSpan(
                          text: encuesta.encuestaData!.descripcion,
                          style:
                              const TextStyle(fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
              ],
            ),
            InkWell(
                onTap: () {
                  for (int i = 0; i < campoList.length; i++)
                    if (campoList[i].campoData!.codigo! ==
                        encuesta.encuestaData!.codigo) {
                      dbRef
                          .child("Campos")
                          .child(campoList[i].key!)
                          .remove()
                          .then((value) {
                        int index = campoList.indexWhere(
                            (element) => element.key == campoList[i].key!);
                        campoList.removeAt(index);
                        setState(() {});
                      });
                    }

                  dbRef
                      .child("Encuestas")
                      .child(encuesta.key!)
                      .remove()
                      .then((value) {
                    int index = encuestaList
                        .indexWhere((element) => element.key == encuesta.key!);
                    encuestaList.removeAt(index);
                    setState(() {});
                  });
                },
                child: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ))
          ],
        ),
      )),
    );
  }
}

generarCodigo() {
  var now = DateTime.now();
  var formatter = DateFormat('yyyyMMddHHmmss');
  String codigo = formatter.format(now);
  return codigo;
}
