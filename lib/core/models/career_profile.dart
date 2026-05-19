import 'package:cloud_firestore/cloud_firestore.dart';

class CareerProfile {
  final String userId;
  final String interest;
  final List<String> skills;
  final String experienceLevel;
  final String aiFeedback;
  final int readinessScore;
  final Map<String, double> analytics;
  final List<String> recommendations;
  final DateTime updatedAt;

  CareerProfile({
    required this.userId,
    required this.interest,
    required this.skills,
    required this.experienceLevel,
    required this.aiFeedback,
    required this.readinessScore,
    required this.analytics,
    required this.recommendations,
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
      'analytics': analytics,
      'recommendations': recommendations,
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
      analytics: Map<String, double>.from(map['analytics'] ?? {
        'Technical': 0.0,
        'Soft Skills': 0.0,
        'Experience': 0.0,
        'Culture': 0.0,
        'Leadership': 0.0,
      }),
      recommendations: List<String>.from(map['recommendations'] ?? []),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}


