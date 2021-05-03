import 'package:delivery/auxiliar/import.dart';

class UserOki {

  //region Variaveis
  static const String TAG = 'UserOki';

  UserDados _dados;

  int _acessoEspecial = 0;
  String _dataAlteracao;
  //endregion

  //region Construtores

  UserOki([this._dados]);

  UserOki.fromJson(Map map) {
    try {
      if(map == null) return;

      if (_mapNotNull(map['dataAlteracao']))
        dataAlteracao = map['dataAlteracao'];

      if (_mapNotNull(map['_dados']))
        dados = UserDados.fromJson(map['_dados']);

    } catch (e) {
      Log.e(TAG, 'User.fromJson', e);
    }
  }

  Map<String, dynamic> toJson() => {
    "_dados": dados.toJson(),
    "dataAlteracao": dataAlteracao,
  };

  static Map<String, UserOki> fromJsonList(Map map) {
    Map<String, UserOki> items = Map();
    if (map == null)
      return items;
    for (String key in map.keys)
      items[key] = UserOki.fromJson(map[key]);
    return items;
  }

  //endregion

  //region Metodos

  static bool _mapNotNull(dynamic value) => value != null;

  void complete(UserOki user) {
    if (user == null) return;

    int compare = dataAlteracao.compareTo(user.dataAlteracao);
    if (compare > 0) {
      saveExternalData();
    } else if (compare < 0) {
      dataAlteracao = user.dataAlteracao;
    }
  }

  Future<bool> checkSpecialAcess() async {
    try {
      var snapshot = await FirebaseOki.database
          .child(FirebaseChild.ACESSO_ESPECIAL)
          .once();

      Map<dynamic, dynamic> map = snapshot.value;
      Map usersId = Map();

      for (dynamic key in map.keys)
        usersId[key] = map[key];

      if (usersId.containsKey(dados.id))
        _acessoEspecial = map[dados.id];

      return true;
    } catch (e) {
      Log.e(TAG, 'checkSpecialAcess', e);
      return false;
    }
  }

  Future<bool> setSpecialAcesso(int value, {bool save = true}) async {
    try {
      if (save) {
        await FirebaseOki.database
            .child(FirebaseChild.ACESSO_ESPECIAL)
            .child(dados.id)
            .set(value);

        Log.d(TAG, 'setSpecialAcesso', 'OK', value);
      }
      _acessoEspecial = value;
      return true;
    } catch(e) {
      Log.e(TAG, 'setSpecialAcesso fail', e);
      return false;
    }
  }

  bool saveDataAlteracao() {
    try {
      FirebaseOki.database
          .child(FirebaseChild.USUARIO)
          .child(dados.id)
          .child(FirebaseChild.DATA_ALTERACAO)
          .set(dataAlteracao);

      Log.d(TAG, 'saveDataAlteracao', 'OK');
      return true;
    } catch (e) {
      Log.e(TAG, 'saveDataAlteracao fail 2', e);
      return false;
    }
  }

  Future<bool> saveExternalData() async {
    try {
      var result = await FirebaseOki.database
          .child(FirebaseChild.USUARIO)
          .child(dados.id)
          .set(toJson()).then((value) {
        Log.d(TAG, 'saveExternalData', 'OK');
        Config.ultimoBackup = dataAlteracao;
        return true;
      }).catchError((e) {
        Log.e(TAG, 'saveExternalData fail', e);
        return false;
      });

      return result;
    } catch (e) {
      Log.e(TAG, 'saveExternalData fail 2', e);
      return false;
    }
  }

  static Future<UserOki> baixarUser(String userId) async {
    Log.d(TAG, 'baixarUser', 'Iniciando');
    var result = await FirebaseOki.database
        .child(FirebaseChild.USUARIO)
        .child(userId)
        .once().then((value) {
      Log.d(TAG, 'baixarUser', 'OK');
      return value.value;
    }).catchError((e) {
      Log.e(TAG, 'baixarUser fail', e);
      return null;
    });
    if (result != null)
      return UserOki.fromJson(result);
    return result;
  }

  //endregion

  //region get set

