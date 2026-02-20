// features/auth/presentation/pages/banned_page.dart

import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BannedPage extends StatelessWidget {
  const BannedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gavel_rounded, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text("Account Suspended", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                "Your account has been deactivated by an administrator for policy violations. Please contact support@yourapp.com if you believe this is a mistake.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}