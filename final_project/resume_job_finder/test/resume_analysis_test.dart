import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/features/career_preferences/models/career_preferences_model.dart';
import 'package:resume_job_finder/features/resume_matching/services/gemini_resume_service.dart';
import 'package:resume_job_finder/features/resume_matching/services/local_resume_analyzer.dart';

void main() {
  const analyzer = LocalResumeAnalyzer();

  test('CV skills take priority over a conflicting preferred track', () {
    final result = analyzer.analyze(
      fileName: 'frontend.pdf',
      resumeText: 'React TypeScript JavaScript HTML CSS frontend projects',
      preferences: const CareerPreferencesModel(
        track: 'Flutter',
        experienceLevel: 'Junior',
        experienceYears: 1,
        workType: 'Full-time',
        preferredCity: 'Cairo',
      ),
    );

    expect(result.bestJobTitle, 'Frontend Developer');
    expect(result.skills, containsAll(['React', 'TypeScript', 'JavaScript']));
    expect(result.skills, isNot(contains('Java')));
    expect(result.recommendedJobs, isNotEmpty);
    expect(
      result.recommendedJobs.every((job) => !job.title.contains('Flutter')),
      isTrue,
    );
  });

  test('Data skills produce a data analyst track and matching sample jobs', () {
    final result = analyzer.analyze(
      fileName: 'data.pdf',
      resumeText: 'Python SQL Excel Power BI pandas data analyst',
    );

    expect(result.bestJobTitle, 'Data Analyst');
    expect(result.recommendedJobs.first.title, contains('Data Analyst'));
    expect(result.skills, containsAll(['Python', 'SQL / SQLite', 'Power BI']));
  });

  test('missing Gemini key uses the local analyzer immediately', () async {
    final service = GeminiResumeService(apiKey: '', localAnalyzer: analyzer);
    final result = await service.analyzeResume(
      fileName: 'backend.pdf',
      resumeText: 'Python Django FastAPI PostgreSQL backend developer',
    );

    expect(result.isLocalFallback, isTrue);
    expect(result.bestJobTitle, 'Backend Developer');
  });
}
