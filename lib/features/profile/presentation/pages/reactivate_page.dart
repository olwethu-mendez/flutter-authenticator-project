// features/auth/presentation/pages/reactivate_page.dart

import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_event.dart';
import 'package:authentipass/features/profile/data/models/deactivate_account_model.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_event.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReactivatePage extends StatefulWidget {
  const ReactivatePage({super.key});

  @override
  State<ReactivatePage> createState() => _ReactivatePageState();
}

class _ReactivatePageState extends State<ReactivatePage> {
  final TextEditingController _passwordController = TextEditingController();
  bool passwordIsHidden = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileActivated) {
          context.read<AuthBloc>().add(AuthCheckRequested());
        }
            
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle_outlined, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text("Welcome Back!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                "Your account is currently deactivated. Would you like to reactivate it and pick up where you left off?",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                "Please re-enter password to confirm you want to activate your account.",
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 32),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  // Use setModalState here!
                  onPressed: () =>
                      setState(() => passwordIsHidden = !passwordIsHidden),
                  icon: Icon(
                    passwordIsHidden ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
              obscureText: passwordIsHidden,
            ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  context.read<ProfileBloc>().add(ActivateProfileRequested(
                      deactivate: DeactivateAccountModel(
                        password: _passwordController.text,
                      ),
                    ),
                  );
                },
                child: const Text("Reactivate Account"),
              ),
              TextButton(
                onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
                child: const Text("Logout and exit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}