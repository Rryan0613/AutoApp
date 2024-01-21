// Import the necessary package for Firebase Authentication
import 'package:firebase_auth/firebase_auth.dart';

// A class responsible for user authentication using Firebase Auth - By Roman
class Authentication {
  // Create an instance of FirebaseAuth for authentication operations
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Getter to retrieve the currently authenticated user (if any)
  User? get currentUser => _firebaseAuth.currentUser; 

  // Stream to listen to changes in the authentication state (sign in, sign out, etc.)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Async function to sign in a user with email and password
  Future<void> signin({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Async function to sign up a new user with email and password
  Future<void> signup({required String email, required String password}) async {
    await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // Async function to sign out the currently authenticated user
  Future<void> signout() async {
    await _firebaseAuth.signOut();
  }
}
