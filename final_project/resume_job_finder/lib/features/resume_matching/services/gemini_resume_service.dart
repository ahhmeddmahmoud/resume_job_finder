import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../core/config/gemini_config.dart';
import '../../career_preferences/models/career_preferences_model.dart';
import '../models/resume_analysis_model.dart';
import 'local_resume_analyzer.dart';

/// Calls Gemini AI with a model fallback chain to analyze a CV and match jobs.
/// Falls back automatically to [LocalResumeAnalyzer] if all Gemini calls fail.
class GeminiResumeService {
  GeminiResumeService({
    String? apiKey,
    List<String>? modelFallbackChain,
    LocalResumeAnalyzer? localAnalyzer,
  })  : _apiKey = apiKey ?? geminiApiKey,
        _models = modelFallbackChain ?? geminiModelFallbackChain,
        _localAnalyzer = localAnalyzer ?? const LocalResumeAnalyzer();

  final String _apiKey;
  final List<String> _models;
  final LocalResumeAnalyzer _localAnalyzer;
  String? _preferredModel;

  Future<ResumeAnalysisModel> analyzeResume({
    required String fileName,
    required String resumeText,
    CareerPreferencesModel? preferences,
  }) async {
    if (_apiKey.trim().isEmpty) {
      debugPrint(
        '[GeminiResumeService] GEMINI_API_KEY is empty; using the local analyzer.',
      );
      return _localAnalyzer.analyze(
        fileName: fileName,
        resumeText: resumeText,
        preferences: preferences,
      );
    }

    final prompt = _buildPrompt(
      resumeText: resumeText,
      preferences: preferences,
    );

    final orderedModels = <String>[
      if (_preferredModel != null) _preferredModel!,
      ..._models.where((m) => m != _preferredModel),
    ];

    Object? lastError;
    const totalTimeout = Duration(seconds: 25);
    final stopwatch = Stopwatch()..start();
    for (final modelName in orderedModels) {
      final remaining = totalTimeout - stopwatch.elapsed;
      if (remaining <= Duration.zero) break;
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.2,
            responseMimeType: 'application/json',
          ),
        );

        final response = await model
            .generateContent([Content.text(prompt)]).timeout(remaining);
        final rawText = response.text?.trim();
        if (rawText == null || rawText.isEmpty) {
          throw FormatException('استجابة فارغة من النموذج $modelName');
        }

        final decoded = _decodeJson(rawText);
        _preferredModel = modelName;
        final analysis = ResumeAnalysisModel.fromJson(
          {
            ...decoded,
            'isLocalFallback': false,
            'usedModel': modelName,
          },
          fileName: fileName,
        );
        if (analysis.skills.isEmpty && resumeText.trim().isNotEmpty) {
          final localAnalysis = _localAnalyzer.analyze(
            fileName: fileName,
            resumeText: resumeText,
            preferences: preferences,
          );
          if (localAnalysis.skills.isNotEmpty) return localAnalysis;
        }
        return analysis;
      } catch (e, stackTrace) {
        lastError = e;
        debugPrint(
          '[GeminiResumeService] Model "$modelName" failed: $e\n$stackTrace',
        );
        if (e is TimeoutException || stopwatch.elapsed >= totalTimeout) break;
        continue;
      }
    }

    debugPrint(
      '[GeminiResumeService] All Gemini models (${orderedModels.join(', ')}) failed. '
      'Last error: $lastError. Switching to LocalResumeAnalyzer.',
    );
    return _localAnalyzer.analyze(
      fileName: fileName,
      resumeText: resumeText,
      preferences: preferences,
    );
  }

  Map<String, dynamic> _decodeJson(String raw) {
    var cleaned = raw.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned
          .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
          .replaceFirst(RegExp(r'\s*```$'), '')
          .trim();
    }
    final decoded = jsonDecode(cleaned);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('تنسيق JSON غير صالح من Gemini.');
    }
    return decoded;
  }

  String _buildPrompt({
    required String resumeText,
    CareerPreferencesModel? preferences,
  }) {
    final prefsSection = preferences == null
        ? 'لم يحدد المستخدم تفضيلات مهنية بعد.'
        : '''
- التخصص المطلوب: ${preferences.track}
- مستوى الخبرة: ${preferences.experienceLevel}
- سنوات الخبرة: ${preferences.experienceYears}
- نوع العمل المفضل: ${preferences.workType}
- المدينة المفضلة: ${preferences.preferredCity}
''';

    return '''
أنت خبير توظيف ومحلل سير ذاتية تقنية.
قم بتحليل نص السيرة الذاتية التالي ومطابقته مع تفضيلات المستخدم، وأعد النتيجة بصيغة JSON فقط بدون أي نص إضافي أو Markdown.

تفضيلات المستخدم:
$prefsSection

نص السيرة الذاتية:
"""
$resumeText
"""

أعد كائن JSON بالبنية التالية تمامًا:
{
  "bestJobTitle": "المسمى الوظيفي الأنسب باللغة العربية أو الإنجليزية",
  "experienceYears": 2,
  "matchPercentage": 85,
  "summary": "ملخص احترافي قصير عن المرشح بالعربية (سطران كحد أقصى)",
  "skills": ["Skill 1", "Skill 2"],
  "matchedSkills": ["Skill 1", "Skill 2"],
  "strengths": ["نقطة قوة 1", "نقطة قوة 2"],
  "missingSkills": ["مهارة ناقصة 1", "مهارة ناقصة 2"],
  "recommendedJobs": [
    {
      "title": "Job Title",
      "companyType": "نوع الشركة أو القطاع",
      "location": "المدينة أو Remote",
      "workType": "Full-time / Remote / Hybrid",
      "matchPercentage": 88,
      "matchReason": "سبب التوافق بالعربية بشكل مختصر وواضح",
      "missingSkills": ["مهارة ناقصة إن وجدت"]
    }
  ]
}

الشروط:
- استخرج التخصص الأساسي من السيرة نفسها (المسمى والخبرة والمشاريع والمهارات). استخدم تفضيلات المستخدم لترتيب النتائج فقط، ولا تجعلها تستبدل تخصصًا واضحًا في السيرة.
- أدرج في skills المهارات المذكورة فعليًا في السيرة فقط، ولا تخترع مهارات غير موجودة.
- أعد من 4 إلى 6 وظائف في recommendedJobs مرتبة تنازليًا حسب matchPercentage (من 0 إلى 100).
- اعتمد فقط على المعلومات الموجودة في السيرة الذاتية وتفضيلات المستخدم.
''';
  }
}
