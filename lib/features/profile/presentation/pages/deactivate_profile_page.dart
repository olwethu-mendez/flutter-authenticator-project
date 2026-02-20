import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_event.dart';
import 'package:authentipass/features/profile/data/models/deactivate_account_model.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_event.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';

class DeactivateProfilePage extends StatefulWidget {
  const DeactivateProfilePage({super.key});

  @override
  State<DeactivateProfilePage> createState() => _DeactivateProfilePageState();
}

class _DeactivateProfilePageState extends State<DeactivateProfilePage> {
  final TextEditingController _passwordController = TextEditingController();
  bool passwordIsHidden = true;

  final LocalAuthentication auth = LocalAuthentication();
  bool biometricAvailable = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    if (!mounted) return;
    context.read<ProfileBloc>().add(ProfileCheckBiometricAvailabilityRequested());
    context.read<ProfileBloc>().add(FetchProfileRequested());
  }

  Future<void> _onDeactivatePressed() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your password"), backgroundColor: Colors.red),
      );
      return;
    }

    final deactivateModel = DeactivateAccountModel(password: password);
    context.read<ProfileBloc>().add(DeactivateProfileRequested(deactivate: deactivateModel));
  }

  Future<void> _onBiometricPressed() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to deactivate your profile',
      );

      if (didAuthenticate) {
        final deactivateModel = DeactivateAccountModel(password: '');
        context.read<ProfileBloc>().add(DeactivateProfileRequested(deactivate: deactivateModel));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Biometric authentication failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    context.read<ProfileBloc>().add(FetchProfileRequested());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is BiometricAvailabilityChecked) {
          setState(() {
            biometricAvailable = state.isAvailable;
          });
        } // ADD THIS: Handle error messages globally here
        if (state is ProfileDeactivated) {
          context.read<AuthBloc>().add(AuthLogoutRequested());
        }// Handle errors so the user isn't stuck wondering why it failed
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Deactivate Profile'),
          centerTitle: true,
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          buildWhen: (previous, current) =>
              current is ProfileInitial ||
              current is ProfileLoading ||
              current is ProfileError ||
              current is ProfileDeactivated,
          builder: (context, state) {
            return _buildImprovedLayout(context, state);
          },
        ),
      ),
    );
  }

Widget _buildImprovedLayout(BuildContext context, ProfileState state) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24.0),
    child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Warning Section
          /*Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'This action is permanent. All your data will be cleared.',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),*/
      
          // 2. Action Card
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text("Confirm Identity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: passwordIsHidden,
                    decoration: InputDecoration(
                      labelText: "Enter Password",
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => passwordIsHidden = !passwordIsHidden),
                        icon: Icon(passwordIsHidden ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Primary Deactivate Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: state is ProfileLoading ? null : _onDeactivatePressed,
                      child: state is ProfileLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Deactivate with Password"),
                    ),
                  ),
                ],
              ),
            ),
          ),
      
          // 3. Biometric Quick-Action
          if (biometricAvailable) ...[
            const SizedBox(height: 24),
            const Text("OR", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _onBiometricPressed,
              icon: const Icon(Icons.fingerprint, color: Colors.red),
              label: const Text("Use Biometric Confirmation", style: TextStyle(color: Colors.red)),
            ),
          ],
        ],
      ),
    ),
  );
}
}
