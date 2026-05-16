import 'package:cloud_firestore/cloud_firestore.dart';

class CareerProfile {
  final String userId;
  final String interest;
  final List<String> skills;
  final String experienceLevel;
  final String aiFeedback;
  final int readinessScore;
  final DateTime updatedAt;

  CareerProfile({
    required this.userId,
    required this.interest,
    required this.skills,
    required this.experienceLevel,
    required this.aiFeedback,
    required this.readinessScore,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'interest': interest,
      'skills': skills,
      'experienceLevel': experienceLevel,
      'aiFeedback': aiFeedback,
      'readinessScore': readinessScore,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory CareerProfile.fromMap(Map<String, dynamic> map) {
    return CareerProfile(
      userId: map['userId'] ?? '',
      interest: map['interest'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      experienceLevel: map['experienceLevel'] ?? '',
      aiFeedback: map['aiFeedback'] ?? '',
      readinessScore: map['readinessScore'] ?? 0,
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
