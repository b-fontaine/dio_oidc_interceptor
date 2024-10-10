
// Implémentation factice de LocalStorage
import 'package:localstorage/localstorage.dart';

class LocalStorageStub implements LocalStorage {
  bool clearCalled = false;

  @override
  void clear() {
    clearCalled = true;
  }

  // Autres méthodes peuvent rester non implémentées si elles ne sont pas utilisées
  @override
  int get length => 0;

  @override
  String? getItem(String key) => null;

  @override
  String? key(int index) => null;

  @override
  void removeItem(String key) {}

  @override
  void setItem(String key, String value) {}
}