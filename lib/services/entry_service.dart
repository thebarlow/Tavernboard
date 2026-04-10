import '../models/entry.dart';
import '../models/recurrence_exception.dart';
import 'supabase_client.dart';

class EntryService {
  Future<List<Entry>> fetchEntries({String? projectId}) async {
    dynamic query = supabase.from('entries').select();

    if (projectId != null) {
      query = (query as dynamic).eq('project_id', projectId);
    }

    final data = await (query as dynamic).order('date', ascending: true) as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(Entry.fromJson)
        .toList();
  }

  Future<List<Entry>> fetchEntriesForDateRange(DateTime start, DateTime end) async {
    final data = await supabase
        .from('entries')
        .select()
        .gte('date', start.toIso8601String().split('T').first)
        .lte('date', end.toIso8601String().split('T').first)
        .order('date', ascending: true) as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(Entry.fromJson)
        .toList();
  }

  Future<Entry> createEntry(Map<String, dynamic> fields) async {
    final data = await supabase
        .from('entries')
        .insert({...fields, 'user_id': supabase.auth.currentUser!.id})
        .select()
        .single();
    return Entry.fromJson(data);
  }

  Future<Entry> updateEntry(String id, Map<String, dynamic> fields) async {
    final data = await supabase
        .from('entries')
        .update(fields)
        .eq('id', id)
        .select()
        .single();
    return Entry.fromJson(data);
  }

  Future<void> deleteEntry(String id) async {
    await supabase.from('entries').delete().eq('id', id);
  }

  Future<List<RecurrenceException>> fetchExceptions(String entryId) async {
    final data = await supabase
        .from('recurrence_exceptions')
        .select()
        .eq('entry_id', entryId) as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(RecurrenceException.fromJson)
        .toList();
  }

  Future<RecurrenceException> createException(Map<String, dynamic> fields) async {
    final data = await supabase
        .from('recurrence_exceptions')
        .insert(fields)
        .select()
        .single();
    return RecurrenceException.fromJson(data);
  }
}
