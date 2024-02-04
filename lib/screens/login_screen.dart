import 'package:flutter/material.dart';
import 'package:flutter_qrcode_bloc/blocs/auth/auth_bloc.dart';
import 'package:flutter_qrcode_bloc/routes/route_names.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final TextEditingController emailC =
      TextEditingController(text: 'admin@gmail.com');
  final TextEditingController passC = TextEditingController(text: 'admin123');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LOGIN'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: emailC,
            autocorrect: false,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: passC,
            autocorrect: false,
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                  AuthEventLogin(email: emailC.text, password: passC.text));
            },
            child: BlocConsumer<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthStateLoading) {
                  return const Text('LOADING...');
                }
                return const Text('LOGIN');
              },
              listener: (context, state) {
                if (state is AuthStateLoggedIn) {
                  context.goNamed(Routes.home);
                }
                if (state is AuthStateError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
