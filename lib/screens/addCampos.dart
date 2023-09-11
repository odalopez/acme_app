import 'package:acme_app/models/campo_model.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_realtime_database_crud_tutorial/models/encuesta_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final format = DateFormat("dd/MM/yyyy");

class CamposPage extends StatefulWidget {
  final String codigo;
  CamposPage({Key? key, required this.codigo}) : super(key: key);

  @override
  State<CamposPage> createState() => _CamposPageState(this.codigo);
}

class _CamposPageState extends State<CamposPage> {
  final String codigo;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  int idCampo = 1;
  final TextEditingController _nombreCampoController = TextEditingController();
  final TextEditingController _tituloCampoController = TextEditingController();
  String tipoCampo = 'text';
  String checkedRequerido = 'true';

  List<Campo> campoList = [];

  bool updateCampo = false;
  _CamposPageState(this.codigo);

  @override
  void initState() {
    super.initState();

    retrieveCamposData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Agregar campos"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (int i = 0; i < campoList.length; i++)
              if (campoList[i].campoData!.codigo! == codigo) campoWidget(campoList[i])
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _nombreCampoController.text = "";
          _tituloCampoController.text = "";
          updateCampo = false;
          campoDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void campoDialog({String? key}) {
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
                      controller: _tituloCampoController,
                      decoration: const InputDecoration(labelText: "Título")),
                  TextField(
                    controller: _nombreCampoController,
                    decoration: const InputDecoration(labelText: "Nombre"),
                  ),
                  Row(
                    children: [
                      Expanded(flex: 3, child: Text('¿El campo es requerido?')),
                      Expanded(
                          flex: 1,
                          child: DropdownButtonFormField(
                              elevation: 2,
                              isExpanded: true,
                              items: listDdmRequerido(),
                              style: const TextStyle(color: Colors.black),
                              onSaved: (value) =>
                                  checkedRequerido = value.toString(),
                              onChanged: (value) => {
                                    setState(() {
                                      checkedRequerido = value.toString();
                                    }),
                                  },
                              value: 'true'))
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(flex: 3, child: const Text('Tipo de campo.')),
                      Expanded(
                          flex: 1,
                          child: DropdownButtonFormField(
                            elevation: 2,
                            isExpanded: true,
                            items: listDdmTipoCampo(),
                            style: const TextStyle(color: Colors.black),
                            onSaved: (value) => tipoCampo = value.toString(),
                            onChanged: (value) => {
                              setState(() {
                                tipoCampo = value.toString();
                              }),
                            },
                            value: "text",
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Map<String, dynamic> data = {
                          "codigo": codigo,
                          "idCampo": idCampo,
                          "nombre": _nombreCampoController.text.toString(),
                          "titulo": _tituloCampoController.text.toString(),
                          "requerido": checkedRequerido,
                          "tipo": tipoCampo,
                        };

                        if (updateCampo) {
                          dbRef
                              .child("Campos")
                              .child(key!)
                              .update(data)
                              .then((value) {
                            int index = campoList
                                .indexWhere((element) => element.key == key);
                            campoList.removeAt(index);
                            campoList.insert(
                                index,
                                Campo(
                                    key: key,
                                    campoData: CampoData.fromJson(data)));
                            setState(() {});
                            Navigator.of(context).pop();
                          });
                        } else {
                          idCampo = idCampo + 1;
                          dbRef.child("Campos").push().set(data).then((value) {
                            Navigator.of(context).pop();
                          });
                        }
                      },
                      child: Text(
                          updateCampo ? "Actualizar Campo" : "Guardar Campo"))
                ],
              ),
            ),
          );
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

  Widget campoWidget(Campo campo) {
      idCampo= campo.campoData!.idCampo! + 1;
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: Card(
                margin: const EdgeInsets.only(top: 5, left: 10, right: 10),
                child: campo.campoData!.tipo == 'text' ||
                        campo.campoData!.tipo == 'number'
                    ? TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: campo.campoData!.tipo == 'text'
                            ? TextInputType.text
                            : TextInputType.number,
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            labelText: campo.campoData!.titulo!,
                            hoverColor: Colors.amber),
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
                            // controller: fechaCtrl,
                            onShowPicker: (context, currentValue) {
                              return showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1995),
                                  initialDate: currentValue ?? DateTime.now(),
                                  lastDate: DateTime(
                                      2100)); /*.then((value){
                 FechaVisita= value.toString();
                    });*/
                            },
                            onSaved: (value) {
                              if (value != null) {
                                String dia = value.day.toString();
                                String mes = value.month.toString();

                                if (dia.length == 1) {
                                  dia = "0" + value.day.toString();
                                }
                                if (mes.length == 1) {
                                  mes = "0" + value.month.toString();
                                }
                                //  this.FechaVisita = value.year.toString() + "-" + mes  + "-" + dia;
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
                      ))),
        Expanded(
            flex: 1,
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                  ),
                  onPressed: () {
                    idCampo = campo.campoData!.idCampo!;
                    _nombreCampoController.text = campo.campoData!.nombre!;
                    _tituloCampoController.text = campo.campoData!.titulo!;
                    checkedRequerido = campo.campoData!.requerido!;
                    tipoCampo = campo.campoData!.tipo!;

                    updateCampo = true;
                    campoDialog(key: campo.key);
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    dbRef
                        .child("Campos")
                        .child(campo.key!)
                        .remove()
                        .then((value) {
                      int index = campoList
                          .indexWhere((element) => element.key == campo.key!);
                      campoList.removeAt(index);
                      setState(() {});
                    });
                  },
                )
              ],
            ))
      ],
    );
  }
}

List<DropdownMenuItem<String>> listDdmTipoCampo() {
  List<DropdownMenuItem<String>> lWidgets = [];
  lWidgets.add(const DropdownMenuItem(
    value: ('text'),
    child: Text(
      'Texto',
      style: TextStyle(color: Colors.black, fontSize: 14.00),
    ),
  ));
  lWidgets.add(const DropdownMenuItem(
    value: ('number'),
    child: Text(
      'Número',
      style: TextStyle(color: Colors.black, fontSize: 14.00),
    ),
  ));
  lWidgets.add(const DropdownMenuItem(
    value: ('date'),
    child: Text(
      'Fecha',
      style: TextStyle(color: Colors.black, fontSize: 14.00),
    ),
  ));

  return lWidgets;
}

List<DropdownMenuItem<String>> listDdmRequerido() {
  List<DropdownMenuItem<String>> lWidgets = [];
  lWidgets.add(const DropdownMenuItem(
    value: ('true'),
    child: Text(
      'Sí',
      style: TextStyle(color: Colors.black, fontSize: 14.00),
    ),
  ));
  lWidgets.add(const DropdownMenuItem(
    value: ('false'),
    child: Text(
      'No',
      style: TextStyle(color: Colors.black, fontSize: 14.00),
    ),
  ));

  return lWidgets;
}
