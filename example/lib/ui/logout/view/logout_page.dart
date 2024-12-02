import 'package:dio_oidc_interceptor_example/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logout_bloc.dart';
import 'logout_view.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LogoutBloc>(),
      child: const LogoutView(),
    );
  }
}
