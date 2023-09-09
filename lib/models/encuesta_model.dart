class Encuesta{
  String? key;
  EncuestaData? encuestaData;

  Encuesta({this.key,this.encuestaData});
}

class EncuestaData{
  String? nombre;
  String? codigo;
  String? descripcion;

  EncuestaData({this.nombre,this.codigo,this.descripcion});

  EncuestaData.fromJson(Map<dynamic,dynamic> json){
    nombre = json["nombre"];
    codigo = json["codigo"];
    descripcion = json["descripcion"];
  }
}