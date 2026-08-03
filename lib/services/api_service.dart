import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/alert_item.dart';
import '../models/channel.dart';
import '../models/contact.dart';
import '../models/note.dart';
import '../models/session.dart';
import '../utils/location_helper.dart';

/// Thrown by [_HttpApiService] on non-2xx responses.
class ApiException implements Exception {
  ApiException(this.statusCode, this.message, [this.body]);
  final int statusCode;
  final String message;
  final String? body;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Public API surface consumed by every screen. Screens should only ever
/// reference [ApiService.instance] — the concrete implementation (dummy vs
/// HTTP) is chosen by [AppConfig.useDummyData].
abstract class ApiService {
  static final ApiService instance =
      AppConfig.useDummyData ? _DummyApiService() : _HttpApiService();

  // Persona / goals
  Future<String> getPersona();
  Future<List<Map<String, dynamic>>> getPersonas();
  Future<List<Map<String, dynamic>>> getGoals(String personaId);
  Future<bool> toggleGoalDone(String personaId, String id);
  Future<bool> deleteGoal(String personaId, String id);
  Future<Map<String, dynamic>> createGoal(
    String personaId, {
    required String title,
    required String description,
    required String category,
    required String priority,
    required List<String> technologies,
  });

  // Contacts
  Future<List<Contact>> getContacts();
  Future<List<Map<String, dynamic>>> getSavedContacts();
  Future<bool> toggleSaveContact(String id);
  Future<bool> scheduleMeeting(String contactId);

  // Sessions & rooms
  Future<List<Session>> getSessions({
    bool sortByDistance = false,
    bool sortByMatch = false,
  });
  Future<List<String>> getRooms();
  Future<bool> toggleScheduleSession(String id);

  // Webex channels
  Future<List<String>> getWebexTopics();
  Future<List<Channel>> getChannels({String? topic});
  Future<bool> toggleJoinChannel(String id);

  // Notes
  Future<List<Note>> getNotes();
  Future<Note> createNote(
    String title,
    String body, {
    String? linkedSessionId,
    List<String> participants = const [],
  });
  Future<bool> updateNote(String id, String title, String body);
  Future<bool> deleteNote(String id);

  // Misc
  Future<List<AlertItem>> getAlerts();
  Future<String> generateInsights();
  Future<List<Map<String, dynamic>>> search(String q);
}

// ---------------------------------------------------------------------------
// Dummy implementation — reads assets/dummy/data.json. Kept identical in
// behaviour to the previous inline service so nothing on-screen changes.
// ---------------------------------------------------------------------------

class _DummyApiService implements ApiService {
  Map<String, dynamic>? _cache;

  Future<Map<String, dynamic>> _loadJson() async {
    if (_cache != null) return _cache!;
    final s = await rootBundle.loadString('assets/dummy/data.json');
    _cache = json.decode(s) as Map<String, dynamic>;
    return _cache!;
  }

  @override
  Future<String> getPersona() async {
    final m = await _loadJson();
    return m['persona']?.toString() ?? 'Network Engineer';
  }

  @override
  Future<List<Contact>> getContacts() async {
    final m = await _loadJson();
    final list = (m['contacts'] as List<dynamic>?) ?? [];
    final userLoc = m['userLocation'];
    final userLat = userLoc != null ? (userLoc['lat'] as num).toDouble() : null;
    final userLon = userLoc != null ? (userLoc['lon'] as num).toDouble() : null;
    final contacts =
        list.map((e) => Contact.fromJson(e as Map<String, dynamic>)).toList();
    if (userLat != null && userLon != null) {
      for (var c in contacts) {
        if (c.distanceMeters == null && c.lat != null && c.lon != null) {
          c.distanceMeters =
              LocationHelper.distanceMeters(userLat, userLon, c.lat!, c.lon!)
                  .round();
        }
      }
    }
    return contacts;
  }

