import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entry.dart';
import '../services/entry_service.dart';

final entryServiceProvider = Provider<EntryService>(
  (ref) => EntryService(),
);

final entriesProvider = FutureProvider<List<Entry>>((ref) async {
  return ref.watch(entryServiceProvider).fetchEntries();
});

final projectEntriesProvider = FutureProvider.family<List<Entry>, String>(
  (ref, projectId) async {
    return ref.watch(entryServiceProvider).fetchEntries(projectId: projectId);
  },
);

final dateRangeEntriesProvider =
    FutureProvider.family<List<Entry>, ({DateTime start, DateTime end})>(
  (ref, range) async {
    return ref
        .watch(entryServiceProvider)
        .fetchEntriesForDateRange(range.start, range.end);
  },
);
