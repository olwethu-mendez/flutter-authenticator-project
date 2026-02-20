// features/auth/presentation/pages/register_page.dart

import 'package:authentipass/features/auth/domain/entity/register_entity.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:country_codes/country_codes.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_event.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final countryCodeController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // 1. Define a list of supported codes so we can validate against them
  final List<String> _supportedCodes = ["+27", "+266", "+268"];
  
  // 2. State variable to track the dropdown selection
  String? _selectedCountryCode;
  final _formKey = GlobalKey<FormState>();
  bool? _prefersEmail;


  void _onTextChanged() {
      setState(() {
    if (emailController.text.isEmpty || phoneNumberController.text.isEmpty) {
        _prefersEmail = null; 
    }
      });
  }
  @override
  void initState() {
    super.initState();
    _initializeCountryCode();
    // Listen for changes to handle the toggle visibility and reset
    emailController.addListener(_onTextChanged);
    phoneNumberController.addListener(_onTextChanged);
  }

  Future<void> _initializeCountryCode() async {
    await CountryCodes.init();
    final deviceLocale = CountryCodes.dialCode();
    
    setState(() {
      // If the device code is in our list, use it. Otherwise, default to +27
      if (_supportedCodes.contains(deviceLocale)) {
        _selectedCountryCode = deviceLocale;
      } else {
        _selectedCountryCode = "+27";
      }
      countryCodeController.text = _selectedCountryCode!;
    });
  }

  @override
  void dispose() {
    countryCodeController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void registerUser(AuthState state) {
    // Trigger standard Form validation (for passwords, etc.)
  if (!_formKey.currentState!.validate()) return;

  // Custom validation for Preference Toggle
  if (emailController.text.isNotEmpty && 
      phoneNumberController.text.isNotEmpty && 
      _prefersEmail == null) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select your preferred mode of communication."),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

    final registerEntity = RegisterEntity(
      countryCode: countryCodeController.text,
      phoneNumber: phoneNumberController.text,
      email: emailController.text,
      prefersEmail: _prefersEmail,
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
    );
    context.read<AuthBloc>().add(AuthRegisterRequested(register: registerEntity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: BlocBuilder<AuthBloc, AuthState>(
        // listener: (context, state) {
        //   if (state is AuthLoading) context.go('/');
        //   if (state is AuthAuthenticated) context.go('/home');
        //   if (state is AuthProfileCreationRequired) context.go('/create-profile');
        //   if (state is AuthError) {
        //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        //   }
        // },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Icon(Icons.person_add_outlined, size: 80, color: Colors.blue),
                  const SizedBox(height: 32),
                  
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    onTapOutside: (value) => _onTextChanged(),
                  ),
                  const SizedBox(height: 16),            
                  
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 110,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedCountryCode,decoration: const InputDecoration(
                            labelText: "Code",
                            contentPadding: EdgeInsets.symmetric(horizontal: 4),
                          ),items: _supportedCodes.map((code) {
                            return DropdownMenuItem(
                              value: code,
                              child: Row(
                                children: [
                                  CountryFlag.fromPhonePrefix(code, 
                                    theme: const ImageTheme(height: 16, width: 24)),
                                  const SizedBox(width: 8),
                                  Text(code, style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            );
                          }).toList(),onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCountryCode = val;
                                countryCodeController.text = val;
                              });
                            }
                          },
                        ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: phoneNumberController,
                              decoration: const InputDecoration(labelText: "Phone Number"),
                              onTapOutside: (value) => _onTextChanged(),
                            ),
                          ),
                        ],
                      ),
                  const SizedBox(height: 16),
                  if (emailController.text.isNotEmpty && phoneNumberController.text.isNotEmpty)
                  
                SwitchListTile.adaptive(
                  title: const Text("Preferred communication"),
                  value: _prefersEmail ?? false,
                  subtitle: Text(
                    _prefersEmail == true ? "Mode: Email" : _prefersEmail == false ? "Mode: Phone" : "Toggle to select mode",
                    style: TextStyle(
                      color: _prefersEmail == true ? Colors.blue : _prefersEmail == false ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  secondary: Icon(
                    _prefersEmail == true ? Icons.email :_prefersEmail == false ? Icons.phone : Icons.toggle_on,
                  ),
                  onChanged: (newValue) => setState(() => _prefersEmail = newValue),
                  //activeColor: Colors.teal, // Color when the switch is ON
                ),
                if (emailController.text.isNotEmpty && phoneNumberController.text.isNotEmpty)
                const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value != passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: "Confirm Password",
                      prefixIcon: Icon(Icons.lock_reset_outlined),
                    ),
                    obscureText: true,                    
                    validator: (value) {
                      if (value != passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => state is AuthLoading ? null : registerUser(state),
                      child: state is AuthLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("Register"),
                    ),
                  ),
                  
                  TextButton(
                    onPressed: () => context.pop(), // Goes back to login
                    child: const Text("Already have an account? Login"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}