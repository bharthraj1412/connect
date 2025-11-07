import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    // Enable Firestore offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      ignoreUndefinedProperties: true,
    );
    // Set up Firestore emulator (for development)
    // Uncomment to use local emulator
    // FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  static FirebaseFirestore getFirestore() {
    return FirebaseFirestore.instance;
  }

  static Future<void> setNetworkSettings() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      sslEnabled: true,
    );
  }

  static Future<void> clearCache() async {
    await FirebaseFirestore.instance.clearPersistence();
  }
}
