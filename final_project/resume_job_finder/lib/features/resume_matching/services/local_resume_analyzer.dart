import '../../career_preferences/models/career_preferences_model.dart';
import '../models/resume_analysis_model.dart';

/// Deterministic local CV analyzer used as a fallback when Gemini API is unavailable.
class LocalResumeAnalyzer {
  const LocalResumeAnalyzer();

  static const Map<String, List<String>> _skillKeywords = {
    'Flutter': ['flutter'],
    'Dart': ['dart'],
    'BLoC / Cubit': ['bloc', 'cubit', 'flutter_bloc'],
    'Provider / Riverpod': ['provider', 'riverpod'],
    'GetX': ['getx'],
    'Firebase': ['firebase', 'firestore', 'firebase auth', 'fcm'],
    'REST APIs': ['rest', 'restful', 'dio', 'http', 'retrofit', 'api'],
    'GraphQL': ['graphql'],
    'Git & GitHub': ['git', 'github', 'gitlab', 'bitbucket'],
    'Clean Architecture': ['clean architecture', 'mvvm', 'mvc', 'solid'],
    'SQL / SQLite': ['sql', 'sqlite', 'sqflite', 'mysql', 'postgresql'],
    'React': ['react', 'reactjs', 'next.js', 'nextjs'],
    'TypeScript': ['typescript'],
    'JavaScript': ['javascript', 'es6'],
    'HTML & CSS': ['html', 'css', 'tailwind', 'sass'],
    'Node.js': ['node.js', 'nodejs', 'express', 'nestjs'],
    'Python': ['python', 'django', 'fastapi', 'flask'],
    'Java': ['java', 'spring', 'spring boot'],
    'C# / .NET': ['c#', '.net', 'asp.net'],
    'Kotlin': ['kotlin', 'jetpack compose', 'android sdk'],
    'Swift': ['swift', 'swiftui', 'uikit', 'ios'],
    'Docker': ['docker', 'kubernetes', 'ci/cd'],
    'Unit Testing': ['unit test', 'testing', 'mockito', 'bloc_test'],
    'UI/UX & Figma': ['figma', 'ui/ux', 'material design'],
    'Excel': ['microsoft excel', 'excel'],
    'Power BI': ['power bi', 'powerbi'],
    'Tableau': ['tableau'],
    'Pandas / NumPy': ['pandas', 'numpy'],
    'Machine Learning': ['machine learning', 'scikit-learn', 'pytorch'],
  };

  static const Map<String, List<String>> _trackCoreSkills = {
    'Flutter': [
      'Flutter',
      'Dart',
      'BLoC / Cubit',
      'Firebase',
      'REST APIs',
      'Clean Architecture',
      'Git & GitHub',
      'Unit Testing'
    ],
    'Frontend': [
      'React',
      'TypeScript',
      'JavaScript',
      'HTML & CSS',
      'REST APIs',
      'Git & GitHub',
      'UI/UX & Figma'
    ],
    'Backend': [
      'Node.js',
      'Python',
      'Java',
      'SQL / SQLite',
      'REST APIs',
      'Docker',
      'Git & GitHub'
    ],
    'Full-stack': [
      'React',
      'Node.js',
      'TypeScript',
      'SQL / SQLite',
      'REST APIs',
      'Docker',
      'Git & GitHub'
    ],
    'Android': [
      'Kotlin',
      'Java',
      'REST APIs',
      'Firebase',
      'Clean Architecture',
      'Git & GitHub',
      'Unit Testing'
    ],
    'iOS': [
      'Swift',
      'REST APIs',
      'Firebase',
      'Clean Architecture',
      'Git & GitHub',
      'Unit Testing'
    ],
    'Software Engineer': [
      'Clean Architecture',
      'REST APIs',
      'SQL / SQLite',
      'Git & GitHub',
      'Unit Testing',
      'Docker'
    ],
    'Data / AI': [
      'Python',
      'SQL / SQLite',
      'Excel',
      'Power BI',
      'Tableau',
      'Pandas / NumPy',
      'Machine Learning',
      'Git & GitHub',
    ],
  };

