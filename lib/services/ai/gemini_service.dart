import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  // Key is now securely fetched from --dart-define environment variables
  const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  return GeminiService(apiKey: apiKey);
});

class GeminiService   {
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
        'Your name is Forge, a premier Career Coach and Technical Interviewer at CareerForge AI. '
        'Conduct a professional mock interview for a candidate applying for: $role. '
        'Personality: Professional, slightly challenging, insightful, and encouraging. '
        '1. Always introduce yourself as Forge in the beginning. '
        '2. Ask ONE question at a time. '
        '3. After each answer, give brief feedback and ask the next question. '
        '4. If the user says "DONE" or "SELESAI", provide a performance summary.'
      ),
    ]);
  }

  ChatSession startInterviewChatWithHistory(
    String role, 
    List<Content> history, {
    List<String>? skills, 
    String? experience,
    bool isMentor = false,
  }) {
    final profileContext = 'Candidate Profile:\n'
        '- Target Role: $role\n'
        '- Skills: ${skills?.join(', ') ?? 'Not specified'}\n'
        '- Experience: ${experience ?? 'Not specified'}';

    final systemInstruction = isMentor
        ? 'Your name is Forge, a premier Career Mentor and Coach. \n\n'
          '$profileContext\n\n'
          'ROLE: You are here to provide advice, answer questions about career growth, job hunting, salary negotiation, and roadmap building. '
          'BEHAVIOR: Be supportive, insightful, and detailed. Do NOT just ask questions; provide solutions and guidance. '
          'Introduce yourself as Forge, your Career Mentor.'
        : 'Your name is Forge, a premier Technical Interviewer. \n\n'
          '$profileContext\n\n'
          'ROLE: You are conducting a professional mock interview. '
          'BEHAVIOR: Professional, slightly challenging. Ask ONE question at a time. Provide brief feedback after answers. '
          'Introduce yourself as Forge, your Interviewer.';

    return _model.startChat(history: [
      Content.text(systemInstruction),
      ...history,
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
      return "Error: $e";
    }

  }

  Future<Map<String, dynamic>> analyzeInterviewPerformance(List<Map<String, dynamic>> history) async {
    if (_apiKey.isEmpty) {
      return {
        'scores': {'Technical': 7.5, 'Soft Skills': 8.0, 'Experience': 6.5, 'Culture': 7.0, 'Leadership': 5.0},
        'readinessScore': 68,
        'feedback': "Bagus! Terus tingkatkan kemampuan teknis Anda.",
      };
    }

    final chatContext = history.map((m) => "${m['isUser'] ? 'User' : 'Forge'}: ${m['text']}").join('\n');
    
    final prompt = '''
    Analisis transkrip interview berikut dan berikan evaluasi mendalam:
    \n$chatContext\n
    
    Berikan respons dalam format JSON murni:
    {
      "scores": {
        "Technical": (skor 0-10),
        "Soft Skills": (skor 0-10),
        "Experience": (skor 0-10),
        "Culture": (skor 0-10),
        "Leadership": (skor 0-10)
      },
      "readinessScore": (rata-rata skor keseluruhan 0-100),
      "feedback": "Penjelasan singkat tentang performa dan saran perbaikan"
    }
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      // Basic JSON cleaning if Gemini adds markdown blocks
      final cleanJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final Map<String, dynamic> data = jsonDecode(cleanJson);
      return data;
    } catch (e) {
      print("Analysis Error: $e");
      return {
        'scores': {'Technical': 5.0, 'Soft Skills': 5.0, 'Experience': 5.0, 'Culture': 5.0, 'Leadership': 5.0},
        'readinessScore': 50,
        'feedback': "Gagal menganalisis: $e",
      };
    }
  }

  Future<List<String>> getCareerRecommendations(Map<String, double> scores, String interest) async {

    if (_apiKey.isEmpty) {
      return [
        "Selesaikan project dengan Flutter & Riverpod",
        "Latih komunikasi publik untuk Soft Skill",
        "Pelajari System Design untuk peran $interest",
      ];
    }

    final gaps = scores.entries.where((e) => e.value < 7.0).map((e) => e.key).join(', ');
    
    final prompt = '''
    Berdasarkan skor kesiapan kerja (Technical, Soft Skills, Experience, Culture, Leadership) untuk bidang $interest, 
    pengguna memiliki kekurangan di area: $gaps.
    
    Berikan 3 poin tindakan konkret (pendek, maks 10 kata per poin) yang harus mereka pelajari atau lakukan untuk meningkatkan skor tersebut.
    Tampilkan hanya list item tanpa kata pengantar.
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      return text.split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.replaceFirst(RegExp(r'^[\-\*\d\.]+\s*'), '').trim())
          .take(3)
          .toList();
    } catch (e) {
      print("Recommendations Error: $e");
      return ["Terus berlatih interview", "Perdalam skill utama", "Minta feedback mentor"];
    }
  }
}


