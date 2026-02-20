import 'package:authentipass/features/profile/data/models/update_phone_number_model.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_event.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_state.dart';
import 'package:go_router/go_router.dart';

class ChangePhoneNumberPage extends StatefulWidget {
  const ChangePhoneNumberPage({super.key});

  @override
  State<ChangePhoneNumberPage> createState() => _ChangePhoneNumberPageState();
}

class _ChangePhoneNumberPageState extends State<ChangePhoneNumberPage> {
  final _formKey = GlobalKey<FormState>();
  final countryCodeController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  String localCode = "+27";
  final List<String> _supportedCodes = ["+27", "+266", "+268"];
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _passwordController.dispose();
    countryCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Phone Number')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated && (state.phoneConfirmed == true || state.phoneChanged == true)) {
            context.read<ProfileBloc>().add(ResetProfileFlagsEvent());
            context.read<ProfileBloc>().add(FetchProfileRequested());
            context.push('/verify-otp/phone');            
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if(state is ProfileLoaded && (state.profile.phoneNumberConfirmed == true || (state.profile.phoneNumber == null || state.profile.phoneNumber == ""))) ...[
                    const Text(
                    "To update your phone number, please enter your new number and confirm with your current password.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // New Phone Number Field
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        child: DropdownButtonFormField<String>(
                          // Use the validated localCode
                          value: _supportedCodes.contains(localCode)
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
                        child: TextFormField(
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'New Phone Number',
                          ),
                          validator: (value) =>
                              (value == null || value.length != 9)
                              ? 'Enter a valid phone number'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Password Confirmation Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (value) => (value == null || value.length < 6)
                        ? 'Password required for security'
                        : null,
                  ),
                  const Spacer(),

                  ElevatedButton(
                    onPressed: state is ProfileLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state is ProfileLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit New Phone Number'),
                  ),
                ] else ...[
                  Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.phone_android_outlined,
                          size: 250,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                        Positioned(
                          bottom: -10,
                          right: 50,
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: const Icon(
                              Icons.check_circle,
                              size: 80,
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state is ProfileLoading ? null : _confirmPhoneNumber,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state is ProfileLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Confirm Phone Number'),
                  ),
                ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        UpdatePhoneNumberRequested(
          updatePhoneNumberModel: UpdatePhoneNumberModel(
            newPhoneNumber: _phoneNumberController.text.trim(),
            password: _passwordController.text,
            countryCode: countryCodeController.text.trim(),
          ),
        ),
      );
    }
  }

  void _confirmPhoneNumber() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        ConfirmPhoneNumberRequested(),
      );
    }
  }
}