  @override
  Future<List<Note>> getNotes() async {
    final m = await _loadJson();
    final list = (m['notes'] as List<dynamic>?) ?? [];
    return list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Note> createNote(
    String title,
    String body, {
    String? linkedSessionId,
    List<String> participants = const [],
  }) async {
    final id = 'n_local_${DateTime.now().millisecondsSinceEpoch}';
    final ts = DateTime.now().toIso8601String();
    final note = Note(
      id: id,
      title: title,
      body: body,
      timestamp: ts,
      linkedSessionId: linkedSessionId,
      participants: participants,
      local: true,
    );
    final m = await _loadJson();
    final list = (m['notes'] as List<dynamic>?) ?? [];
    list.insert(0, {
      'id': note.id,
      'title': note.title,
      'body': note.body,
      'timestamp': note.timestamp,
      'linkedSessionId': linkedSessionId,
      'participants': participants,
      'local': true,
    });
    _cache!['notes'] = list;
    return note;
  }

  @override
  Future<List<Map<String, dynamic>>> getSavedContacts() async {
    final m = await _loadJson();
    final list = (m['savedContacts'] as List<dynamic>?) ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Future<bool> updateNote(String id, String title, String body) async {
    final m = await _loadJson();
    final list = (m['notes'] as List<dynamic>?) ?? [];
    for (var item in list) {
      if ((item['id']?.toString() ?? '') == id) {
        item['title'] = title;
        item['body'] = body;
        return true;
      }
    }
    return false;
  }

  @override
  Future<bool> deleteNote(String id) async {
    final m = await _loadJson();
    final list = (m['notes'] as List<dynamic>?) ?? [];
    final before = list.length;
    list.removeWhere((item) => (item['id']?.toString() ?? '') == id);
    _cache!['notes'] = list;
    return list.length < before;
  }

  @override
  Future<bool> toggleSaveContact(String id) async {
    final m = await _loadJson();
    final list = (m['contacts'] as List<dynamic>?) ?? [];
    for (var item in list) {
      if ((item['id']?.toString() ?? '') == id) {
        item['saved'] = !(item['saved'] == true);
        _cache!['contacts'] = list;
        return item['saved'] == true;
      }
    }
    return false;
  }

  @override
  Future<bool> scheduleMeeting(String contactId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> getPersonas() async {
    final m = await _loadJson();
    final list = (m['personas'] as List<dynamic>?) ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  List<dynamic> _goalsListFor(String personaId) {
    final map = (_cache!['goalsByPersona'] as Map<String, dynamic>?) ?? {};
    return (map[personaId] as List<dynamic>?) ?? [];
  }

  @override
  Future<List<Map<String, dynamic>>> getGoals(String personaId) async {
    await _loadJson();
    return _goalsListFor(personaId)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  @override
  Future<bool> toggleGoalDone(String personaId, String id) async {
    await _loadJson();
    for (var g in _goalsListFor(personaId)) {
      if ((g['id']?.toString() ?? '') == id) {
        g['done'] = !(g['done'] == true);
        return g['done'] == true;
      }
    }
    return false;
  }

  @override
  Future<bool> deleteGoal(String personaId, String id) async {
    await _loadJson();
    final list = _goalsListFor(personaId);
    final before = list.length;
    list.removeWhere((g) => (g['id']?.toString() ?? '') == id);
    return list.length < before;
  }

  @override
  Future<Map<String, dynamic>> createGoal(
    String personaId, {
    required String title,
    required String description,
    required String category,
    required String priority,
    required List<String> technologies,
  }) async {
    await _loadJson();
    final list = _goalsListFor(personaId);
    final goal = <String, dynamic>{
      'id': 'g_local_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'technologies': technologies,
      'done': false,
      'local': true,
    };
    list.add(goal);
    final map = Map<String, dynamic>.from(
        (_cache!['goalsByPersona'] as Map<String, dynamic>?) ?? {});
    map[personaId] = list;
    _cache!['goalsByPersona'] = map;
    return goal;
  }

  @override
  Future<List<AlertItem>> getAlerts() async {
    final m = await _loadJson();
    final list = (m['alerts'] as List<dynamic>?) ?? [];
    return list
        .map((e) => AlertItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Session>> getSessions({
    bool sortByDistance = false,
    bool sortByMatch = false,
  }) async {
    final m = await _loadJson();
    final list = (m['sessions'] as List<dynamic>?) ?? [];
    final sessions =
        list.map((e) => Session.fromJson(e as Map<String, dynamic>)).toList();
    if (sortByMatch) {
      sessions.sort(
          (a, b) => (b.matchPercent ?? 0).compareTo(a.matchPercent ?? 0));
    } else if (sortByDistance) {
      sessions.sort((a, b) =>
          (a.distanceMeters ?? 999999).compareTo(b.distanceMeters ?? 999999));
    }
    return sessions;
  }

  @override
  Future<List<String>> getRooms() async {
    final m = await _loadJson();
    final list = (m['rooms'] as List<dynamic>?) ?? [];
    return list.map((e) => e.toString()).toList();
  }

  @override
  Future<List<String>> getWebexTopics() async {
    final m = await _loadJson();
    final list =
        (m['webexTopics'] as List<dynamic>?) ?? const ['All topics'];
    return list.map((e) => e.toString()).toList();
  }

  @override
  Future<List<Channel>> getChannels({String? topic}) async {
    final m = await _loadJson();
    final list = (m['channels'] as List<dynamic>?) ?? [];
    var channels = list
        .map((e) => Channel.fromJson(e as Map<String, dynamic>))
        .toList();
    if (topic != null && topic.isNotEmpty && topic != 'All topics') {
      channels = channels.where((c) => c.topic == topic).toList();
    }
    channels
        .sort((a, b) => (b.matchPercent ?? 0).compareTo(a.matchPercent ?? 0));
    return channels;
  }

  @override
  Future<bool> toggleJoinChannel(String id) async {
    final m = await _loadJson();
    final list = (m['channels'] as List<dynamic>?) ?? [];
    for (var c in list) {
      if ((c['id']?.toString() ?? '') == id) {
        c['joined'] = !(c['joined'] == true);
        return c['joined'] == true;
      }
    }
    return false;
  }

  @override
  Future<bool> toggleScheduleSession(String id) async {
    final m = await _loadJson();
    final list = (m['sessions'] as List<dynamic>?) ?? [];
    for (var s in list) {
      if ((s['id']?.toString() ?? '') == id) {
        s['scheduled'] = !(s['scheduled'] == true);
        return s['scheduled'] == true;
      }
    }
    return false;
  }

  @override
  Future<String> generateInsights() async {
    final persona = await getPersona();
    final notes = await getNotes();
    final summary =
        'Persona: $persona\nNotes count: ${notes.length}\nKey takeaways: Review saved notes and follow up with saved contacts.';
    await Future.delayed(const Duration(milliseconds: 300));
    return summary;
  }

  @override
  Future<List<Map<String, dynamic>>> search(String q) async {
    final m = await _loadJson();
    final results = <Map<String, dynamic>>[];
    final needle = q.toLowerCase();
    final notes = (m['notes'] as List<dynamic>?) ?? [];
    for (var n in notes) {
      final map = n as Map<String, dynamic>;
      if ((map['title'] ?? '').toString().toLowerCase().contains(needle) ||
          (map['body'] ?? '').toString().toLowerCase().contains(needle)) {
        results.add({'type': 'note', 'data': map});
      }
    }
    final contacts = (m['contacts'] as List<dynamic>?) ?? [];
    for (var c in contacts) {
      final map = c as Map<String, dynamic>;
      if ((map['name'] ?? '').toString().toLowerCase().contains(needle)) {
        results.add({'type': 'contact', 'data': map});
      }
    }
    return results;
  }
}

// ---------------------------------------------------------------------------
// HTTP implementation — talks to the Spring Boot backend. Every method mirrors
// the dummy version so screens can switch by flipping AppConfig.useDummyData.
// ---------------------------------------------------------------------------

class _HttpApiService implements ApiService {
  final http.Client _client = http.Client();

  Uri _u(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse(AppConfig.apiBaseUrl);
    return base.replace(
      path: (base.path + path).replaceAll('//', '/'),
      queryParameters: query == null
          ? null
          : query.map((k, v) => MapEntry(k, v?.toString() ?? '')),
    );
  }

  Map<String, String> get _headers {
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final t = AppConfig.authToken;
    if (t != null && t.isNotEmpty) h['Authorization'] = 'Bearer $t';
    return h;
  }

  Future<dynamic> _get(String path, [Map<String, dynamic>? q]) =>
      _send(() => _client.get(_u(path, q), headers: _headers));

  Future<dynamic> _post(String path, [Object? body]) => _send(() =>
      _client.post(_u(path), headers: _headers, body: jsonEncode(body ?? {})));

  Future<dynamic> _put(String path, [Object? body]) => _send(() =>
      _client.put(_u(path), headers: _headers, body: jsonEncode(body ?? {})));

  Future<dynamic> _patch(String path, [Object? body]) => _send(() => _client
      .patch(_u(path), headers: _headers, body: jsonEncode(body ?? {})));

  Future<dynamic> _delete(String path) =>
      _send(() => _client.delete(_u(path), headers: _headers));

  Future<dynamic> _send(Future<http.Response> Function() req) async {
    final http.Response res;
    try {
      res = await req().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw ApiException(0, 'Request timed out');
    } catch (e) {
      throw ApiException(0, 'Network error: $e');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      debugPrint('API ${res.statusCode} ${res.request?.url}: ${res.body}');
      throw ApiException(
          res.statusCode, res.reasonPhrase ?? 'HTTP error', res.body);
    }
    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }

  List<Map<String, dynamic>> _asMapList(dynamic v) {
    if (v is! List) return const [];
    return v.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // -- Persona / goals ------------------------------------------------------

  @override
  Future<String> getPersona() async {
    final r = await _get('/api/persona');
    return (r is Map ? r['name']?.toString() : r?.toString()) ??
        'Network Engineer';
  }

  @override
  Future<List<Map<String, dynamic>>> getPersonas() async =>
      _asMapList(await _get('/api/personas'));

  @override
  Future<List<Map<String, dynamic>>> getGoals(String personaId) async =>
      _asMapList(await _get('/api/personas/$personaId/goals'));

  @override
  Future<bool> toggleGoalDone(String personaId, String id) async {
    final r = await _patch('/api/personas/$personaId/goals/$id/toggle');
    return r is Map ? r['done'] == true : true;
  }

  @override
  Future<bool> deleteGoal(String personaId, String id) async {
    await _delete('/api/personas/$personaId/goals/$id');
    return true;
  }

  @override
  Future<Map<String, dynamic>> createGoal(
    String personaId, {
    required String title,
    required String description,
    required String category,
    required String priority,
    required List<String> technologies,
  }) async {
    final r = await _post('/api/personas/$personaId/goals', {
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'technologies': technologies,
    });
    return Map<String, dynamic>.from(r as Map);
  }

  // -- Contacts -------------------------------------------------------------

  @override
  Future<List<Contact>> getContacts() async {
    final list = _asMapList(await _get('/api/contacts'));
    return list.map(Contact.fromJson).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getSavedContacts() async =>
      _asMapList(await _get('/api/contacts/saved'));

  @override
  Future<bool> toggleSaveContact(String id) async {
    final r = await _patch('/api/contacts/$id/save');
    return r is Map ? r['saved'] == true : true;
  }

  @override
  Future<bool> scheduleMeeting(String contactId) async {
    await _post('/api/contacts/$contactId/schedule');
    return true;
  }

  // -- Sessions & rooms -----------------------------------------------------

  @override
  Future<List<Session>> getSessions({
    bool sortByDistance = false,
    bool sortByMatch = false,
  }) async {
    final sort = sortByMatch
        ? 'match'
        : sortByDistance
            ? 'distance'
            : null;
    final list = _asMapList(
        await _get('/api/sessions', sort == null ? null : {'sort': sort}));
    return list.map(Session.fromJson).toList();
  }

  @override
  Future<List<String>> getRooms() async {
    final v = await _get('/api/rooms');
    return (v as List).map((e) => e.toString()).toList();
  }

  @override
  Future<bool> toggleScheduleSession(String id) async {
    final r = await _patch('/api/sessions/$id/schedule');
    return r is Map ? r['scheduled'] == true : true;
  }

  // -- Webex channels -------------------------------------------------------

  @override
  Future<List<String>> getWebexTopics() async {
    final v = await _get('/api/channels/topics');
    return (v as List).map((e) => e.toString()).toList();
  }

  @override
  Future<List<Channel>> getChannels({String? topic}) async {
    final list = _asMapList(await _get(
        '/api/channels',
        topic == null || topic.isEmpty || topic == 'All topics'
            ? null
            : {'topic': topic}));
    return list.map(Channel.fromJson).toList();
  }

  @override
  Future<bool> toggleJoinChannel(String id) async {
    final r = await _patch('/api/channels/$id/join');
    return r is Map ? r['joined'] == true : true;
  }

  // -- Notes ----------------------------------------------------------------

  @override
  Future<List<Note>> getNotes() async {
    final list = _asMapList(await _get('/api/notes'));
    return list.map(Note.fromJson).toList();
  }

  @override
  Future<Note> createNote(
    String title,
    String body, {
    String? linkedSessionId,
    List<String> participants = const [],
  }) async {
    final r = await _post('/api/notes', {
      'title': title,
      'body': body,
      'linkedSessionId': linkedSessionId,
      'participants': participants,
    });
    return Note.fromJson(Map<String, dynamic>.from(r as Map));
  }

  @override
  Future<bool> updateNote(String id, String title, String body) async {
    await _put('/api/notes/$id', {'title': title, 'body': body});
    return true;
  }

  @override
  Future<bool> deleteNote(String id) async {
    await _delete('/api/notes/$id');
    return true;
  }

  // -- Misc -----------------------------------------------------------------

  @override
  Future<List<AlertItem>> getAlerts() async {
    final list = _asMapList(await _get('/api/alerts'));
    return list.map(AlertItem.fromJson).toList();
  }

  @override
  Future<String> generateInsights() async {
    final r = await _post('/api/insights/generate');
    if (r is Map && r['report'] != null) return r['report'].toString();
    return r?.toString() ?? '';
  }

  @override
  Future<List<Map<String, dynamic>>> search(String q) async =>
      _asMapList(await _get('/api/search', {'q': q}));
}
