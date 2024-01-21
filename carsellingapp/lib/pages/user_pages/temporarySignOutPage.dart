import 'package:flutter/material.dart';
import 'package:autoplusapp/database/authentication.dart';
import 'package:autoplusapp/statecontrollers/authtree.dart';

class tempSignOutPage extends StatefulWidget{

    const tempSignOutPage({super.key});

  @override
  State<tempSignOutPage> createState() => _tempSignOutPageState();
}

class _tempSignOutPageState extends State<tempSignOutPage> {
    final _formKey = GlobalKey<FormState>(); // our global key used to change the state of the page (Ro)


  @override
  Widget build(BuildContext context) { // Ro
    return Scaffold(
      body:
      Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment:MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Row(
            mainAxisAlignment:MainAxisAlignment.center,
            children: [
            IconButton(onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      await Authentication().signout();
                      Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const authTree()),
                    );
      
                      
                    }
                  }, icon: const Icon(Icons.logout))
          ],)
        ],),
      )
    );
 
    
  }
}