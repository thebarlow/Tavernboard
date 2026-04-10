import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../services/project_service.dart';

final projectServiceProvider = Provider<ProjectService>(
  (ref) => ProjectService(),
);

final projectsProvider = FutureProvider<List<Project>>((ref) async {
  return ref.watch(projectServiceProvider).fetchProjects();
});
