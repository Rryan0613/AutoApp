import 'dart:math';
import 'package:flutter/material.dart';
import 'package:autoplusapp/database/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:autoplusapp/pages/user_pages/detailsPageOwner.dart';

class userProfilePage extends StatefulWidget{ // Made By Roman

  const userProfilePage ({Key? key}): super(key: key);

  @override
  State<userProfilePage> createState() => _userProfilePage();
}

class _userProfilePage extends State<userProfilePage>{

  @override
  void initState(){
    super.initState();
    getUserData();
  }

  final User? user = Authentication().currentUser;
  late String user_name = '';

  Future<void> getUserData() async { // Ro
  if (user != null) {
    try {
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(user!.email).get();

      if (userData.exists) {
        Map<String, dynamic>? userDataMap = userData.data() as Map<String, dynamic>?;

        if (userDataMap != null && userDataMap.containsKey('name')) {
          setState(() {
            user_name = userDataMap['name'];
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }
}

Future<String> getImageUrl(imageUrl) async { // Ro
  Reference ref = FirebaseStorage.instance.refFromURL(imageUrl);
  return await ref.getDownloadURL();
}


  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) { // Ro
  return Scaffold(
    body: Column(
      children: [
         Padding(padding: EdgeInsets.only(top:MediaQuery.of(context).size.height * 0.1),),
        Center(child: CircleAvatar(backgroundColor: Color(Random().nextInt(0xffffffff)),
        minRadius: 70,
        maxRadius: 70,
        child: Text(user_name.isNotEmpty ? user_name.substring(0,1): '',style: GoogleFonts.roboto(color: Colors.white, fontSize: 50,fontWeight: FontWeight.bold),),
        ),),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Center(child: Text(user_name.isNotEmpty ? user_name : '',
         style:GoogleFonts.roboto(fontSize: 30) ,),),

         Row(children: [SizedBox(width: MediaQuery.of(context).size.width * 0.03),Text("My Posts", style: GoogleFonts.nunito(fontSize: 25))],),

        Expanded(
          flex: 8,
          child: Padding(
            padding: const EdgeInsets.only(left:10, top:10, right:10, bottom:50),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('posts').where('owner_info',isEqualTo: user!.email) .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                   if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.red));
                } 
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final List<DocumentSnapshot> documents = snapshot.data!.docs;
                if (documents.isEmpty) {
                  return Center(
                    child: Text(
                      'No posts yet',
                      style: GoogleFonts.nunito(fontSize: 20),
                    ),
                  );
                }
          
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final vehicleImage = documents[index]['vehicle_image'];
                    final vehicleName = documents[index]['vehicle_name'];
                    final vehiclePrice = documents[index]['vehicle_cost'];
                    final vehicleDescription = documents[index]['vehicle_desc'];
                    final ownerInfo = documents[index]['owner_info'];
                    final vehicleOwner = documents[index]['vehicle_owner'];
          
                    return GestureDetector(
                      onTap: (){
                        Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => detailsPageOwner(vehicle_image : vehicleImage, vehicle_name:vehicleName, vehicle_price:vehiclePrice,vehicle_description:vehicleDescription,owner_info:ownerInfo, vehicle_owner: vehicleOwner,),
                    ),
                       );
                      },

                      child: ClipRRect(
                                      
                          borderRadius:  BorderRadius.circular(15),
                      
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            FutureBuilder<String>(
                              future: getImageUrl(vehicleImage),
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
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              right: 10,
                              child: Text(
                                "$vehicleName   ",
                                style: const TextStyle(
                                  backgroundColor: Color.fromARGB(35, 255, 255, 255),
                                  color: Color.fromARGB(223, 255, 255, 255),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}
}