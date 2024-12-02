import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../ui_module.dart';
import '../login_bloc.dart';
import '../login_event.dart';
import '../login_state.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginLoaded) {
          context.push("/logout");
        }
      },
      builder: (context, state) {
        if (state is LoginInitial) {
          context.read<LoginBloc>().add(LoginInitialEvent());
        }
        if (state is LoginLoading) {
          return ScaffoldWithDoc(
            title: "login",
            buttonLabel: "Local connect with default login (admin/admin)",
            isLoading: true,
            onButtonPressed: () {},
          );
        }
        return ScaffoldWithDoc(
          title: "login",
          buttonLabel: "Local connect with default login (admin/admin)",
          onButtonPressed: () {
            context.read<LoginBloc>().add(LoginButtonPressed());
          },
        );
      },
    );
  }
}
