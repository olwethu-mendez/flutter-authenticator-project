import 'dart:io';

import 'package:authentipass/features/organisation/data/models/create_organisation_model.dart';
import 'package:authentipass/features/organisation/presentation/bloc/org_bloc.dart';
import 'package:authentipass/features/organisation/presentation/bloc/org_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class CreateOrganisationPage extends StatefulWidget {
  const CreateOrganisationPage({super.key});

  @override
  State<CreateOrganisationPage> createState() => _CreateOrganisationPageState();
}

class _CreateOrganisationPageState extends State<CreateOrganisationPage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  File? _logoFile;
  File? _headerFile;
  bool _isPublic = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _logoFile = File(pickedFile.path));
  }

  Future<void> _pickHeaderImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _headerFile = File(pickedFile.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Organisation")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Stack(
            clipBehavior:
                Clip.none, // Allows the logo to hang off the edge if needed
            alignment: Alignment.center, // Centers children by default
            children: [
              // 1. Header Image (Top)
              GestureDetector(
                onTap: _pickHeaderImage,
                child: Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey[200], // Placeholder color
                  child: _headerFile != null
                      ? Image.file(_headerFile!, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 50),
                ),
              ),

              // 2. Circular Logo (Centered on Header)
              Positioned(
                // Adjust 'bottom' to move the logo up or down relative to the header
                bottom: 20,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white, // Border effect
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: _logoFile != null
                          ? FileImage(_logoFile!)
                          : null,
                      child: _logoFile == null
                          ? const Icon(Icons.camera_alt, size: 40)
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Organisation Name"),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: "Description"),
          ),
          SwitchListTile(
            title: const Text("Public Organisation"),
            value: _isPublic,
            onChanged: (val) => setState(() => _isPublic = val),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              context.read<OrgBloc>().add(
                CreateOrganisationsRequested(
                  CreateOrganisationModel(
                    name: _nameController.text,
                    description: _descController.text,
                    isPublic: _isPublic,
                    organizationImage: _logoFile,
                    organizationHeaderImage: _headerFile,
                  ),
                ),
              );
            },
            child: const Text("Create Organisation"),
          ),
        ],
      ),
    );
  }
}
