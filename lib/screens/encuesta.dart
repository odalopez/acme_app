import 'package:acme_app/models/encuesta_model.dart';
import 'package:acme_app/screens/addCampos.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_realtime_database_crud_tutorial/models/encuesta_model.dart';
import 'package:flutter/material.dart';

class EncuestaPage extends StatefulWidget {
  const EncuestaPage({Key? key}) : super(key: key);

  @override
  State<EncuestaPage> createState() => _EncuestaPageState();
}

class _EncuestaPageState extends State<EncuestaPage> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  final TextEditingController _nombreEncuestaController =
      TextEditingController();
  final TextEditingController _idEncuestaController = TextEditingController();
  final TextEditingController _descripcionEncuestaController =
      TextEditingController();

  List<Encuesta> encuestaList = [];

  bool updateEncuesta = false;

  @override
  void initState() {
    super.initState();

    retrieveEncuestaData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Encuestas"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (int i = 0; i < encuestaList.length; i++)
              encuestaWidget(encuestaList[i])
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _nombreEncuestaController.text = "";
          _idEncuestaController.text = "";
          _descripcionEncuestaController.text = "";
          updateEncuesta = false;
          encuestaDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void encuestaDialog({String? key}) {
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
                      controller: _idEncuestaController,
                      decoration: const InputDecoration(helperText: "Codigo")),
                  TextField(
                    controller: _nombreEncuestaController,
                    decoration: const InputDecoration(helperText: "Nombre"),
                  ),
                  TextField(
                      controller: _descripcionEncuestaController,
                      decoration:
                          const InputDecoration(helperText: "Descripción")),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(children: [
                    Expanded(
                        flex: 1,
                        child: ElevatedButton(
                            onPressed: () {
                              Map<String, dynamic> data = {
                                "nombre":
                                    _nombreEncuestaController.text.toString(),
                                "codigo": _idEncuestaController.text.toString(),
                                "descripcion": _descripcionEncuestaController
                                    .text
                                    .toString()
                              };

                              if (updateEncuesta) {
                                dbRef
                                    .child("Encuestas")
                                    .child(key!)
                                    .update(data)
                                    .then((value) {
                                  int index = encuestaList.indexWhere(
                                      (element) => element.key == key);
                                  encuestaList.removeAt(index);
                                  encuestaList.insert(
                                      index,
                                      Encuesta(
                                          key: key,
                                          encuestaData:
                                              EncuestaData.fromJson(data)));
                                  setState(() {});
                                  Navigator.of(context).pop();
                                });
                              } else {
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
                                              codigo: '123',
                                            )),
                                  );
                                });
                              }
                            },
                            child: Text(updateEncuesta
                                ? "Actualizar datos"
                                : "Guardar"))),
                               SizedBox(width: 20,),
                    Expanded(
                        flex: 1,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CamposPage(
                                          codigo: _idEncuestaController.text
                                              .toString(),
                                        )),
                              );
                            },
                            child: Text("Ver campos")))
                  ]),
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

  Widget encuestaWidget(Encuesta encuesta) {
    return InkWell(
      onTap: () {
        _nombreEncuestaController.text = encuesta.encuestaData!.nombre!;
        _idEncuestaController.text = encuesta.encuestaData!.codigo!;
        _descripcionEncuestaController.text =
            encuesta.encuestaData!.descripcion!;
        updateEncuesta = true;
        encuestaDialog(key: encuesta.key);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.only(top: 5, left: 10, right: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.description),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(encuesta.encuestaData!.codigo!),
                Text(encuesta.encuestaData!.nombre!),
                Text(encuesta.encuestaData!.descripcion!),
              ],
            ),
            InkWell(
                onTap: () {
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
      ),
    );
  }
}
