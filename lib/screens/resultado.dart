import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class VerResultados extends StatefulWidget {
  final String codigo;
  final String nombre;
  VerResultados({Key? key, required this.codigo, required this.nombre})
      : super(key: key);

  @override
  _VerResultadosState createState() =>
      _VerResultadosState(this.codigo, this.nombre);
}

class _VerResultadosState extends State<VerResultados> {
  final String codigo;
  final String nombre;
  DatabaseReference dbRef = FirebaseDatabase.instance.reference();
  List<Resultado> resultadosList = [];

  _VerResultadosState(this.codigo, this.nombre);

  @override
  void initState() {
    super.initState();
    retrieveResultadosData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Resultados de encuesta"),
        ),
        body: Column(
          children: [
            const SizedBox(height: 15),
            Text('Encuesta $nombre',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Expanded(
                child: ListView.builder(
              itemCount: resultadosList.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Respuesta ${index + 1}"),
                      for (var entry in resultadosList[index].data.entries)
                        if (entry.key != 'codigo')
                          RichText(
                            text: TextSpan(
                              text: '${entry.key}: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 15),
                              children: <TextSpan>[
                                TextSpan(
                                    text: entry.value.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                    ],
                  ),
                );
              },
            )),
          ],
        ));
  }

  void retrieveResultadosData() {
    dbRef.child("Resultados").onChildAdded.listen((data) {
      Resultado resultado = Resultado.fromJson(data.snapshot.value as Map);
      if (resultado.codigo == codigo) {
        resultadosList.add(resultado);
        setState(() {});
      }
    });
  }
}

class Resultado {
  String? codigo;
  late Map<String, dynamic> data;

  Resultado({this.codigo, Map<String, dynamic>? jsonData}) {
    data = jsonData ?? {};
  }

  Resultado.fromJson(Map<dynamic, dynamic> json) {
    codigo = json["codigo"];
    data = Map<String, dynamic>.from(json);
  }
}
