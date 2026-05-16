import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  // Key is now securely fetched from --dart-define environment variables
  const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  return GeminiService(apiKey: apiKey);
});

class GeminiService {
  final GenerativeModel _model;
  final String _apiKey;

  GeminiService({required String apiKey})
      : _apiKey = apiKey.trim(),
        _model = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: apiKey.trim(),
        );

  /// Menganalisis profil input pengguna untuk menentukan tingkat kesiapan
  Future<String?> analyzeCareerProfile({
    required List<String> skills,
    required String interest,
    required String experience,
  }) async {
    if (_apiKey.isEmpty) {
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
      print("Gemini Analysis Error: $e");
      return "Error dari AI: $e";
    }
  }

  ChatSession startInterviewChat(String role) {
    return _model.startChat(history: [
      Content.text(
        'You are an expert HR and Technical Interviewer at a top-tier global company. '
        'Conduct a professional mock interview for a candidate applying for: $role. '
        '1. Be professional and challenging but encouraging. '
        '2. Ask ONE question at a time. '
        '3. After each answer, give brief feedback and ask the next question. '
        '4. Start by introducing yourself and asking the candidate to introduce themselves. '
        '5. If the user says "DONE" or "SELESAI", provide a performance summary.'
      ),
    ]);
  }

  Future<String> sendInterviewMessage(ChatSession session, String message) async {
    if (_apiKey.isEmpty) {
      return "Simulasi AI: (Tanggapan simulasi) Jawaban yang bagus! Lalu, apa tantangan terbesar yang pernah Anda selesaikan?";
    }
    
    try {
      final response = await session.sendMessage(Content.text(message));
      return response.text ?? 'Tidak ada respons.';
    } catch (e) {
      print("Gemini Error: $e");
      return "Gagal mengirim pesan: $e";
    }
  }
}
