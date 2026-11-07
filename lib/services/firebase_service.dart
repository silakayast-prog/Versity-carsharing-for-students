import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'ride_service.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static bool _initialized = false;

  /// Initialize Firebase safely with fallback options
  static Future<void> init() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDemoApiKeyForVersityMobileApp",
          appId: "1:123456789:android:demo123456",
          messagingSenderId: "123456789",
          projectId: "versity-mobile-app",
        ),
      );
      _initialized = true;
      debugPrint('Firebase successfully initialized!');
    } catch (e) {
      debugPrint('Firebase init fallback: $e');
    }
  }

  // --- AUTHENTICATION ---
  static User? get currentUser => _auth.currentUser;

  static Future<UserCredential?> registerUser({
    required String email,
    required String password,
    required String adSoyad,
  }) async {
    try {
      await init();
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (cred.user != null) {
        await cred.user!.updateDisplayName(adSoyad);
        // Save user profile in Firestore
        await _db.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'ad_soyad': adSoyad,
          'okul_email': email,
          'aktif_rol': 'yolcu',
          'created_at': FieldValue.serverTimestamp(),
        });
      }
      return cred;
    } catch (e) {
      debugPrint('Firebase Register Error: $e');
      rethrow;
    }
  }

  static Future<UserCredential?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await init();
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      debugPrint('Firebase Login Error: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Firebase SignOut Error: $e');
    }
  }

  // --- FIRESTORE RIDES REALTIME DATABASE ---
  static Future<void> createRideInFirestore(RideItem ride) async {
    try {
      await init();
      final docRef = _db.collection('rides').doc(ride.id);
      await docRef.set({
        'id': ride.id,
        'driver_name': ride.driverName,
        'rating': ride.rating,
        'trips': ride.trips,
        'badge': ride.badge,
        'from_time': ride.fromTime,
        'from_location': ride.fromLocation,
        'duration': ride.duration,
        'to_time': ride.toTime,
        'to_location': ride.toLocation,
        'price': ride.price,
        'available_seat_count': ride.availableSeatCount,
        'vehicle_type': ride.vehicleType,
        'driver_description': ride.driverDescription,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore createRide Error: $e');
    }
  }

  static Future<bool> bookSeatInFirestore(String rideId) async {
    try {
      await init();
      final docRef = _db.collection('rides').doc(rideId);
      return await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return false;

        final currentSeats = snapshot.get('available_seat_count') as int? ?? 0;
        if (currentSeats > 0) {
          transaction.update(docRef, {'available_seat_count': currentSeats - 1});
          return true;
        }
        return false;
      });
    } catch (e) {
      debugPrint('Firestore bookSeat Error: $e');
      return false;
    }
  }
}