  ResumeAnalysisModel analyze({
    required String fileName,
    required String resumeText,
    CareerPreferencesModel? preferences,
  }) {
    final lowerText = resumeText.toLowerCase();
    final extractedSkills = _extractSkills(lowerText);
    final experienceYears = _estimateExperienceYears(lowerText, preferences);
    final targetTrack = _resolveTrack(extractedSkills, preferences);
    final coreSkills =
        _trackCoreSkills[targetTrack] ?? _trackCoreSkills['Software Engineer']!;

    final matchedSkills =
        coreSkills.where((skill) => extractedSkills.contains(skill)).toList();
    final effectiveMatchedSkills =
        matchedSkills.isNotEmpty ? matchedSkills : extractedSkills;

    final missingSkills = coreSkills
        .where((skill) => !extractedSkills.contains(skill))
        .take(5)
        .toList();

    final strengths =
        _buildStrengths(extractedSkills, experienceYears, targetTrack);
    final recommendedJobs = _buildMatchedJobs(
      extractedSkills: extractedSkills,
      experienceYears: experienceYears,
      targetTrack: targetTrack,
      preferences: preferences,
    );

    final coreRatio = coreSkills.isEmpty
        ? 0.5
        : effectiveMatchedSkills.length / coreSkills.length;
    final expBonus = experienceYears >= 3 ? 15 : (experienceYears >= 1 ? 8 : 4);
    final topJobScore =
        recommendedJobs.isNotEmpty ? recommendedJobs.first.matchPercentage : 45;
    final computedOverall =
        (((coreRatio * 75 + expBonus) * 0.5) + (topJobScore * 0.5)).round();
    final overallMatchPercentage = extractedSkills.isNotEmpty
        ? computedOverall.clamp(35, 96)
        : computedOverall.clamp(25, 80);

    final bestJobTitle = switch (targetTrack) {
      'Flutter' => 'Flutter Developer',
      'Frontend' => 'Frontend Developer',
      'Backend' => 'Backend Developer',
      'Full-stack' => 'Full-stack Developer',
      'Android' => 'Android Developer',
      'iOS' => 'iOS Developer',
      'Data / AI' => 'Data Analyst',
      _ => 'Software Engineer',
    };
    final summary =
        'مرشح في مسار $targetTrack بخبرة تقديرية $experienceYears سنوات، بنسبة توافق إجمالية $overallMatchPercentage% مع ${extractedSkills.length} مهارة تقنية مستخرجة من السيرة الذاتية.';

    return ResumeAnalysisModel(
      fileName: fileName,
      bestJobTitle: bestJobTitle,
      experienceYears: experienceYears,
      matchPercentage: overallMatchPercentage,
      summary: summary,
      skills: extractedSkills,
      matchedSkills: effectiveMatchedSkills,
      strengths: strengths,
      missingSkills: missingSkills.isNotEmpty
          ? missingSkills
          : ['التوسع في الاختبارات الآلية (Unit Testing) وCI/CD'],
      recommendedJobs: recommendedJobs,
      isLocalFallback: true,
      usedModel: 'local-fallback-analyzer',
      analyzedAt: DateTime.now(),
    );
  }

  List<String> _extractSkills(String lowerText) {
    final found = <String>[];
    for (final entry in _skillKeywords.entries) {
      final hasMatch = entry.value.any((keyword) {
        final pattern = RegExp(
          '(?<![a-z0-9])${RegExp.escape(keyword)}(?![a-z0-9])',
        );
        return pattern.hasMatch(lowerText);
      });
      if (hasMatch) {
        found.add(entry.key);
      }
    }
    return found;
  }

