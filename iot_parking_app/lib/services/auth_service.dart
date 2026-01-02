import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static bool _initialized = false;

  // Initialize Google Sign-In with serverClientId (required on Android)
  static Future<void> initGoogle() async {
    if (!_initialized) {
      await _googleSignIn.initialize(
        serverClientId:
            "PUT_YOUR_WEB_CLIENT_ID_HER",
      );
      _initialized = true;
    }
  }

  // Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      await initGoogle();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final idToken = googleUser.authentication.idToken;

      final authorization = await googleUser.authorizationClient
          .authorizationForScopes(['email', 'profile']);

      final accessToken = authorization?.accessToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Missing Google Auth Token');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      // Save new user to Firestore
      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'photoURL': user.photoURL ?? '',
            'provider': 'google',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign up with email & password
  static Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign in with email & password
  static Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
