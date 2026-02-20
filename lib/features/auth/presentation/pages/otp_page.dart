// features/auth/presentation/pages/otp_page.dart

import 'package:authentipass/features/auth/data/models/auth_user_code_model.dart';
import 'package:authentipass/features/auth/data/models/forgot_password_model.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_event.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

enum OtpType { verifyEmail, verifyPhone, forgotPassword }

class OtpPage extends StatefulWidget {
  const OtpPage({
    super.key,
    required this.otpType,
    this.comType,
    this.username,
  });

  final OtpType otpType;
  final String? comType;
  final String? username;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool passworsIsHidden = true;

  @override
  void dispose() {
    super.dispose();
    _otpController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // 1. DETERMINE DATA SOURCE (Bloc vs Widget Params)
      String displayUsername = widget.username ?? "";
      String displayType = widget.comType ?? "";

      if (state is AuthForgotPasswordOtp) {
        displayUsername = state.username;
        displayType = state.comType;
      }

          return Scaffold(
          appBar: AppBar(
            title: Text(widget.otpType == OtpType.verifyEmail
              ? "Verify Email"
              : widget.otpType == OtpType.verifyPhone
                  ? "Verify Phone Number"
                  : "Forgot Password"),
            actions: [
              IconButton(
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                  // If you want to clear profile state immediately:
                  // context.read<ProfileBloc>().add(ResetProfileEvent());
                },
                icon: Icon(Icons.logout_outlined),
              ),
            ],
          ),
          body:  Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Verify Your Account",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                "Enter the 6-digit code sent to your $displayType ($displayUsername)",
                textAlign: TextAlign.center,
              ),
                    const SizedBox(height: 30),
                    Pinput(
                      length: 6,
                      controller: _otpController,
                    ),
                    const SizedBox(height: 20),
                    if (state is AuthLoading)
                      const CircularProgressIndicator()
                    else
                      Column(
                        children: [
                          ElevatedButton(
                      onPressed: () {
                        // 2. HANDLE ACTIONS BASED ON TYPE
                        if (widget.otpType == OtpType.forgotPassword) {
                          _newPasswordModal(context, displayUsername);
                        } else if (state is AuthAuthenticated) {
                          final codeModel = AuthUserCodeModel(
                            userId: state.userId,
                            code: _otpController.text,
                          );

                          if (widget.otpType == OtpType.verifyEmail) {
                            context.read<AuthBloc>().add(AuthConfirmEmailRequested(codeModel: codeModel));
                          } else if (widget.otpType == OtpType.verifyPhone) {
                            context.read<AuthBloc>().add(AuthConfirmPhoneRequested(codeModel: codeModel));
                          }
                        }
                      },
                      child: const Text("Verify"),
                          ),
                          if (widget.otpType == OtpType.verifyEmail ||
                              widget.otpType == OtpType.verifyPhone)
                            SizedBox(height: 16),
                          if (widget.otpType == OtpType.verifyEmail ||
                              widget.otpType == OtpType.verifyPhone)
                            TextButton(
                              onPressed: () async {
                                final state = context.read<AuthBloc>().state;
        
                                if (state is AuthAuthenticated) {
                                  context.read<AuthBloc>().add(
                                    AuthResendOtpRequested(
                                      isEmail: widget.otpType == OtpType.verifyEmail
                                          ? true
                                          : false,
                                    ),
                                  );
                                }
                              },
                              child: Text("Retry"),
                            ),
                        ],
                      ),
                  ],
                ),
              )
        );
      }
    );
  }

  void _newPasswordModal(BuildContext context, String username) {
  showAdaptiveDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setModalState) {
        return AlertDialog.adaptive(
            title: Text("Enter New Password"),
            content: Column(
              mainAxisSize: MainAxisSize.min, // Keep column tight
              children: [
                const Text("Please enter your new password below"),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      // Use setModalState here!
                      onPressed: () => setModalState(
                        () => passworsIsHidden = !passworsIsHidden,
                      ),
                      icon: Icon(
                        passworsIsHidden
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  obscureText: passworsIsHidden,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancel"),
              ),
              TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AuthBloc>().add(
                      AuthConfirmForgotPasswordRequested(
                        forgotPassword: ForgotPasswordModel(
                          newPassword: passwordController.text,
                          code: _otpController.text,
                          username: username, // Uses the passed username
                        ),
                      ),
                    );
              },
              child: const Text("Reset Password"),
              ),
            ],
          );
        },
      ),
    );
  }
}
