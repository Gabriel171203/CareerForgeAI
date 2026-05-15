import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  // Disarankan menggunakan --dart-define=GEMINI_API_KEY=xxx saat flutter build, atau .env file 
  const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  return GeminiService(apiKey: apiKey);
});

class GeminiService {
  final GenerativeModel _model;

  GeminiService({required String apiKey})
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );

  /// Menganalisis profil input pengguna untuk menentukan tingkat kesiapan
  Future<String?> analyzeCareerProfile({
    required List<String> skills,
    required String interest,
    required String experience,
  }) async {
    if (_model.apiKey.isEmpty) {
      return "Simulasi AI (API Key belum di-setup):\n\nBerdasarkan profil Anda, Anda memiliki peluang besar di bidang **Software Engineering**. Kami merekomendasikan Anda untuk mulai membangun portofolio.";
    }

    final prompt = '''
    Sebagai seorang Konsultan Karir AI bernama "CareerForge AI", analisis profil pendaftar kerja berikut ini:
    - Keahlian teknis: \${skills.join(', ')}
    - Minat: \$interest
    - Pengalaman: \$experience
    
    Tugas Anda:
    1. Berikan kata-kata motivasi singkat (1 paragraf).
    2. Usulkan 3 nama peran/posisi pekerjaan yang paling cocok untuk mereka beserta alasannya.
    Gunakan format markdown yang bersih tanpa salam pembuka formal.
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      return "Error dari AI: \$e";
    }
  }
}
