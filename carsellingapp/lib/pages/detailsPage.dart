import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:autoplusapp/database/authentication.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:autoplusapp/statecontrollers/authtree.dart';

class detailsPage extends StatefulWidget{ // Made By Roman
  final String vehicle_image, vehicle_name, vehicle_description, owner_info; 
  final String vehicle_price, vehicle_owner;

  const detailsPage({super.key, required this.vehicle_image, required this.vehicle_name, required this.vehicle_price, required this.vehicle_description, required this.owner_info, required this.vehicle_owner});

  @override
  State<detailsPage> createState() => _detailsPageState();
}

class _detailsPageState extends State<detailsPage>{


  final _formKey = GlobalKey<FormState>(); // our global key used to change the state of the page (Ro)
  final User? user = Authentication().currentUser;

  Future<String> getImageUrl(vehicleImage) async {
    Reference ref = FirebaseStorage.instance.refFromURL(vehicleImage);
   return await ref.getDownloadURL();
  }

  Future<void> favoritePost(vehicle_name, vehicle_cost, vehicle_desc, vehicle_owner, owner_info,vehicle_image) async {

      try {
    CollectionReference favoritesCollection = FirebaseFirestore.instance.collection('favorites');

    DocumentReference userFavoritesDocRef = await favoritesCollection
        .doc(user!.email) 
        .collection('user_favorites')
        .add({
      'vehicle_name': vehicle_name,
      'vehicle_cost': vehicle_cost,
      'vehicle_desc': vehicle_desc,
      'vehicle_owner': vehicle_owner,
      'owner_info': owner_info,
      'vehicle_image':vehicle_image,
      // Add other fields as needed
    });

    print('Document added with ID: ${userFavoritesDocRef.id}');
  } catch (e) {
    print('Error adding document to favorites: $e');
  }



  }

  // Future<void> sendToDB(vehicleName, vehicleDesc, vehicleCost, ownerInfo, vehicleOwner, vehicleImage) async{
  //    await FirebaseFirestore.instance.collection('posts').add({
  //   'vehicle_image': vehicleImage,
  //   'vehicle_name' :vehicleName,
  //   'vehicle_cost' :vehicleCost,
  //   'vehicle_desc' :vehicleDesc,
  //   'vehicle_owner': vehicleOwner,
  //   'owner_info': ownerInfo,
  // });
  


@override
  Widget build(BuildContext context) { // Ro
  return Scaffold(
    body: SingleChildScrollView(
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
          Stack(
            children: [ SizedBox(child: ClipRRect(
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
                                  
                                ),)
                                ),
                                   
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.favorite,color:Color.fromARGB(199, 255, 0, 72), size: 70),
                            onPressed: () async{
                             await favoritePost(widget.vehicle_name, widget.vehicle_price, widget.vehicle_description, widget.vehicle_owner,widget.owner_info,widget.vehicle_image);
                            },
                          ),
                        ),
                    ],
          ),
    
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
       SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: TextFormField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: const BorderSide(color: Color.fromARGB(70, 0, 0, 0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: const BorderSide(color: Color.fromARGB(70, 0, 0, 0)),
                            ),
                            hintText: 'Send a message to ${widget.vehicle_owner}',
                          ),
                          // validator: (String? text) {
                          //   if (text == null || text.isEmpty) {
                          //     return 'Enter username!';
                          //   }
                          //   username = text;
                          //   return null;
                          // },
                        ),
                    ),
     
    
      
    
    
          ],)))
        ],),
      ),
    )
  );
}
 
}
