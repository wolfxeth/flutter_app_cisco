import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/contact.dart';
import '../models/note.dart';
import '../models/alert_item.dart';
import '../utils/location_helper.dart';

class ApiService {
  ApiService._private();
  static final ApiService instance = ApiService._private();

  Map<String, dynamic>? _cache;

  Future<Map<String, dynamic>> _loadJson() async {
    if (_cache != null) return _cache!;
    final s = await rootBundle.loadString('assets/dummy/data.json');
    _cache = json.decode(s) as Map<String, dynamic>;
    return _cache!;
  }

  Future<String> getPersona() async {
    final m = await _loadJson();
    return m['persona']?.toString() ?? 'Network Engineer';
  }

  Future<List<Contact>> getContacts() async {
    final m = await _loadJson();
    final list = (m['contacts'] as List<dynamic>?) ?? [];
    final userLoc = m['userLocation'];
    final userLat = userLoc != null ? (userLoc['lat'] as num).toDouble() : null;
    final userLon = userLoc != null ? (userLoc['lon'] as num).toDouble() : null;
    final contacts = list.map((e) => Contact.fromJson(e as Map<String,dynamic>)).toList();
    if (userLat != null && userLon != null) {
      for (var c in contacts) {
        if (c.lat != null && c.lon != null) {
          c.distanceMeters = LocationHelper.distanceMeters(userLat, userLon, c.lat!, c.lon!).round();
        }
      }
    }
    return contacts;
  }

  Future<List<Note>> getNotes() async {
    final m = await _loadJson();
    final list = (m['notes'] as List<dynamic>?) ?? [];
    return list.map((e) => Note.fromJson(e as Map<String,dynamic>)).toList();
  }

  Future<Note> createNote(String title, String body) async {
    // create an in-memory note with a timestamp
    final id = 'n_local_${DateTime.now().millisecondsSinceEpoch}';
    final note = Note(id: id, title: title, body: body, timestamp: DateTime.now().toIso8601String(), local: true);
    final m = await _loadJson();
    final list = (m['notes'] as List<dynamic>?) ?? [];
    list.insert(0, {'id': note.id, 'title': note.title, 'body': note.body, 'timestamp': note.timestamp, 'local': true});
    _cache!['notes'] = list;
    return note;
  }

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

  Future<bool> deleteNote(String id) async {
    final m = await _loadJson();
    final list = (m['notes'] as List<dynamic>?) ?? [];
    final before = list.length;
    list.removeWhere((item) => (item['id']?.toString() ?? '') == id);
    _cache!['notes'] = list;
    return list.length < before;
  }

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

  Future<bool> scheduleMeeting(String contactId) async {
    // stub for scheduling — in a real app this would call calendar/meeting API
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Future<List<dynamic>> getGoals() async {
    final m = await _loadJson();
    final list = (m['goals'] as List<dynamic>?) ?? [];
    return list;
  }

  Future<bool> toggleGoalDone(String id) async {
    final m = await _loadJson();
    final list = (m['goals'] as List<dynamic>?) ?? [];
    for (var g in list) {
      if ((g['id']?.toString() ?? '') == id) {
        g['done'] = !(g['done'] == true);
        _cache!['goals'] = list;
        return g['done'] == true;
      }
    }
    return false;
  }

  Future<bool> deleteGoal(String id) async {
    final m = await _loadJson();
    final list = (m['goals'] as List<dynamic>?) ?? [];
    final before = list.length;
    list.removeWhere((g) => (g['id']?.toString() ?? '') == id);
    _cache!['goals'] = list;
    return list.length < before;
  }

  Future<List<AlertItem>> getAlerts() async {
    final m = await _loadJson();
    final list = (m['alerts'] as List<dynamic>?) ?? [];
    return list.map((e) => AlertItem.fromJson(e as Map<String,dynamic>)).toList();
  }

  Future<String> generateInsights() async {
    // return a simple generated string based on notes and persona
    final persona = await getPersona();
    final notes = await getNotes();
    final summary = 'Persona: $persona\nNotes count: ${notes.length}\nKey takeaways: Review saved notes and follow up with saved contacts.';
    await Future.delayed(const Duration(milliseconds: 300));
    return summary;
  }

  Future<List<Map<String, dynamic>>> search(String q) async {
    final m = await _loadJson();
    final results = <Map<String, dynamic>>[];
    final notes = (m['notes'] as List<dynamic>?) ?? [];
    for (var n in notes) {
      final map = n as Map<String,dynamic>;
      if ((map['title'] ?? '').toString().toLowerCase().contains(q.toLowerCase()) || (map['body'] ?? '').toString().toLowerCase().contains(q.toLowerCase())) {
        results.add({'type':'note','data':map});
      }
    }
    final contacts = (m['contacts'] as List<dynamic>?) ?? [];
    for (var c in contacts) {
      final map = c as Map<String,dynamic>;
      if ((map['name'] ?? '').toString().toLowerCase().contains(q.toLowerCase())) {
        results.add({'type':'contact','data':map});
      }
    }
    return results;
  }
}
