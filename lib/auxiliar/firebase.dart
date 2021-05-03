import 'import.dart';
import 'package:delivery/model/import.dart';
import 'package:delivery/res/import.dart';

class FirebaseOki {
  //region Variaveis
  static const String TAG = 'FirebaseOki';

  // static FirebaseApp _firebaseApp;
  static User _user;
  static DatabaseReference _database = FirebaseDatabase.instance.reference();
  static Reference _storage = FirebaseStorage.instance.ref();
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static GoogleSignIn _googleSignIn = GoogleSignIn();

  static UserOki _userOki;
  static Function onCheckSpecialAccess;
  static bool _hasAcessoEspecial;
  //endregion

  //region Firebase App

  static Future<bool> app() async{
    try {

      String decript(String value) => Cript.decript(_firebaseData[value]);
      // String encript(String value) => Cript.encript(_firebaseData[value]);

      // Log.d(TAG, 'appId', encript('appId'));
      // Log.d(TAG, 'projectId', encript('projectId'));
      // Log.d(TAG, 'messagingSenderId', encript('messagingSenderId'));
      // Log.d(TAG, 'apiKey', encript('apiKey'));
      // Log.d(TAG, 'storageBucket', encript('storageBucket'));
      // Log.d(TAG, 'databaseURL', encript('databaseURL'));

      var appOptions = FirebaseOptions(
        appId: decript('appId'),
        apiKey: decript('apiKey'),
        projectId: decript('projectId'),
        databaseURL: decript('databaseURL'),
        storageBucket: decript('storageBucket'),
        messagingSenderId: decript('messagingSenderId'),
      );
      await Firebase.initializeApp(
          name: AppResources.APP_NAME,
          options: appOptions
      );
    } catch(e) {
      Log.e(TAG, 'app', e);
    }
    return true;
  }

  static FirebaseAuth get auth => _auth;
  static Reference get storage => _storage;

  static User get user => _user;

  static DatabaseReference get database => _database;

