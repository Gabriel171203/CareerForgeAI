import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/firebase_auth_service.dart';
import '../../core/models/career_profile.dart';

final careerRepositoryProvider = Provider<CareerRepository>((ref) {
  return CareerRepository(FirebaseFirestore.instance);
});

class CareerRepository {
  final FirebaseFirestore _firestore;

  CareerRepository(this._firestore);

  CollectionReference get _profiles => _firestore.collection('profiles');

  Future<void> saveProfile(CareerProfile profile) async {
    await _profiles.doc(profile.userId).set(profile.toMap());
  }

  Stream<CareerProfile?> watchProfile(String userId) {
    return _profiles.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return CareerProfile.fromMap(snapshot.data() as Map<String, dynamic>);
    });
  }

  Future<CareerProfile?> getProfile(String userId) async {
    final doc = await _profiles.doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    return CareerProfile.fromMap(doc.data() as Map<String, dynamic>);
  }
}

final userProfileProvider = StreamProvider<CareerProfile?>((ref) {
  final auth = ref.watch(authStateProvider).value;
  if (auth == null) return Stream.value(null);
  return ref.watch(careerRepositoryProvider).watchProfile(auth.uid);
});