  int _estimateExperienceYears(
    String lowerText,
    CareerPreferencesModel? preferences,
  ) {
    final expRegex = RegExp(r'(\d+)\+?\s*(?:years?|yrs?)');
    final match = expRegex.firstMatch(lowerText) ??
        RegExp(r'(\d+)\s*(?:سنوات|سنة)').firstMatch(lowerText);
    if (match != null) {
      final parsed = int.tryParse(match.group(1) ?? '');
      if (parsed != null && parsed >= 0 && parsed <= 30) {
        return parsed;
      }
    }
    return preferences?.experienceYears ?? 1;
  }

  String _resolveTrack(
    List<String> skills,
    CareerPreferencesModel? preferences,
  ) {
    final preferredTrack = _normalizeTrack(preferences?.track);
    if (skills.isEmpty) return preferredTrack ?? 'Software Engineer';

    final rankedTracks = _trackCoreSkills.entries
        .map((entry) => (
              track: entry.key,
              score: entry.value.where(skills.contains).length,
            ))
        .where((entry) => entry.score > 0)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    if (rankedTracks.isEmpty) return preferredTrack ?? 'Software Engineer';
    final topScore = rankedTracks.first.score;
    for (final candidate in rankedTracks) {
      if (candidate.score == topScore && candidate.track == preferredTrack) {
        return candidate.track;
      }
    }
    return rankedTracks.first.track;
  }

