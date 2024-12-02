import 'dart:async';

import 'package:dio_oidc_interceptor_example/data/data_module.dart';
import 'package:injectable/injectable.dart';

@singleton
class IsConnectedUseCase {
  final IsAuthenticatedRepository _repository;
  final StreamController<bool> _controller = StreamController<bool>();
  late final Stream<bool> _stream;

  Stream<bool> get stream => _stream;

  IsConnectedUseCase(this._repository) {
    _stream = _controller.stream.asBroadcastStream();
  }

  Future<void> call() async {
    _controller.add(await _repository());
  }
}
