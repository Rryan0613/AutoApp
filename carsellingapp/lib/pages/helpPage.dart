import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class HelpPage extends StatelessWidget { // Made By Kevin
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<bool> sendEmail(String name, String email, String description) async {
    // Placeholder for email sending logic
    // Replace this with your actual email sending code
    print('Sending email to: $email');
    // Simulating a successful email sending
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Set the initial value of the email field

    emailController.text = 'your@example.com';

    return Scaffold(
      appBar: AppBar(
        title: Text('Help Page',style: GoogleFonts.nunito()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('The wait time for a response is 12 hours',style: GoogleFonts.nunito()),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              onTap: () {
                if (emailController.text == 'your@example.com') {
                  // Clear the pre-filled text when user taps on the field
                  emailController.clear();
                }
              },
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description of your issue'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                print('Name: ${nameController.text}');
                print('Email: ${emailController.text}');
                print('Description: ${descriptionController.text}');

                bool emailSentSuccessfully = await sendEmail(
                  nameController.text,
                  emailController.text,
                  descriptionController.text,
                );
                nameController.clear();
                emailController.clear();
                descriptionController.clear();

                if (emailSentSuccessfully) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Email sent successfully!', style: GoogleFonts.nunito()),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to send email. Please try again.', style: GoogleFonts.nunito()),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }

                
              },

              child: Text('Send', style: GoogleFonts.nunito()),
            ),
          ],
        ),
      ),
    );
  }
}
