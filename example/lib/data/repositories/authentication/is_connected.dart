import 'package:dio_oidc_interceptor_example/core/di/di_module.dart';
import 'package:injectable/injectable.dart';

@injectable
class IsAuthenticatedRepository {
  final Authentication _authentication;

  @factoryMethod
  IsAuthenticatedRepository(this._authentication);

  Future<bool> call() async {
    var userIfo = await _authentication.userInfo;
    print(userIfo);
    return await _authentication.isAuthenticated;
  }
}
