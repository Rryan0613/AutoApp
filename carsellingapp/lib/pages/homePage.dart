import 'package:autoplusapp/pages/user_pages/temporarySignOutPage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:autoplusapp/database/authentication.dart';
import 'package:autoplusapp/pages/user_pages/profileSetupPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'detailsPage.dart';



class homePage extends StatefulWidget{ // Made By Roman
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage>{

  @override
  void initState() {
    super.initState();
    checkProfileSetup();
    getUserData();
  }

  final _formKey = GlobalKey<FormState>(); // our global key used to change the state of the page (Ro)
  final User? user = Authentication().currentUser;
  String userName = '';

Future<bool> hasCompletedProfileSetup(String email) async { // Ro
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    return querySnapshot.docs.isNotEmpty;
  } catch (e) {
    print('Error checking email registration: $e');
    return false;
  }
}


  Future<void> checkProfileSetup() async { // Ro
    if (user != null) {
      bool hasCompletedSetup = await hasCompletedProfileSetup(user?.email ?? 'email');
      if (!hasCompletedSetup) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileSetupPage(userEmail: user?.email ?? ''),
        ));
      }
    }
  }
  Future<void> getUserData() async { // Ro
  if (user != null) {
    try {
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(user!.email).get();

      if (userData.exists) {
        Map<String, dynamic>? userDataMap = userData.data() as Map<String, dynamic>?;

        if (userDataMap != null && userDataMap.containsKey('name')) {
          setState(() {
            userName = userDataMap['name'];
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

@override
  Widget build(BuildContext context) { // Ro
  return Scaffold(
    body: Column(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              Row(
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  Text(
                    "Welcome back ",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.roboto(fontSize: 30),
                  ),
                    Text(
                    userName,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.roboto(fontSize: 30,fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.user),
                    onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder:(_){
                        return const tempSignOutPage();
                      }));
                    },
                  ),
                ],
              ),
             Row(children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.03),
              Text("New Listings", style: GoogleFonts.nunito(fontWeight: FontWeight.w100, fontSize: 25)),
             ],)

            ],
          ),
        ),
        Expanded(
          flex: 8,
          child: Padding(
            padding: const EdgeInsets.only(left:10, top:10, right:10, bottom:50),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('posts').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                   if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.red));
                } 
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
          
                // Extract the list of documents from the snapshot
                final List<DocumentSnapshot> documents = snapshot.data!.docs;
          
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
                      builder: (context) => detailsPage(vehicle_image : vehicleImage, vehicle_name:vehicleName, vehicle_price:vehiclePrice,vehicle_description:vehicleDescription,owner_info:ownerInfo, vehicle_owner: vehicleOwner,),
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
