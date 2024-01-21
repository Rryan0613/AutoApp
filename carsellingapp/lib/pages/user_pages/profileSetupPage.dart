import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:autoplusapp/statecontrollers/authtree.dart';

// in this page the user gets prompted to insert a name for the app if first time, wont appear again once entered into the database.

class ProfileSetupPage extends StatefulWidget { // Made By Roman
  final String userEmail;

  const ProfileSetupPage({super.key, required this.userEmail});

  @override
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _updateUserProfile() async { // Ro
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userEmail).set({
        'email': widget.userEmail,
        'name': _nameController.text.trim(),
      });
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) { // Ro
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Hi there User, Let us get to know you first!', style: GoogleFonts.roboto(fontSize: 30)),
              TextFormField(
                controller: _nameController,
               decoration: InputDecoration(
               enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: Color.fromARGB(255, 135, 135, 135)),
                 ),
                focusedBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: Color.fromARGB(255, 135, 135, 135)),
),
                 hintText: 'Name',
                 ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    await _updateUserProfile();
                    Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const authTree()),
                  );

                    
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
