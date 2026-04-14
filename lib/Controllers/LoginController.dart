import 'package:flutter/foundation.dart';
import '../Application/ClassificationService.dart';
import '../Infraestructure/Database/DatabaseHelper.dart';
import '../Infraestructure/Repository/UserRepository.dart';
import '../Models/User.dart';

enum LoginStatus { idle, loading, success, error }

class LoginController extends ChangeNotifier {
  final UserRepository  _userRepo;
  final ClassificationService _classifier;

  LoginController(): _userRepo  = UserRepository(DatabaseHelper.instance),
        _classifier = ClassificationService(DatabaseHelper.instance) {
        _classifier.seedDefaultData();
  }

  LoginStatus _status       = LoginStatus.idle;
  String?     _errorMessage;
  User?       _currentUser;
  LoginStatus get status       => _status;
  String?     get errorMessage => _errorMessage;
  User?       get currentUser  => _currentUser;

  bool get isLoading => _status == LoginStatus.loading;

  Future<void> login({
    required String name,
    required String email,
    required String password,
  }) async {

    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      _setError('Por favor completa todos los campos.');
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.trim())) {
      _setError('Ingresa un correo electrónico válido.');
      return;
    }

    _setStatus(LoginStatus.loading);

    try {
      User? user = await _userRepo.findByEmail(email.trim());

      if (user == null) {
        final id = await _userRepo.insert(
          User(name: name.trim(), email: email.trim()),
        );
        user = User(id: id, name: name.trim(), email: email.trim());
      }

      _currentUser = user;
      _setStatus(LoginStatus.success);
    } catch (_) {
      _setError('Ocurrió un error al iniciar sesión. Intenta de nuevo.');
    }
  }

  void reset() {
    _status       = LoginStatus.idle;
    _errorMessage = null;
    _currentUser  = null;
    notifyListeners();
  }

  void _setStatus(LoginStatus s) {
    _status       = s;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status       = LoginStatus.error;
    _errorMessage = msg;
    notifyListeners();
  }
}