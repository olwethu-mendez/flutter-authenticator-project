import 'dart:io';
import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_event.dart';
import 'package:authentipass/features/profile/data/models/update_profile_model.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_event.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:authentipass/features/profile/data/models/user_profile_model.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfileModel profile;
  final bool isDetails;
  const EditProfilePage({
    super.key,
    required this.profile,
    required this.isDetails,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  late String _selectedGender;
  bool get _isOtherGender => _selectedGender == "Other";

  late TextEditingController _genderSelfDescriptionController;

  File? _selectedImage;
  bool _isPickingImage = false; // Add this variable to your State class

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.profile.firstName,
    );
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _selectedGender = widget.profile.gender ?? "Prefer Not To Say";
    _genderSelfDescriptionController = TextEditingController(
      text: widget.profile.genderSelfDescription,
    );

    Listenable.merge([
      _firstNameController,
      _lastNameController,
      _genderSelfDescriptionController,
    ]).addListener(_handleControllerChange);
  }

  void _handleControllerChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // 4. Clean up: Remove the listener and dispose controllers
    _firstNameController.removeListener(_handleControllerChange);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _genderSelfDescriptionController.dispose();
    super.dispose();
  }

  bool _hasChanges() {
  if (widget.isDetails) {
    bool firstNameChanged = _firstNameController.text != widget.profile.firstName;
    bool lastNameChanged = _lastNameController.text != widget.profile.lastName;
    bool genderChanged = _selectedGender != widget.profile.gender;
    bool descriptionChanged = _genderSelfDescriptionController.text != widget.profile.genderSelfDescription;

    // Returns true if ANY field is different from the original
    return firstNameChanged || lastNameChanged || genderChanged || descriptionChanged;
  }
  return _selectedImage != null;
}

  Future<void> _pickImage() async {
    if (_isPickingImage) return; // Prevent double-trigger
    setState(() => _isPickingImage = true);
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  void _saveProfile() {
    if (widget.isDetails) {
      final updateProfileModel = UpdateProfileModel(
        firstName: _firstNameController.text.isEmpty
            ? widget.profile.firstName ?? ""
            : _firstNameController.text,
        lastName: _lastNameController.text.isEmpty
            ? widget.profile.lastName ?? ""
            : _lastNameController.text,
        gender: _selectedGender.isEmpty ? widget.profile.gender ?? "" : _selectedGender,
        genderSelfDescription: _genderSelfDescriptionController.text,
      );
      if (_formKey.currentState!.validate()) {
        context.read<ProfileBloc>().add(
          UpdateProfileRequested(upateProfileModel: updateProfileModel),
        );
      }
    } else {
      context.read<ProfileBloc>().add(
        UpdateProfilePictureRequested(profilePicture: _selectedImage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if ((state is ProfileUpdated && state.profileInfoChanged)|| state is ProfilePictureUpdated) {
          context.read<AuthBloc>().add(AuthCheckRequested());
          if(state is ProfileUpdated){            
            context.read<ProfileBloc>().add(ResetProfileFlagsEvent());
          }
            context.read<ProfileBloc>().add(FetchProfileRequested());
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isDetails ? "Edit Profile" : "Edit Profile Picture"),
          actions: [
            IconButton(
              // Check changes here
              onPressed: _hasChanges() ? _saveProfile : null,
              icon: Icon(
                Icons.check,
                color: _hasChanges() ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: widget.isDetails
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                // Avatar Section
                if (!widget.isDetails)
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 120,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (widget.profile.profilePictureUrl != null
                                    ? NetworkImage(
                                            widget.profile.profilePictureUrl!,
                                          )
                                          as ImageProvider
                                    : null),
                          child:
                              (_selectedImage == null &&
                                  widget.profile.profilePictureUrl == null)
                              ? Text(
                                  widget.profile.firstName![0],
                                  style: const TextStyle(fontSize: 40),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: FloatingActionButton.small(
                            onPressed: _pickImage,
                            child: const Icon(Icons.camera_alt),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (widget.isDetails)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Input Fields
                        TextFormField(
                          controller: _firstNameController,
                          onChanged: (_) => setState(() {}), // Trigger UI refresh
                          decoration: const InputDecoration(
                            labelText: "First Name",
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastNameController,
                          onChanged: (_) => setState(() {}), // Trigger UI refresh
                          decoration: const InputDecoration(
                            labelText: "Last Name",
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value:
                              _selectedGender, // Changed from initialValue to value
                          items:
                              [
                                    "Male",
                                    "Female",
                                    "Non-Binary",
                                    "Genderfluid",
                                    "Other",
                                    "Prefer Not To Say",
                                  ]
                                  .map(
                                    (g) => DropdownMenuItem(
                                      value: g,
                                      child: Text(g),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedGender = val!;
                            });
                          },
                          decoration: const InputDecoration(labelText: "Gender"),
                        ),
                        if (_isOtherGender) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller: _genderSelfDescriptionController,
                            onChanged: (_) =>
                                setState(() {}), // Trigger UI refresh
                            decoration: const InputDecoration(
                              labelText: "Please describe your gender",
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
