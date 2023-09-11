class Usuario{
  String? key;
  UsuarioData? usuarioData;

  Usuario({this.key,this.usuarioData});
}

class UsuarioData{
  String? usuario;
  String? password;
  String? descripcion;

  UsuarioData({this.usuario,this.password,this.descripcion});

  UsuarioData.fromJson(Map<dynamic,dynamic> json){
    usuario = json["usuario"];
    password = json["password"];
    descripcion = json["descripcion"];
  }
}