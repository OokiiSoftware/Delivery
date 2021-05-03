import 'import.dart';

class Admin {
  static const String TAG = 'Admin';
  static Admin inst = Admin();

  List<Function(bool)> _onCheckCompleted = [];
  Map<String, bool> _admins = Map();// <id, isEnabled>
  bool _isAdmin;

  bool get isAdmin => _isAdmin ?? false;

  void addCheckCompletedListener(Function(bool) value) {
    if (value != null && !_onCheckCompleted.contains(value))
      _onCheckCompleted.add(value);
  }
  void removeCheckCompletedListener(Function(bool) value) {
    _onCheckCompleted.remove(value);
  }

  Future<void> _checkAdmin() async {
    try {
      if (!FirebaseOki.isLogado)
        return;

      var snapshot = await FirebaseOki.database.child(FirebaseChild.ADMINISTRADORES).once();
      Map<dynamic, dynamic> map = snapshot.value;
      for (dynamic key in map.keys) {
        _admins[key] = map[key];
      }
      if (_admins.containsKey(FirebaseOki.user.uid))
        _isAdmin = map[FirebaseOki.user.uid];

      Log.d(TAG, 'checkAdmin', 'OK');
    } catch (e) {
      Log.e(TAG, 'checkAdmin', e);
    }
    _onCheckCompleted.forEach((element) {
      element?.call(_isAdmin);
    });
  }

  void init() async {
    await _checkAdmin();
    Log.d(TAG, 'init', 'OK');
  }

  void finalize() {
    _isAdmin = false;
    _admins.clear();
  }
}