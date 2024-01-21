import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:autoplusapp/database/authentication.dart';
import 'package:google_fonts/google_fonts.dart';

class signupPage extends StatefulWidget{ // Roman
  const signupPage({super.key});
 // this is our class for the sign up and log in page (Ro)

  @override
  State<signupPage> createState() => _signupPageState();
}
class _signupPageState extends State<signupPage>{

  final _formKey = GlobalKey<FormState>(); // our global key used to change the state of the page (Ro)
  String? errorMessage =''; // a error message in case login fails (Ro)
  bool isLoggedin = true; // status of being logged in (Ro)
  String email = ''; // a email string to be passed as a parameter to our login function(R)
  String password = ''; // password ^^ (Ro)
  

Widget ShowSignUpError(){
  showDialog(context: context,
  builder: (context){
    return  AlertDialog(title: Text("Password too short, or invalid email (minimum 6 characters)",style: GoogleFonts.roboto(fontSize: 15),textAlign: TextAlign.center,),);
  });
  return Container();
}

Widget ShowSigninError(){
  showDialog(context: context,
  builder: (context){
    return  AlertDialog(title: Text("Invalid credentials", style: GoogleFonts.roboto(fontSize: 15),textAlign: TextAlign.center,));
  });
  return Container();
}


  Widget _signupButton(){
    return ElevatedButton(onPressed: ()async { if (_formKey.currentState!.validate()) {
      try{
        await Authentication().signup(email: email, password: password);
      } on FirebaseAuthException catch (e){
        print(e.message);
        ShowSignUpError();
        // AlertDialog(title: Text("Password is too short or email is invalid"));

      }
        
      }},
      style: ElevatedButton.styleFrom(elevation: 10,
                              shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: const BorderSide(color: Colors.red),
                          ),
                            backgroundColor: const Color.fromRGBO(214, 0, 27, 1)
                          ), child: const Text('Sign Up', style: TextStyle(color:Colors.white)));
  }
Widget _signinButton() {
  return ElevatedButton(
    onPressed: () async {
      if (_formKey.currentState!.validate()) {
        try {
          await Authentication().signin(email: email, password: password);
        } on FirebaseAuthException catch (e) {
          print(e.message);
          ShowSigninError();
          // AlertDialog(title: Text("Wrong username or password"));
        }
      }
    },
    style: ElevatedButton.styleFrom(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
        side: const BorderSide(color: Colors.red),
      ),
      backgroundColor: const Color.fromRGBO(214, 0, 27, 1),
    ),
    child: const Text('Sign In', style: TextStyle(color: Colors.white)),
  );
}

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Column(
                children:[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  Text('A U T O +', style:GoogleFonts.roboto(fontSize: 50,color:Colors.red)),
              
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.07,
                    child: TextFormField(
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide: const BorderSide(color: Color.fromARGB(255, 135, 135, 135)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide: const BorderSide(color: Color.fromARGB(255, 135, 135, 135)),
                                  ),
                                  hintText: 'Email',
                                ),
                                validator: (String? text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Enter email!';
                                  }
                                  email = text;
                                  return null;
                                },
                              ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.6,
                       height: MediaQuery.of(context).size.height * 0.07,
                        child: TextFormField(
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide: const BorderSide(color: Color.fromARGB(255, 135, 135, 135)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide: const BorderSide(color: Color.fromARGB(255, 135, 135, 135)),
                                  ),
                                  hintText: 'Password',
                                ),
                                validator: (String? text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Enter password!';
                                  }
                                  password = text;
                                  return null;
                                },
                              ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Row(
                        children: [
                          SizedBox(width:MediaQuery.of(context).size.width * 0.25),
                            _signupButton(),
                            SizedBox(width:MediaQuery.of(context).size.width * 0.02),
                            _signinButton()
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                      Icon(FontAwesomeIcons.car, color: Colors.red,size:MediaQuery.of(context).size.width * 0.3),
                        ],
                      ),
            ],
          ),
        ),
      ),
    );
  }
}