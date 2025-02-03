import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Sign Up Method
  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception("Email is already in use.");
      } else if (e.code == 'invalid-email') {
        throw Exception("Invalid email format.");
      } else if (e.code == 'weak-password') {
        throw Exception("Password is too weak.");
      } else {
        throw Exception(e.message);
      }
    }
  }

  // Sign In Method (Handles "User Not Found" and "Wrong Password")
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception("User does not exist.");
      } else if (e.code == 'wrong-password') {
        throw Exception("Incorrect password.");
      } else if (e.code == 'invalid-email') {
        throw Exception("Invalid email format.");
      } else {
        throw Exception(e.message);
      }
    }
  }

  // Sign Out Method
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Check if User is Signed In
  Stream<User?> get userStream => _firebaseAuth.authStateChanges();
}
