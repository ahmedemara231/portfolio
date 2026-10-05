import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_options.dart';
import 'firestore_service.dart';

/// Both apps use the same backend and emulator configuration.
Future<void> initializeContentBackend() async {
  if (FirestoreService.useFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (FirestoreService.useEmulators) {
      // Configure Auth before Firestore creates its credentials provider.
      await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
      // Keep demo sign-ins in their own tab, like the separate production sites.
      await FirebaseAuth.instance.setPersistence(Persistence.SESSION);
      FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
      await FirebaseStorage.instance.useStorageEmulator('127.0.0.1', 9199);
    }
  }
  await FirestoreService.initialize();
}