  UserDados get dados => _dados??= UserDados(FirebaseOki.user);
  set dados(UserDados value) => _dados = value;

  String get dataAlteracao => _dataAlteracao??= '';
  set dataAlteracao(String value) => _dataAlteracao = value;

  bool get hasAcessoEspecial => _acessoEspecial > 0 ?? false;
  bool get isGerente => _acessoEspecial > 1 ?? false;

  //endregion

}

class UserDados {

  //region Variaveis
  static const String TAG = 'UserDados';

  String _id;
  String _nome;
  String _foto;
  String _fotoLocal;
  String _email;
  String _senha;
  Endereco _endereco;
  //endregion

  //region construtores

  UserDados(User user) {
    id = user.uid;
    nome = user.displayName;
    foto = user.photoURL;
    email = user.email;
  }

  UserDados.fromJson(Map<dynamic, dynamic> map) {
    id = map['id'];
    nome = _decript(map['nome']);
    foto = map['foto'];
    email = _decript(map['email']);

    if (map['endereco'] != null)
      endereco = Endereco.fromJson(map['endereco']);
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "foto": foto,
    "nome": _encript(nome),
    "email": _encript(email),
    "endereco": endereco.toJson(),
  };

  //endregion

  //region Metodos

  Future<bool> salvar() async {
    Log.d(TAG, 'salvar', 'Iniciando');
    var result = await FirebaseOki.database
        .child(FirebaseChild.USUARIO)
        .child(id)
        .child(FirebaseChild.DADOS)
        .set(toJson()).then((value) {
      Log.d(TAG, 'salvar', 'OK');
      return true;
    }).catchError((e) {
      Log.e(TAG, 'salvar fail', e);
      return false;
    });

    return result;
  }

  String _encript(String value) => Cript.encript(value);
  String _decript(String value) => Cript.decript(value);

  //endregion

  //region get set

  String get senha => _senha ?? '';
  set senha(String value) => _senha = value;

  String get email => _email ?? '';
  set email(String value) => _email = value;

  String get fotoLocal => _fotoLocal ?? '';
  set fotoLocal(String value) => _fotoLocal = value;

  String get foto => _foto ?? '';
  set foto(String value) => _foto = value;

  String get nome => _nome ?? '';
  set nome(String value) => _nome = value;

  String get id => _id ?? '';
  set id(String value) => _id = value;

  Endereco get endereco => _endereco??= Endereco();
  set endereco(Endereco value) => _endereco = value;

  //endregion

}

class Endereco {
  //region variaveis
  String _estado;
  String _cidade;
  String _bairro;
  String _numero;
  String _rua;
  String _cep;
  String _complemento;
  //endregion

  //region construtores

  Endereco();

  Endereco.fromJson(Map map) {
    estado = _decript(map['estado']);
    cidade = _decript(map['cidade']);
    bairro = _decript(map['bairro']);
    numero = _decript(map['numero']);
    rua = _decript(map['rua']);
    cep = _decript(map['cep']);
    complemento = _decript(map['complemento']);
  }

  Map toJson() => {
    'estado': _encript(estado),
    'cidade': _encript(cidade),
    'bairro': _encript(bairro),
    'numero': _encript(numero),
    'rua': _encript(rua),
    'cep': _encript(cep),
    'complemento': _encript(complemento),
  };

  //endregion

  String _encript(String value) => Cript.encript(value);
  String _decript(String value) => Cript.decript(value);

  bool get isIncompleto {
    return bairro.isEmpty || rua.isEmpty || numero.isEmpty;
  }

  //region get set

  String get estado => _estado??= '';
  set estado(String value) => _estado = value;

  String get cidade => _cidade??= '';
  set cidade(String value) => _cidade = value;

  String get bairro => _bairro??= '';
  set bairro(String value) => _bairro = value;

  String get rua => _rua??= '';
  set rua(String value) => _rua = value;

  String get numero => _numero??= '';
  set numero(String value) => _numero = value;

  String get cep => _cep??= '';
  set cep(String value) => _cep = value;

  String get complemento => _complemento??= '';
  set complemento(String value) => _complemento = value;

  //endregion

}
