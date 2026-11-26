import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/jsearch_config.dart';
import '../../career_preferences/models/career_preferences_model.dart';
import '../../resume_matching/models/resume_analysis_model.dart';

/// Loads real jobs from JSearch v5 and keeps results in memory for this session.
class JSearchJobsRepository {
  JSearchJobsRepository({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  final Map<String, List<JobMatchModel>> _cache = {};

  Future<List<JobMatchModel>> fetchJobs({
    required ResumeAnalysisModel analysis,
    required CareerPreferencesModel? preferences,
    required List<JobMatchModel> fallbackJobs,
  }) async {
    final apiKey = jsearchApiKey.trim();
    if (apiKey.isEmpty) {
      debugPrint(
          '[JSearchJobsRepository] JSEARCH_API_KEY is empty; using local jobs.');
      return fallbackJobs;
    }

    final role = _roleFromAnalysis(analysis);
    final city = _clean(preferences?.preferredCity);
    final location = city.isEmpty ? 'Egypt' : city;
    final skills = analysis.skills.take(3).toList();
    final cvTerm = role.isNotEmpty ? role : skills.join(' ');
    final preferredTrack = _clean(preferences?.track);
    final roleOrSkills = cvTerm.isEmpty
        ? preferredTrack
        : (preferredTrack.isNotEmpty &&
                !cvTerm.toLowerCase().contains(preferredTrack.toLowerCase())
            ? '$cvTerm $preferredTrack'
            : cvTerm);
    final query = roleOrSkills.isEmpty
        ? 'Software Developer in Egypt'
        : '$roleOrSkills in $location';
    final normalizedQuery =
        query.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    final sortedSkills =
        analysis.skills.map((s) => s.toLowerCase().trim()).toList()..sort();
    final fingerprint = [
      analysis.bestJobTitle.toLowerCase().trim(),
      analysis.experienceYears.toString(),
      ...sortedSkills,
      preferences?.track.toLowerCase().trim() ?? '',
      preferences?.experienceLevel.toLowerCase().trim() ?? '',
      preferences?.experienceYears.toString() ?? '',
      preferences?.workType.toLowerCase().trim() ?? '',
    ].join('|');
    final cacheKey = '$normalizedQuery|$fingerprint';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    try {
      final host = jsearchHost.trim().isEmpty
          ? 'jsearch.p.rapidapi.com'
          : jsearchHost.trim();
      final uri = Uri.https(host, '/search-v2', {
        'query': query,
        'country': 'eg',
        'num_pages': '1',
      });
      final response = await _client.get(uri, headers: {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': host,
      }).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        debugPrint(
          '[JSearchJobsRepository] /search returned HTTP ${response.statusCode}; using local jobs.',
        );
        return _cacheFallback(cacheKey, fallbackJobs);
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        debugPrint(
            '[JSearchJobsRepository] Invalid response JSON; using local jobs.');
        return _cacheFallback(cacheKey, fallbackJobs);
      }
      final rawData = decoded['data'];
      final rawJobs = rawData is Map
          ? rawData['jobs']
          : (rawData is List ? rawData : decoded['jobs']);
      if (rawJobs is! List || rawJobs.isEmpty) {
        debugPrint(
            '[JSearchJobsRepository] /search returned no jobs; using local jobs.');
        return _cacheFallback(cacheKey, fallbackJobs);
      }

      final jobs = rawJobs
          .whereType<Map>()
          .map((raw) => _mapJob(
                Map<String, dynamic>.from(raw),
                skills: analysis.skills,
                targetRole: analysis.bestJobTitle,
                preferences: preferences,
              ))
          .whereType<JobMatchModel>()
          .toList()
        ..sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
      if (jobs.isEmpty) return _cacheFallback(cacheKey, fallbackJobs);
      _cache[cacheKey] = jobs;
      return jobs;
    } catch (error) {
      debugPrint('[JSearchJobsRepository] Falling back to local jobs: $error');
      return _cacheFallback(cacheKey, fallbackJobs);
    }
  }

  List<JobMatchModel> _cacheFallback(
    String cacheKey,
    List<JobMatchModel> fallbackJobs,
  ) {
    _cache[cacheKey] = fallbackJobs;
    return fallbackJobs;
  }

  JobMatchModel? _mapJob(
    Map<String, dynamic> raw, {
    required List<String> skills,
    required String targetRole,
    required CareerPreferencesModel? preferences,
  }) {
    String? value(dynamic item) {
      if (item is String && item.trim().isNotEmpty) return item.trim();
      return null;
    }

    final title = value(raw['job_title']);
    if (title == null) return null;
    final company =
        value(raw['employer_name']) ?? value(raw['job_publisher']) ?? '';
    final remote = raw['job_is_remote'] == true;
    final location = value(raw['job_location']) ??
        [value(raw['job_city']), value(raw['job_country'])]
            .whereType<String>()
            .where((part) => part.isNotEmpty)
            .join(', ');
    final applyOptions = raw['apply_options'];
    final optionLink = applyOptions is List &&
            applyOptions.isNotEmpty &&
            applyOptions.first is Map
        ? value((applyOptions.first as Map)['apply_link'])
        : null;
    final applyUrl = value(raw['job_apply_link']) ?? optionLink;
    final types = raw['job_employment_types'];
    final employmentType = value(raw['job_employment_type']) ??
        (types is List && types.isNotEmpty ? value(types.first) : null) ??
        '';
    final description = value(raw['job_description']) ?? '';
    final searchable = '$title $description'.toLowerCase();
    final matched =
        skills.where((skill) => _containsSkill(searchable, skill)).toList();
    final preferenceTerms = <String>{
      targetRole,
      if (preferences?.track.trim().isNotEmpty == true) preferences!.track,
      if (preferences?.workType.trim().isNotEmpty == true)
        preferences!.workType,
    }.where((term) => term.trim().isNotEmpty).toList();
    final preferenceMatches = preferenceTerms
        .where((term) => _containsSkill(searchable, term))
        .toList();
    final denominator = skills.length + preferenceTerms.length;
    final score = denominator == 0
        ? 0
        : ((matched.length + preferenceMatches.length) * 100 / denominator)
            .round()
            .clamp(0, 100);
    final allMatched = {...matched, ...preferenceMatches}.toList();
    final missing = skills.where((skill) => !matched.contains(skill)).toList();
    final rawId = value(raw['job_id']) ?? value(raw['job_uid']);

    return JobMatchModel(
      id: rawId,
      title: title,
      companyType: company,
      location: location.isNotEmpty ? location : (remote ? 'Remote' : 'Egypt'),
      workType:
          employmentType.isNotEmpty ? employmentType : (remote ? 'Remote' : ''),
      matchPercentage: score,
      matchReason: '',
      missingSkills: missing,
      matchedSkills: allMatched,
      logoUrl: value(raw['employer_logo']),
      description: description,
      applyUrl: applyUrl,
      isRemote: remote,
      isRealJob: true,
    );
  }

  String _roleFromAnalysis(ResumeAnalysisModel analysis) {
    final title = _clean(analysis.bestJobTitle);
    if (title.isEmpty) return '';
    return title;
  }

  String _clean(String? value) => value?.trim() ?? '';

  bool _containsSkill(String text, String skill) {
    final normalized = skill.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    return text.contains(normalized);
  }
}
