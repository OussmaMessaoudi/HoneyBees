import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Updates or creates the user document in Firestore.
  /// Called at login or signup to make sure a user doc exists.
  Future<void> initUserDoc() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _db.collection('users').doc(user.uid);

    await docRef.set({
      'createdAt': FieldValue.serverTimestamp(),
      // Add any other default fields you want here
    }, SetOptions(merge: true));
  }

  /// Updates the daily earnings for the current user.
  /// Fixed: store dateKey as a literal map key, not as a dotted path.
  Future<void> updateDailyEarnings(double earnings) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _db.collection('users').doc(user.uid);

    // Use an ISO date string like "2025-08-23" as the map key
    final dateKey = DateTime.now().toIso8601String().split('T').first;

    await docRef.set({
      'dailyEarnings': {
        dateKey: earnings,
      }
    }, SetOptions(merge: true));
  }

  /// Records a payment request with email and amount.
  /// Fixed: store dateKey inside a map, not as a dotted path.
  Future<void> recordPayment(String email, double amount) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _db.collection('users').doc(user.uid);

    final dateKey = DateTime.now().toIso8601String().split('T').first;

    await docRef.set({
      'payments': {
        dateKey: {
          'email': email,
          'amount': amount,
        }
      }
    }, SetOptions(merge: true));
  }

  /// Reads the latest daily earnings for the user.
  Future<double?> getTodayEarnings() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final docRef = _db.collection('users').doc(user.uid);

    final snapshot = await docRef.get();
    if (!snapshot.exists) return null;

    final data = snapshot.data();
    if (data == null) return null;

    final dateKey = DateTime.now().toIso8601String().split('T').first;

    // Safely access the nested map
    if (data['dailyEarnings'] != null &&
        data['dailyEarnings'][dateKey] != null) {
      return (data['dailyEarnings'][dateKey] as num).toDouble();
    }

    return null;
  }

  /// Reads all payment records for the user.
  Future<Map<String, dynamic>?> getPayments() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final docRef = _db.collection('users').doc(user.uid);

    final snapshot = await docRef.get();
    if (!snapshot.exists) return null;

    final data = snapshot.data();
    if (data == null) return null;

    // 'payments' is stored as a map of dateKey -> {email, amount}
    return Map<String, dynamic>.from(data['payments'] ?? {});
  }
}
