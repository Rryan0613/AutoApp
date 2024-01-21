// Importing necessary Dart and Flutter packages
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:autoplusapp/database/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:autoplusapp/pages/user_pages/detailsPageOwner.dart';

// Defining the StatefulWidget for the favoritesPage
class favoritesPage extends StatefulWidget { // Ryan
  const favoritesPage({Key? key}) : super(key: key);
  @override
  State<favoritesPage> createState() => _favoritesPage();
}

// The corresponding State class for favoritesPage
class _favoritesPage extends State<favoritesPage> {
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  // Retrieving the current user and initializing user_name
  final User? user = Authentication().currentUser;
  late String user_name = '';

  // Asynchronous method to fetch user data from Firestore
  Future<void> getUserData() async { // Ro
    if (user != null) {
      try {
        // Fetching user data document from Firestore
        DocumentSnapshot userData =
            await FirebaseFirestore.instance.collection('users').doc(user!.email).get();

        // Checking if the document exists
        if (userData.exists) {
          // Extracting user data map
          Map<String, dynamic>? userDataMap = userData.data() as Map<String, dynamic>?;

          // Updating user_name if user data contains 'name' field
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

  // Asynchronous method to get the download URL of an image from Firebase Storage
  Future<String> getImageUrl(imageUrl) async { // Ro
    Reference ref = FirebaseStorage.instance.refFromURL(imageUrl);
    return await ref.getDownloadURL();
  }

  // Global key for the form widget
  final _formKey = GlobalKey<FormState>();

  // Building the UI for the favoritesPage
  @override
  Widget build(BuildContext context) { // Ro
    return Scaffold(
      body: Column(
        children: [
          // UI elements for user information and avatar
          Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),),
          Center(
            child: CircleAvatar(
              backgroundColor: Color(Random().nextInt(0xffffffff)),
              minRadius: 70,
              maxRadius: 70,
              child: Text(
                user_name.isNotEmpty ? user_name.substring(0, 1) : '',
                style: GoogleFonts.roboto(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Center(
            child: Text(
              user_name.isNotEmpty ? user_name : '',
              style: GoogleFonts.roboto(fontSize: 30),
            ),
          ),

          // Text for 'My Favorites' section
          Row(children: [SizedBox(width: MediaQuery.of(context).size.width * 0.03), Text("My Favorites", style: GoogleFonts.nunito(fontSize: 25))],),

          // StreamBuilder for displaying favorite items from Firestore
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.only(left:10, top:10, right:10, bottom:50),
              child: StreamBuilder(
                stream:  FirebaseFirestore.instance.collection('favorites')
                    .doc(user!.email)  // Assuming the document ID is the user's email
                    .collection('user_favorites')
                    .snapshots(),

                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  // Loading indicator while waiting for data
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.red));
                  } 
                  // Handling errors during data retrieval
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  // Extracting documents from the snapshot
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  // Displaying a message if no posts are available
                  if (documents.isEmpty) {
                    return Center(
                      child: Text(
                        'No posts yet',
                        style: GoogleFonts.nunito(fontSize: 20),
                      ),
                    );
                  }

                  // Building a grid of favorite items
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      // Extracting data for each item
                      final vehicleImage = documents[index]['vehicle_image'];
                      final vehicleName = documents[index]['vehicle_name'];
                      final vehiclePrice = documents[index]['vehicle_cost'];
                      final vehicleDescription = documents[index]['vehicle_desc'];
                      final ownerInfo = documents[index]['owner_info'];
                      final vehicleOwner = documents[index]['vehicle_owner'];

                      // Gesture detector for item tap
                      return GestureDetector(
                        onTap: (){
                          // Navigating to the detailsPageOwner when an item is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => detailsPageOwner(
                                vehicle_image: vehicleImage,
                                vehicle_name: vehicleName,
                                vehicle_price: vehiclePrice,
                                vehicle_description: vehicleDescription,
                                owner_info: ownerInfo,
                                vehicle_owner: vehicleOwner,
                              ),
                            ),
                          );
                        },

                        // Displaying each item as a stack with an image and text
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Fetching and displaying the image asynchronously
                              FutureBuilder<String>(
                                future: getImageUrl(vehicleImage),
                                builder: (context, snapshot) {
                                  // Loading indicator while waiting for image
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator(color: Colors.red));
                                  }
                                  // Displaying the image when available
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
                              // Displaying text overlay on the image
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
