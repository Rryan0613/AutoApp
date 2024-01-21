import 'package:flutter/material.dart';
import 'package:autoplusapp/database/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:autoplusapp/statecontrollers/authtree.dart';




class newAdPage extends StatefulWidget{ // Made By Roman

  const newAdPage ({Key? key}) : super(key:key);

  @override
  State<newAdPage> createState() => _newAdPage();

}

class _newAdPage extends State<newAdPage>{

  final _formKey = GlobalKey<FormState>(); // our global key used to change the state of the page (Ro)


    @override
  void initState() {
    super.initState();
    getUserData();
  }

  final User? user = Authentication().currentUser;

  String vehicle_owner = '';
    Future<void> getUserData() async { // Ro
  if (user != null) {
    try {
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(user!.email).get();

      if (userData.exists) {
        Map<String, dynamic>? userDataMap = userData.data() as Map<String, dynamic>?;

        if (userDataMap != null && userDataMap.containsKey('name')) {
          setState(() {
            vehicle_owner = userDataMap['name'];
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }
}

   Future<void> _pickImage() async { // a method to retrieve photos from device gallery
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      _selectedImage = File(pickedFile!.path);
    });
  }
    void _deleteImage() { // method to remove image from selected image container in case doesnt want it anymore or simply refresh and itll be gone.
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _takePicture() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      _selectedImage = File(pickedFile!.path);
    });
  }
  
  File ? _selectedImage;
  // late String vehicle_name ='', vehicle_desc= '', vehicle_cost = ''; // inputted info from user
  TextEditingController vehicleNameController = TextEditingController();
  TextEditingController vehicleDescController = TextEditingController();
  TextEditingController vehicleCostController = TextEditingController();



  Future<String> imageToStorage (File imageFile) async {
  try {
    String fileName = "${user!.uid}${DateTime.now().toString()}"; // sends image to firebase storage as their userID + time it was uploaded for ref purposes.

    Reference storageReference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = storageReference.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;

  } catch (e) {
    print('Error uploading image: $e');
    return '';
  }
}

  Future<void> sendToDB(vehicleName, vehicleDesc, vehicleCost, ownerInfo, vehicleOwner, vehicleImage) async{
     await FirebaseFirestore.instance.collection('posts').add({
    'vehicle_image': vehicleImage,
    'vehicle_name' :vehicleName,
    'vehicle_cost' :vehicleCost,
    'vehicle_desc' :vehicleDesc,
    'vehicle_owner': vehicleOwner,
    'owner_info': ownerInfo,
  });

  }
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(padding:EdgeInsets.only(top:MediaQuery.of(context).size.height * 0.1),child: Text("Post an Ad", style: GoogleFonts.nunito(fontSize: 30, color:Colors.red))),
              Row(children: [SizedBox(width:MediaQuery.of(context).size.width * 0.02),
                Text("Step 1. Upload an image of your vehicle, tap below", style: GoogleFonts.nunito(fontSize: 15))],),
              Padding(
                padding:EdgeInsets.only(top:MediaQuery.of(context).size.height * 0.03),
                child: Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose an option"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.photo_library),
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  await _pickImage(); // Open the gallery
                },
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  await _takePicture(); // Open the camera
                },
              ),
            ],
          ),
        );
      },
    );
  },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: MediaQuery.of(context).size.height * 0.3,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(
                                    _selectedImage!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.image, size:40),
                                ),
                        ),
                      ),
                      if (_selectedImage != null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.delete,color:Colors.white),
                            onPressed: _deleteImage,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(children: [SizedBox(width:MediaQuery.of(context).size.width * 0.02),
                Text("Step 2. Give us some details about the vehicle", style: GoogleFonts.nunito(fontSize: 15))],),
              Row(children: [SizedBox(width:MediaQuery.of(context).size.width * 0.4),
              Text("Description", style: GoogleFonts.nunito(fontSize: 15,))],),
              Center(child:  SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height:MediaQuery.of(context).size.height * 0.06,
                child: TextFormField(
                  controller: vehicleNameController,
                  style: const TextStyle(fontSize: 15),
                      maxLines: 1,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(50, 0, 0, 0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(50, 0, 0, 0)),
                        ),
                        hintText: 'year, make, model',
                      ),
                      validator: (String? text) {
                        if (text == null || text.isEmpty) {
                          return 'Give Description';
                        }
                        return null;
                      },
                    ),
              ),),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        
              Center(child:  SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller:vehicleDescController,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(50, 0, 0, 0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: Color.fromARGB(50, 0, 0, 0)),
                        ),
                        hintText: 'Tell us about the car...',
                      ),
                      validator: (String? text) {
                        if (text == null || text.isEmpty) {
                          return 'Give Description';
                        }
           
                        return null;
                      },
                    ),
              ),),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(children:
               [SizedBox(width:MediaQuery.of(context).size.width * 0.02),
                const Text("Price:   "),
               SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.06,
                child: TextFormField(
                  controller: vehicleCostController,
                      maxLines: 1,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(50, 0, 0, 0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(50, 0, 0, 0)),
                        ),
                        hintText: '\$CAD',
                      ),
                      validator: (String? text) {
                        if (text == null || text.isEmpty) {
                          return 'Give Description';
                        }
                        return null;
                      },
                    ),
              )
               
               ],),
                SizedBox(height:MediaQuery.of(context).size.height * 0.05),
                Row(children: [SizedBox(width:MediaQuery.of(context).size.width * 0.02),
                Text("Final step, upload.", style: GoogleFonts.nunito(fontSize: 15))],),
                SizedBox(height:MediaQuery.of(context).size.height * 0.01),
                Center(child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if(_formKey.currentState!.validate()){

                      
                      try {
                        String imageId = await imageToStorage(_selectedImage!);
                        await sendToDB(vehicleNameController.text, vehicleDescController.text, vehicleCostController.text, user!.email, vehicle_owner, imageId);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Success'),
                              content: const Text('Posted Ad'),
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
                    }},
                  ),
                ),),
                Container(child: SizedBox(height:MediaQuery.of(context).size.height * 0.1),
        ),
            ],
          ),
        ),
      ),
    );
  }
}
