// features/profile/presentation/pages/create_profile_page.dart
import 'dart:io';

import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_state.dart';
import 'package:authentipass/features/users_management/data/models/create_user_model.dart';
import 'package:authentipass/features/users_management/presentation/bloc/users_bloc.dart';
import 'package:authentipass/features/users_management/presentation/bloc/users_event.dart';
import 'package:authentipass/features/users_management/presentation/bloc/users_state.dart';
import 'package:country_codes/country_codes.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  String selectedGender = "Male";
  File? selectedImage;
  bool _isPickingImage = false; // Add this variable to your State class
  bool? _prefersEmail = false; // Add this variable to your State class
  bool get isOtherGender => selectedGender == "Other";
final genderDescriptionController = TextEditingController();
final emailController = TextEditingController();
final countryCodeController = TextEditingController();
final phoneNumberController = TextEditingController();
  final List<String> _supportedCodes = ["+27", "+266", "+268"];
  String? _selectedCountryCode;
  //final _formKey = GlobalKey<FormState>();




  void _onTextChanged() {
      setState(() {
    if (emailController.text.isEmpty || phoneNumberController.text.isEmpty) {
        _prefersEmail = null; 
    }
      });
  }

  // Helper to pick image
  Future<void> _pickImage() async {
    if (_isPickingImage) return; // Prevent double-trigger
    setState(() => _isPickingImage = true);try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => selectedImage = File(pickedFile.path));
    }
  } finally {
    setState(() => _isPickingImage = false);
  }
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
  void initState() {
    super.initState();
    _initializeCountryCode();
    // Listen for changes to handle the toggle visibility and reset
    emailController.addListener(_onTextChanged);
    phoneNumberController.addListener(_onTextChanged);
  }

  

  @override
  void dispose() {
    firstNameController.dispose();
lastNameController.dispose();
genderDescriptionController.dispose();

    countryCodeController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return BlocListener<AuthBloc, AuthState>(
    listener: (context, state) {
      if(state is AuthAuthenticated){
        context.go('/home');
      }
    },
    child: BlocListener<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UserCreated) {
             context.push('/admin/users');
          }
          if (state is UsersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
                  child: selectedImage == null ? const Icon(Icons.camera_alt, size: 40) : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: firstNameController, 
                decoration: const InputDecoration(labelText: "First Name")
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: lastNameController, 
                decoration: const InputDecoration(labelText: "Last Name")
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedGender, // Use value, not initialValue for controlled widgets
                items: ["Male", "Female", "Non-Binary", "Genderfluid", "Other", "Prefer Not To Say"]
                    .map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => selectedGender = val!),
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              
              if (isOtherGender) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: genderDescriptionController,
                  decoration: const InputDecoration(
                    labelText: "Please describe your gender"
                  ),
                ),
              ],
              const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                    ),
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
                  
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final model = CreateUserModel(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      gender: selectedGender,
                      genderSelfDescription: isOtherGender ? genderDescriptionController.text : null,
                      countryCode: _selectedCountryCode,
                      email: emailController.text,
                      phoneNumber: phoneNumberController.text,
                      prefersEmail: _prefersEmail,
                      profilePicture: selectedImage,
                    );
                    context.read<UsersBloc>().add(CreateUserRequested(createUser: model));
                  },
                  child: const Text("Complete Profile"),
                ),
              )
            ],
          ),
        ),
      ),
  );
}
}