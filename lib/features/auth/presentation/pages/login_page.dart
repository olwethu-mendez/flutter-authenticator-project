// features/auth/presentation/pages/login_page.dart
import 'package:authentipass/features/auth/domain/entity/login_entity.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_event.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final countryCodeController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String localCode = "+27";
  final List<String> _supportedCodes = ["+27", "+266", "+268"];
  bool isEmailLogin = true;
  bool passworsIsHidden = true;

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
    context.read<AuthBloc>().add(AuthCheckBiometricAvailabilityRequested());
  }

  @override
  void dispose() {
    countryCodeController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void loginUser() {
    final String? finalCountryCode = isEmailLogin
        ? null
        : countryCodeController.text;
    final String finalUsername = isEmailLogin
        ? emailController.text
        : phoneNumberController.text;

    final loginEntity = LoginEntity(
      countryCode: (finalCountryCode?.isEmpty ?? true)
          ? null
          : finalCountryCode,
      username: finalUsername,
      password: passwordController.text,
      stayLoggedIn: true,
    );
    context.read<AuthBloc>().add(AuthLoginRequested(login: loginEntity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is BiometricAvailabilityChecked) {
            setState(() {
              biometricAvailable = state.isAvailable;
            });
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) =>
          current is AuthInitial || 
            current is AuthLoading || 
            current is AuthError || 
            current is AuthUnauthenticated,
        builder: (context, state) {
            // If we are loading a login request, show a spinner over the form 
          // or disable buttons.
          final isSubmitting = state is AuthLoading;

          return Center(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text("Login to your account"),
                      const SizedBox(height: 32),

                      ToggleButtons(
                        borderRadius: BorderRadius.circular(12),
                        constraints: const BoxConstraints(
                          minHeight: 45.0,
                          minWidth: 120.0,
                        ),
                        isSelected: [!isEmailLogin, isEmailLogin],
                        onPressed: (index) {
                          setState(() {
                            isEmailLogin = index == 1;
                            if (isEmailLogin) {
                              emailController.clear();
                              countryCodeController
                                  .clear(); // Clear so it becomes null in loginUser()
                            } else {
                              phoneNumberController.clear();
                              countryCodeController.text =
                                  localCode; // Reset to default dial code
                            }
                          });
                        },
                        children: const [Text('Phone'), Text('Email')],
                      ),

                      const SizedBox(height: 24),
                      if (isEmailLogin)
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            semanticCounterText: "Phone number input field",
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        )
                      else
                        MergeSemantics(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                child: DropdownButtonFormField<String>(
                                  // Use the validated localCode
                                  initialValue: _supportedCodes.contains(localCode)
                                      ? localCode
                                      : _supportedCodes.first,
                                  decoration: InputDecoration(
                                    semanticCounterText: "Country Code dropdown field"
                                  ),
                                  items: _supportedCodes.map((code) {
                                    return DropdownMenuItem(
                                      value: code,
                                      child: Row(
                                        children: [
                                          CountryFlag.fromPhonePrefix(
                                            code,
                                            theme: const ImageTheme(
                                              height: 16,
                                              width: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(code),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        localCode = val;
                                        countryCodeController.text = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: phoneNumberController,
                                  decoration: const InputDecoration(
                                    labelText: "Phone Number",
                                    semanticCounterText: "Phone number input field"
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          semanticCounterText: "Password input field",
                          prefixIcon: Icon(Icons.lock_outline),
                          suffix: IconButton(
                            onPressed: () => setState(
                              () => passworsIsHidden = !passworsIsHidden,
                            ),
                            icon: Icon(
                              passworsIsHidden
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            tooltip: passworsIsHidden ? "Show password" : "Hide password",
                          ),
                        ),
                        obscureText: passworsIsHidden ? true : false,
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _forgotPasswordModal(context),
                            child: const Text("Forgot Password"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : loginUser,
                          child: state is AuthLoading
                              ? const CircularProgressIndicator(semanticsLabel: "Logging you in, please wait")
                              : const Text("Login"),
                        ),
                      ),

                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: const Text("Don't have an account? Register"),
                      ),
                      if (biometricAvailable) ...[
                        //used for conditional UI
                        const SizedBox(
                          height: 32,
                        ), // Replace Spacer() with this
                        Text("or", style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: (isSubmitting || isLoading)
                                ? null
                                : () async {
                                    final didAuthenticate = await auth
                                        .authenticate(localizedReason: 'Please authenticate to login');

                                    if (didAuthenticate && mounted) {
                                      context.read<AuthBloc>().add(
                                        AuthBiometricLoginRequested(),
                                      );
                                    }
                                  },
                            icon:
                                (state is AuthLoading &&
                                    biometricAvailable) // Optional: show spinner on button
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      semanticsLabel: "Logging you in, please wait",
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.fingerprint),
                            label: const Text("Login with Biometrics"),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _forgotPasswordModal(BuildContext context) {
    showAdaptiveDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog.adaptive(
            title: Text("Forgot Password"),
            content: Text(
              "Please enter your preferred and validated mode of communication",
            ),
            actions: [
              const SizedBox(height: 32),
              ToggleButtons(
                borderRadius: BorderRadius.circular(12),
                constraints: const BoxConstraints(
                  minHeight: 45.0,
                  minWidth: 120.0,
                ),
                isSelected: [!isEmailLogin, isEmailLogin],
                onPressed: (index) {
                  setModalState(() {
                    isEmailLogin = index == 1;
                    if (isEmailLogin) {
                      emailController.clear();
                      countryCodeController
                          .clear(); // Clear so it becomes null in loginUser()
                    } else {
                      phoneNumberController.clear();
                      countryCodeController.text =
                          localCode; // Reset to default dial code
                    }
                  });
                },
                children: const [Text('Phone'), Text('Email')],
              ),

              const SizedBox(height: 24),
              if (isEmailLogin)
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      child: DropdownButtonFormField<String>(
                        // Use the validated localCode
                        initialValue: _supportedCodes.contains(localCode)
                            ? localCode
                            : _supportedCodes.first,
                        items: _supportedCodes.map((code) {
                          return DropdownMenuItem(
                            value: code,
                            child: Row(
                              children: [
                                CountryFlag.fromPhonePrefix(
                                  code,
                                  theme: const ImageTheme(
                                    height: 16,
                                    width: 24,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(code),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              localCode = val;
                              countryCodeController.text = val;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: phoneNumberController,
                        decoration: const InputDecoration(
                          labelText: "Phone Number",
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  final username = isEmailLogin
                      ? emailController.text
                      : phoneNumberController.text;
                  final comType = isEmailLogin ? "email" : "phone";
                  context.read<AuthBloc>().add(
                    AuthForgotPasswordRequested(username: username, comType: comType),
                  );
                  Navigator.pop(dialogContext);
                },
                child: Text("Forgot Password"),
              ),
            ],
          );
        },
      ),
    );
  }
}
