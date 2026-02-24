// features/profile/presentation/pages/create_profile_page.dart
import 'dart:io';

import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_event.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_state.dart';
import 'package:authentipass/features/profile/data/models/create_profile_model.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_event.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  String selectedGender = "Male";
  File? selectedImage;
  bool _isPickingImage = false; // Add this variable to your State class
  bool _stayLoggedIn = false; // Add this variable to your State class
  bool get isOtherGender => selectedGender == "Other";
final genderDescriptionController = TextEditingController();

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

  @override
Widget build(BuildContext context) {
  return BlocListener<AuthBloc, AuthState>(
    listener: (context, state) {
      if(state is AuthAuthenticated){
        context.go('/home');
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text("Create Profile"),
        actions: [        
            IconButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
                // If you want to clear profile state immediately:
                // context.read<ProfileBloc>().add(ResetProfileEvent());
              },
              icon: Icon(Icons.logout_outlined),
            ),
        ],),
      // Fix 1: Explicitly define the types <Bloc, State>
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileCreated) {
            // Fix 2: Refresh AuthBloc state so it knows we now have a profile
            context.read<AuthBloc>().add(AuthCheckRequested());
          }
          /*if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }*/
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
              TextField(
                controller: firstNameController, 
                decoration: const InputDecoration(labelText: "First Name", border: OutlineInputBorder())
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastNameController, 
                decoration: const InputDecoration(labelText: "Last Name", border: OutlineInputBorder())
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedGender, // Use value, not initialValue for controlled widgets
                items: ["Male", "Female", "Non-Binary", "Genderfluid", "Other", "Prefer Not To Say"]
                    .map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => selectedGender = val!),
                decoration: const InputDecoration(labelText: "Gender", border: OutlineInputBorder()),
              ),
              
              if (isOtherGender) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: genderDescriptionController,
                  decoration: const InputDecoration(
                    labelText: "Please describe your gender",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                title: Text("stay logged in?"),
                value: _stayLoggedIn,
                onChanged: (newValue) => setState(() => _stayLoggedIn = newValue),
                //activeColor: Colors.teal, // Color when the switch is ON
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final model = CreateProfileModel(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      gender: selectedGender,
                      genderSelfDescription: isOtherGender ? genderDescriptionController.text : null,
                      stayLoggedIn: _stayLoggedIn,
                      profilePicture: selectedImage,
                    );
                    context.read<ProfileBloc>().add(CreateProfileRequested(createProfileModel: model));
                  },
                  child: const Text("Complete Profile"),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}
}