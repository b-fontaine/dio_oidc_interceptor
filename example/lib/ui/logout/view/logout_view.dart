import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../ui_module.dart';
import '../logout_bloc.dart';
import '../logout_event.dart';
import '../logout_state.dart';

class LogoutView extends StatelessWidget {
  const LogoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LogoutBloc, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccessState) {
          context.push("/login");
        }
      },
      builder: (context, state) {
        return ScaffoldWithDoc(
          title: "logout",
          buttonLabel: "Log out and return to login",
          onButtonPressed: () {
            context.read<LogoutBloc>().add(LogoutEventLogout());
          },
        );
      },
    );
  }
}
