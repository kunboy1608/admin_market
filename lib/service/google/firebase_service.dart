import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._();
  static FirebaseService get instance => _instance;
  FirebaseService._();

  FirebaseApp? _firebaseApp;
  FirebaseAuth? _firebaseAuth;

  Future<FirebaseApp?> initializeFirebase() async {
    _firebaseApp ??= await Firebase.initializeApp();
    return _firebaseApp;
  }

  Future<FirebaseAuth?> initialAuth() async {
    if (_firebaseAuth != null) {
      return _firebaseAuth;
    }

    await initializeFirebase();
    _firebaseAuth = FirebaseAuth.instanceFor(app: _firebaseApp!);
    return _firebaseAuth;
  }

  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      await initialAuth();
      return _firebaseAuth!.signInWithCredential(credential);
    } catch (e) {
      return null;
    }
  }

  Future<UserCredential?> signInWithFacebook() async {
    await initialAuth();
    return _firebaseAuth!.signInWithProvider(FacebookAuthProvider());
  }

  Future<UserCredential?> signInWithEmail(
      String username, String password) async {
    try {
      await initialAuth();
      return await _firebaseAuth!
          .signInWithEmailAndPassword(email: username, password: password);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserId() async {
    await initialAuth();
    return _firebaseAuth!.currentUser?.uid;
  }

  Future<UserCredential?> createUser(String username, String password) {
    return initialAuth().then((_) {
      return _firebaseAuth!
          .createUserWithEmailAndPassword(email: username, password: password);
    });
  }

  Future<void> forgetPassword(String username) async {
    try {
      await initialAuth();
      return _firebaseAuth!.sendPasswordResetEmail(email: username);
    } catch (e) {
      return;
    }
  }

  Future<int> changePassword(UserCredential credential, String newPass) async {
    try {
      credential.user?.updatePassword(newPass);
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code.toString().contains("weak-password")) {
          return 2;
        }
      }
      return 0;
    }
    return 1;
  }
}