  static Future<bool> googleAuth() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User user = (await _auth.signInWithCredential(credential)).user;
    Log.d(TAG, 'googleAuth OK', user.displayName);
    _user = user;
    _atualizarUser();
    return true;
  }

  //endregion

  //region gets

  static bool get isLogado => _user != null;

  static UserOki get userOki {
    if (_userOki == null && _user != null)
      _userOki = UserOki(UserDados(_user));
    return _userOki;
  }

  static Map get _firebaseData => {
    'apiKey': 'OMHKs3SRMEQRHG4|CBAJoISsiS☡EHNs|M☡PMSCXERU[X0JCQvWTDO3GKZxiRWHl4NH3PWi1ZmPWRGixKZKiIUD[mvGXmUmhT[fYNsLUHsYFm3F0LHJ[P1SZVIADfXJFTlOGU0dRFNv1S[xiK4kSJHiPGk|JMTX',
    'appId': Platform.isAndroid ? '3Ni3VWHskFMF☡lJ4YDm|DWSlXUT33F[iQVLmVVD3xU[GiiFNf☡UCV4vHlQDNLiRfiGRT☡zCLfGHCzIVVQPGKNlhVWi0Tx☡TMSQlRlsJZKkmZZJ7☡TURiIRZD4XFoADfxHLXWxsKihSCTfsDH3mTUzYTCdiTGCkQKk7FKo1ZhECTRivJSx' : '',
    'projectId': 'zTSiOURQEWRm7FO|NxxGKssSVUvYG☡XHFYOHN4QHRJmmWFZs',
    'databaseURL': 'LUQxRHU3fMSdEW4AUUs0G1kVSJfQRYiDU3ONf3NKV1mWFZs0NA3RWS0IDHT1XWJK3kRGf|CHMlxSJS7IVVQzNZT47DFlxC3lDLIHTC☡7KxEVW☡7JKkPUVJ3dRDH0☡NF7dWSxPWmiVoQS|iWTYiNVdzSXsWMvQGMN4lUNMosMWlYC4hCDGvsTGklHIIH|xM☡',
    'messagingSenderId': 'OMHKslHMOvSGFYODRMh4NRl1KQ☡MJQAZTRLQVLzWRfvKJXLVSK1kRSzzUHHEAFHV1☡SHV0AW7iDF7ECkkKCYiCHh|TDZ7ISRVdXUZhIHTC☡ETGGAkKF☡oNDkXUDkxVUslTdQNQQFJTYITZGE1MMimHKzzSfkCQ|JMTXEGomCDviSWEPWlBGSDviGTz☡GZRd7TNCOESI☡RTvXCDNz|GME3KMKo7GWUmfUl4UWBdWQzViXWHX4SVlYDTNs0F[DmkKJU7IJCQ1ZTKYXVxdNGDvBJJzPWUM☡|M☡LRNVo7NQvDf4SJKsQJv0VxmUDNAdH[S3BG4xRKI|DRCoLSmAJNVssZZB4GVGA3SM☡4TxiHRZYiK7☡C7dKWkiKVl0F00NRFOQKJmYTTYXJUkOKmYTMsiF[N☡PD☡BJPxKHK1vUJFoxZQERKkhSRMXoU3LUhiMk1HSLfFi☡NdhKCAkJiASD[☡dWQ0H7XGPoGizF[☡dTx4JJPkShlJ4IFvQFDlENFWI0Go3WA7KdEWM7mFMAmZVEiFXBWW4mDZOAUFNI4JR7QDk|GVxAKTBdMDMfsZZBLSFJlIVFDL7NEOML0G[0dVFEvRo0NxOZDB',
    'storageBucket': 'iSL3SHHOxKh|TvzHJmES0oMWkiSGVOzHMMs0UNviSF[m0JCQhFZH0dGT03FDT1PUZ☡3DWZfXNv0FKOxKZKi1NAiGsvZxxKSiEMJ[3BNCSYmWZmLSHV7ERHk'
  };

  static bool get isAdmin => Admin.inst.isAdmin;
  static bool get isGerente => userOki?.isGerente ?? false;
  static bool get isGerenteOrAdmin => isGerente || isAdmin;

  static bool get hasAcessoEspecial {
    return userOki?.hasAcessoEspecial ?? false;
  }
  static bool get hasAcessoEspecialOrIsAdmin {
    return hasAcessoEspecial || isAdmin;
  }

  static set userOki(UserOki value) => _userOki = value;

  //endregion

  //region Metodos

  static Future<void> init() async {
    const firebaseUser_Null = 'firebaseUser Null';
    try {
      await app();

      _user = _auth.currentUser;
      if (_user != null) {
        // _userOki = await UserOki.readLocalData(user.uid);
        var temp = Preferences.getObj(PreferencesKey.USER);
        if (temp != null)
          _userOki = UserOki.fromJson(temp);
        UserOki.baixarUser(_user.uid)
            .then((value) {
              if (_userOki == null)
                _userOki = UserOki(UserDados(_user));
              _userOki.complete(value);
              checkUserSpecialAccess();

        }).catchError((e) => false);
      }
      //   throw new Exception(firebaseUser_Null);

      _atualizarUser();
      Log.d(TAG, 'init', 'OK');
    } catch (e) {
      Log.e(TAG, 'init', e, send: !e.toString().contains(firebaseUser_Null));
    }
  }

  static void checkUserSpecialAccess() async {
    await _userOki.checkSpecialAcess();
    onCheckSpecialAccess?.call();
  }

  static Future<void> finalize() async {
    _user = null;
    _userOki = null;
    Admin.inst.finalize();
    await _auth.signOut();
    Log.d(TAG, 'finalize', 'OK');
  }

  static Future<void> _atualizarUser() async {
    // String uid = _user?.uid;
    // if (uid == null) return;
    // UserOki item = await _baixarUser(uid);
    // if (item == null) {
    //   if (_userOki == null)
    //     _userOki = UserOki();
    // } else {
    //   _userOki = item;
    // }
  }

  // static Future<UserOki> _baixarUser(String uid) async {
  //   try {
  //     var snapshot = await FirebaseOki.database
  //         .child(FirebaseChild.USUARIO).child(uid).once();
  //     return UserOki.fromJson(snapshot.value);
  //   } catch (e) {
  //     Log.e(TAG, 'baixarUser', e);
  //     return null;
  //   }
  // }

  //endregion

}

class FirebaseChild {
  static const String TESTE = 'teste';
  static const String COMBOS = 'combos';
  static const String USUARIO = 'usuario';
  static const String DADOS = '_dados';
  static const String DESEJOS = 'assistindo';
  static const String CONCLUIDOS = 'concluidos';
  static const String ACESSO_ESPECIAL = 'acesso_especial';
  static const String BIBLIA = 'biblia';
  static const String REFERENCIAS = 'referencias';
  static const String PRODUTOS = 'produtos';
  static const String PEDIDOS = 'pedidos';
  static const String PEDIDOS_PENDENTES = 'pedidos_pendentes';
  static const String PEDIDOS_CONCLUIDOS = 'pedidos_concluidos';
  static const String TEMAS = 'temas';
  static const String ESTABELECIMENTO = 'estabelecimento';

  static const String LIVRO = 'livro';
  static const String LIVROS = 'livros';
  static const String LIVROS_LIDOS = 'livrosLidos';
  static const String LIVROS_MARCADOS = 'livrosMarcados';
  static const String DATA_ALTERACAO = 'dataAlteracao';
  static const String CAPITULO = 'capitulo';
  static const String CAPITULOS = 'capitulos';
  static const String Versiculo = 'versiculo';

  static const String NOTIFICATIONS = 'notifications';
  static const String NOTIFICATIONS_TOPIC = 'notificationTopic';
  static const String ITEMS = 'items';
  static const String LOGS = 'logs';
  static const String CLASSIFICACAO = 'classificacao';
  static const String ADMINISTRADORES = 'admins';
  static const String BUG_ANIME = 'bug_anime';
  static const String SUGESTAO = 'sugestao';
  static const String SUGESTAO_ANIME = 'sugestao_anime';
  static const String VERSAO = 'versao';
}