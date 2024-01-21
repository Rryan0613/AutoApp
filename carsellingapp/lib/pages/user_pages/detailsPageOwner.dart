import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:autoplusapp/database/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:autoplusapp/statecontrollers/authtree.dart';

class detailsPageOwner extends StatefulWidget{ // Roman
  final String vehicle_image, vehicle_name, vehicle_description, owner_info; 
  final String vehicle_price, vehicle_owner;

  const detailsPageOwner({super.key, required this.vehicle_image, required this.vehicle_name, required this.vehicle_price, required this.vehicle_description, required this.owner_info, required this.vehicle_owner});

  @override
  State<detailsPageOwner> createState() => _detailsPageOwnerState();
}

class _detailsPageOwnerState extends State<detailsPageOwner>{


  final _formKey = GlobalKey<FormState>(); // our global key used to change the state of the page (Ro)
  final User? user = Authentication().currentUser;

  Future<String> getImageUrl(vehicleImage) async {
    Reference ref = FirebaseStorage.instance.refFromURL(vehicleImage);
   return await ref.getDownloadURL();
  }

  Future<void> deletePost(userEmail, vehicleName, vehicleDescription, vehiclePrice, vehicleOwner)async{
    await FirebaseFirestore.instance.collection('posts').
    where('owner_info', isEqualTo: userEmail ?? '').
    where('vehicle_name', isEqualTo: vehicleName).
    where('vehicle_desc', isEqualTo: vehicleDescription).
    where('vehicle_cost', isEqualTo: vehiclePrice).
    where('vehicle_image', isEqualTo: widget.vehicle_image).
    where('vehicle_owner', isEqualTo: vehicleOwner).get().
    then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot document) async {
        await document.reference.delete();
      });
    });
}

  
@override
  Widget build(BuildContext context) { // Ro
  return Scaffold(
    body: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height *0.07, left: MediaQuery.of(context).size.width *0.05, right: MediaQuery.of(context).size.width *0.05, bottom: MediaQuery.of(context).size.height *0.1),
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children:
             [IconButton(icon: const Icon(Icons.arrow_back_ios),color: Colors.red, onPressed: (){
                Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const authTree()),
                );
          
                        
              
          
             })],),
            SizedBox(child: ClipRRect(
              borderRadius:BorderRadius.circular(20),
              child: FutureBuilder<String>(
                                  future: getImageUrl(widget.vehicle_image),
                                  builder: (context, snapshot) {
                                     if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator(color: Colors.red));
                                     }
                                    if (snapshot.connectionState == ConnectionState.done) {
                                      return snapshot.hasError
                                          ? const Icon(Icons.error)
                                          : Image.network(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                            );
                                    } else {
                                      return const Placeholder();
                                    }
                                  },
                                ),)),
          
            SizedBox(child: Container(child: Column(children: [
              
              Row(children: [Text(widget.vehicle_name, style: GoogleFonts.nunito(fontSize: 25,fontWeight: FontWeight.w100),)],),
             
              Row(children: [Text("Asking: \$${widget.vehicle_price} CAD", style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold))],),
              
              SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
             
             
              Container(decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black, // Choose the border color
          width: 0.2, // Choose the border width
        ),
        borderRadius: BorderRadius.circular(12.0), // Adjust the border radius
        ),
        padding: const EdgeInsets.all(16),
        child: Text(widget.vehicle_description, textAlign: TextAlign.start,style: GoogleFonts.nunito())),
          
        Row(children: [
        const Icon(Icons.person, color: Colors.red,size: 50), 
        Text("Owner: ${widget.vehicle_owner}",style: GoogleFonts.nunito(fontSize: 20)),
        ],),
      
        Row(children: 
        [
          const Spacer(),
          IconButton(icon: const Icon(Icons.delete_sharp,color:Colors.red),
          onPressed: () async {
                      if(_formKey.currentState!.validate()){
                      try {
                       await deletePost(user!.email, widget.vehicle_name,widget.vehicle_description,widget.vehicle_price, widget.vehicle_owner);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Success'),
                              content: const Text('Deleted Ad'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); 
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                        Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const authTree()),
              );
                      } catch (error) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: Text('An error occurred: $error'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }}),
         const Spacer(),
        ],)
            ],)))
          ],),
        ),
      ),
    )
  );
}
 
}