  String? _normalizeTrack(String? track) {
    final normalized = track?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) return null;
    if (normalized.contains('data') || normalized.contains('ai')) {
      return 'Data / AI';
    }
    if (normalized.contains('flutter') || normalized == 'mobile') {
      return 'Flutter';
    }
    if (normalized.contains('front')) return 'Frontend';
    if (normalized.contains('back')) return 'Backend';
    if (normalized.contains('full')) return 'Full-stack';
    if (normalized.contains('android')) return 'Android';
    if (normalized.contains('ios')) return 'iOS';
    if (normalized.contains('software')) return 'Software Engineer';
    return null;
  }

  List<String> _buildStrengths(
    List<String> skills,
    int experienceYears,
    String track,
  ) {
    final list = <String>[];
    if (skills.isNotEmpty) {
      list.add(
          'توافق واضح مع مسار $track عبر مهارات: ${skills.take(4).join('، ')}.');
    }
    if (skills.contains('Clean Architecture') ||
        skills.contains('BLoC / Cubit')) {
      list.add('خبرة في هيكلة التطبيقات وإدارة الحالة بشكل احترافي.');
    }
    if (skills.contains('Firebase') || skills.contains('REST APIs')) {
      list.add('القدرة على ربط التطبيقات بالخدمات السحابية وواجهات البرمجة.');
    }
    if (experienceYears >= 2) {
      list.add(
          'خبرة عملية تقديرية ($experienceYears سنوات) تدعم الجاهزية لسوق العمل.');
    }
    if (list.isEmpty) {
      list.add(
          'سيرة ذاتية منظمة قابلة للتطوير بإضافة تفاصيل المشاريع التقنية.');
    }
    return list;
  }

  List<JobMatchModel> _buildMatchedJobs({
    required List<String> extractedSkills,
    required int experienceYears,
    required String targetTrack,
    CareerPreferencesModel? preferences,
  }) {
    final city = preferences?.preferredCity ?? 'Cairo';
    final workType = preferences?.workType ?? 'Full-time';
    final level = preferences?.experienceLevel ?? 'Junior';

    final templates = <({
      String title,
      String companyType,
      String track,
      String location,
      String workType,
      List<String> requiredSkills,
    })>[
      (
        title: '$level Flutter Mobile Developer',
        companyType: 'شركة تطوير تطبيقات ومشاريع رقمية',
        track: 'Flutter',
        location: city,
        workType: workType,
        requiredSkills: [
          'Flutter',
          'Dart',
          'BLoC / Cubit',
          'Firebase',
          'REST APIs'
        ],
      ),
      (
        title: 'Cross-Platform Mobile Engineer',
        companyType: 'شركة تقنية مالية (FinTech)',
        track: 'Flutter',
        location: 'Remote',
        workType: 'Remote',
        requiredSkills: [
          'Flutter',
          'Clean Architecture',
          'REST APIs',
          'Unit Testing',
          'Git & GitHub'
        ],
      ),
      (
        title: '$level Frontend Developer (React)',
        companyType: 'منصة تجارة إلكترونية',
        track: 'Frontend',
        location: city,
        workType: workType,
        requiredSkills: [
          'React',
          'TypeScript',
          'JavaScript',
          'HTML & CSS',
          'REST APIs'
        ],
      ),
      (
        title: '$level Backend Engineer',
        companyType: 'شركة حلول سحابية',
        track: 'Backend',
        location: city,
        workType: workType,
        requiredSkills: [
          'Node.js',
          'Python',
          'SQL / SQLite',
          'REST APIs',
          'Docker'
        ],
      ),
      (
        title: '$level Full-Stack Software Engineer',
        companyType: 'شركة برمجيات ناشئة (Startup)',
        track: 'Full-stack',
        location: 'Hybrid / $city',
        workType: 'Hybrid',
        requiredSkills: [
          'React',
          'Node.js',
          'TypeScript',
          'REST APIs',
          'Git & GitHub'
        ],
      ),
      (
        title: '$level Android Developer (Kotlin)',
        companyType: 'شركة خدمات ذكية',
        track: 'Android',
        location: city,
        workType: workType,
        requiredSkills: [
          'Kotlin',
          'Java',
          'REST APIs',
          'Firebase',
          'Clean Architecture'
        ],
      ),
      (
        title: '$level Software Engineer',
        companyType: 'شركة أنظمة مؤسسية',
        track: 'Software Engineer',
        location: city,
        workType: workType,
        requiredSkills: [
          'Clean Architecture',
          'REST APIs',
          'SQL / SQLite',
          'Git & GitHub',
          'Unit Testing'
        ],
      ),
      (
        title: '$level Data Analyst',
        companyType: 'شركة تحليلات وذكاء أعمال',
        track: 'Data / AI',
        location: city,
        workType: workType,
        requiredSkills: [
          'Python',
          'SQL / SQLite',
          'Excel',
          'Power BI',
          'Pandas / NumPy',
        ],
      ),
    ];

    final scored = templates.map((job) {
      final matched =
          job.requiredSkills.where((s) => extractedSkills.contains(s)).toList();
      final missing = job.requiredSkills
          .where((s) => !extractedSkills.contains(s))
          .toList();

      final skillRatio = job.requiredSkills.isEmpty
          ? 0.5
          : matched.length / job.requiredSkills.length;
      final trackBonus = job.track == targetTrack ? 22 : 6;
      final expBonus = experienceYears >= 1 ? 8 : 3;
      final rawScore = (skillRatio * 70 + trackBonus + expBonus).round();
      final percentage = rawScore.clamp(25, 96);

      final reason = matched.isNotEmpty
          ? 'تطابق في المهارات: ${matched.join('، ')}${job.track == targetTrack ? ' مع توافق مباشر مع مسار $targetTrack.' : '.'}'
          : 'ملائمة مبدئية لمستوى الخبرة ($experienceYears سنوات) مع إمكانية التطوير في المهارات المطلوبة.';

      return (
        track: job.track,
        match: JobMatchModel(
          title: job.title,
          companyType: job.companyType,
          location: job.location,
          workType: job.workType,
          matchPercentage: percentage,
          matchReason: reason,
          missingSkills: missing,
          matchedSkills: matched,
        ),
      );
    }).toList();

    final relevant = scored
        .where((job) =>
            job.track == targetTrack || job.match.matchedSkills.length >= 2)
        .map((job) => job.match)
        .toList()
      ..sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    return relevant.take(5).toList();
  }
}
