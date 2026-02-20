import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_event.dart';
import 'package:authentipass/features/profile/data/models/deactivate_account_model.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeactivatedScreen extends StatefulWidget {
  final bool byAdmin;
  const DeactivatedScreen({super.key, required this.byAdmin});

  @override
  State<DeactivatedScreen> createState() => _DeactivatedScreenState();
}

class _DeactivatedScreenState extends State<DeactivatedScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool passwordIsHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.byAdmin ? Icons.gavel : Icons.no_accounts, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              widget.byAdmin ? "Account Suspended" : "Account Deactivated",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              widget.byAdmin 
                ? "Your account has been deactivated by an administrator. Please contact support."
                : "Welcome back! Would you like to reactivate your account to continue?",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (!widget.byAdmin) 
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
            if (!widget.byAdmin) 
          const SizedBox(height: 16),
            if (!widget.byAdmin) 
              ElevatedButton(
              onPressed: () {
                context.read<ProfileBloc>().add(ActivateProfileRequested(
                    deactivate: DeactivateAccountModel(
                      password: _passwordController.text,
                    ),
                  ),
                );     
              },
                child: const Text("Reactivate My Account"),
              ),
            TextButton(
              onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}