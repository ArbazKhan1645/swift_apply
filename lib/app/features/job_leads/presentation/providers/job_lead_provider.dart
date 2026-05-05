import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:swift_apply/app/features/job_leads/data/models/job_lead_model.dart';
import 'package:swift_apply/app/features/job_leads/data/repositories/job_lead_repository.dart';
import 'package:swift_apply/app/features/settings/data/repositories/settings_repository.dart';

@injectable
class JobLeadProvider extends ChangeNotifier {
  JobLeadProvider(this._repository, this._settingsRepository);

  final JobLeadRepository _repository;
  final SettingsRepository _settingsRepository;

  bool _loading = false;
  String _query = '';
  JobLeadStatus? _statusFilter;
  List<JobLead> _items = const [];

  bool get loading => _loading;
  String get query => _query;
  JobLeadStatus? get statusFilter => _statusFilter;
  List<JobLead> get items => _items;
  List<JobLead> get visibleItems {
    return _items.where((lead) {
      final haystack =
          '${lead.company} ${lead.position} ${lead.location} ${lead.contactEmail} ${lead.contactPhone} ${lead.rawText}'
              .toLowerCase();
      final matchesQuery = haystack.contains(_query.toLowerCase());
      final matchesStatus =
          _statusFilter == null || lead.status == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  List<JobLead> get dueFollowUps {
    return _items.where((lead) => lead.isFollowUpDue).toList();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _items = await _repository.getAll();
    _loading = false;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setStatusFilter(JobLeadStatus? value) {
    _statusFilter = value;
    notifyListeners();
  }

  Future<JobLead> addFromPaste(String rawText) async {
    final settings = await _settingsRepository.getSettings();
    final parsed = parseJobText(
      rawText,
      fallbackPosition: settings.targetPosition,
    );
    final duplicate = await _repository.findDuplicate(
      rawText: parsed.rawText,
      sourceUrl: parsed.sourceUrl,
    );
    if (duplicate != null) {
      await load();
      return duplicate;
    }
    final id = await _repository.add(parsed);
    await load();
    return parsed.copyWith(id: id);
  }

  Future<void> update(JobLead lead) async {
    await _repository.update(lead);
    await load();
  }

  Future<void> delete(JobLead lead) async {
    final id = lead.id;
    if (id == null) return;
    await _repository.delete(id);
    await load();
  }

  static JobLead parseJobText(
    String rawText, {
    required String fallbackPosition,
  }) {
    final text = rawText.trim();
    final email = _firstMatch(text, RegExp(r'[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}'));
    final phone = _firstMatch(text, RegExp(r'(\+?\d[\d\s().-]{6,}\d)'));
    final url = _firstMatch(
      text,
      RegExp(r'https?:\/\/[^\s]+', caseSensitive: false),
    );
    final salary = _firstMatch(
      text,
      RegExp(
        r'((AED|USD|\$|PKR|SAR)\s?[0-9][0-9,]*(\s?-\s?[0-9][0-9,]*)?)',
        caseSensitive: false,
      ),
    );
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final source = _sourceFromUrl(url);
    final titleCompany = _titleCompanyFromSharedText(text);
    final position = _cleanValue(
      _valueAfterLabel(text, ['position', 'job title', 'title', 'role']) ??
          titleCompany.$1 ??
          (lines.isNotEmpty ? lines.first : fallbackPosition),
    );
    final company = _cleanValue(
      _valueAfterLabel(text, ['company', 'organization', 'employer']) ??
          titleCompany.$2 ??
          _guessCompany(lines, source),
    );
    final location = _cleanValue(
      _valueAfterLabel(text, ['location', 'city']) ?? '',
    );
    final now = DateTime.now();

    return JobLead(
      company: company,
      position: position,
      location: location,
      salary: salary,
      sourceUrl: url,
      contactEmail: email,
      contactPhone: phone,
      rawText: text,
      notes: '',
      followUpAt: now.add(const Duration(days: 7)),
      createdAt: now,
      updatedAt: now,
    );
  }

  static String _firstMatch(String text, RegExp pattern) {
    return pattern.firstMatch(text)?.group(0)?.trim().replaceAll(')', '') ?? '';
  }

  static String? _valueAfterLabel(String text, List<String> labels) {
    for (final label in labels) {
      final match = RegExp(
        '$label\\s*[:\\-]\\s*(.+)',
        caseSensitive: false,
        multiLine: true,
      ).firstMatch(text);
      final value = match?.group(1)?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static (String?, String?) _titleCompanyFromSharedText(String text) {
    final firstLine = text.split(RegExp(r'\r?\n')).first.trim();
    final patterns = [
      RegExp(
        r'(?:check out|view|apply to|see)?\s*(?:this\s+)?job\s+(?:at|with)\s+(.+?)\s*[:\-]\s*(.+)',
        caseSensitive: false,
      ),
      RegExp(r'(.+?)\s+(?:at|@)\s+(.+)', caseSensitive: false),
      RegExp(
        r'(.+?)\s+\|\s+(.+?)\s+\|\s+(LinkedIn|Indeed)',
        caseSensitive: false,
      ),
      RegExp(
        r'(.+?)\s+-\s+(.+?)\s+(?:\||-|at)\s*(LinkedIn|Indeed)?',
        caseSensitive: false,
      ),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(firstLine);
      if (match == null) continue;
      final first = _cleanValue(match.group(1) ?? '');
      final second = _cleanValue(match.group(2) ?? '');
      if (first.isEmpty || second.isEmpty) continue;
      if (pattern.pattern.contains('job')) return (second, first);
      return (first, second);
    }
    return (null, null);
  }

  static String _sourceFromUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('linkedin.')) return 'LinkedIn';
    if (lower.contains('indeed.')) return 'Indeed';
    return '';
  }

  static String _guessCompany(List<String> lines, String source) {
    if (lines.length > 1) {
      final second = _cleanValue(lines[1]);
      if (second.isNotEmpty && !second.startsWith('http')) return second;
    }
    if (source.isNotEmpty) return '$source Job';
    return 'Unknown Company';
  }

  static String _cleanValue(String value) {
    return value
        .replaceAll(RegExp(r'https?:\/\/\S+', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(
          RegExp(r'^(job|role|title|company)\s*[:\-]\s*', caseSensitive: false),
          '',
        )
        .trim();
  }
}
