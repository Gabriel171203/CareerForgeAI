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

  // --- Session Management ---

  Future<String> createNewSession(String userId, String title, {String mode = 'hr'}) async {
    final doc = await _profiles.doc(userId).collection('sessions').add({
      'title': title,
      'mode': mode,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }


  Future<void> deleteSession(String userId, String sessionId) async {
    // Delete messages first (Firestore requires manual subcollection deletion)
    final messages = await _profiles.doc(userId).collection('sessions').doc(sessionId).collection('messages').get();
    for (var doc in messages.docs) {
      await doc.reference.delete();
    }
    await _profiles.doc(userId).collection('sessions').doc(sessionId).delete();
  }

  Future<void> updateSessionTitle(String userId, String sessionId, String newTitle) async {
    await _profiles.doc(userId).collection('sessions').doc(sessionId).update({
      'title': newTitle,
    });
  }

  Future<void> markSessionAsFinished(String userId, String sessionId) async {
    await _profiles.doc(userId).collection('sessions').doc(sessionId).update({
      'isFinished': true,
    });
  }

  Stream<List<Map<String, dynamic>>> getSessions(String userId) {
    return _profiles
        .doc(userId)
        .collection('sessions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
          'id': doc.id, 
          'isFinished': false, // default
          ...doc.data()
        }).toList());
  }

  // --- Message Management ---

  Future<void> saveMessage(String userId, String sessionId, {required String text, required bool isUser}) async {
    await _profiles
        .doc(userId)
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .add({
      'text': text,
      'isUser': isUser,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getMessagesStream(String userId, String sessionId) {
    return _profiles
        .doc(userId)
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}

final userProfileProvider = StreamProvider<CareerProfile?>((ref) {
  final auth = ref.watch(authStateProvider).value;
  if (auth == null) return Stream.value(null);
  return ref.watch(careerRepositoryProvider).watchProfile(auth.uid);
});

// Provider for specific session messages
final chatMessagesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, sessionId) {
  final auth = ref.watch(authStateProvider).value;
  if (auth == null || sessionId.isEmpty) return Stream.value([]);
  return ref.watch(careerRepositoryProvider).getMessagesStream(auth.uid, sessionId);
});

// Provider for all sessions
final interviewSessionsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final auth = ref.watch(authStateProvider).value;
  if (auth == null) return Stream.value([]);
  return ref.watch(careerRepositoryProvider).getSessions(auth.uid);
});

// Selected Session State
final selectedSessionIdProvider = StateProvider<String>((ref) => '');
