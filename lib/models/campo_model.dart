class Campo{
  String? key;
  CampoData? campoData;

  Campo({this.key,this.campoData});
}

class CampoData{
  String? codigo;
  int? idCampo;
  String? nombre;
  String? titulo;
  String? requerido;
  String? tipo;

  CampoData({this.codigo,this.idCampo, this.nombre, this.titulo, this.requerido, this.tipo});

  CampoData.fromJson(Map<dynamic,dynamic> json){
    codigo = json["codigo"];
    idCampo = json["idCampo"];
    nombre = json["nombre"];
    titulo = json["titulo"];
    requerido = json["requerido"].toString();
    tipo = json["tipo"];
  }
}