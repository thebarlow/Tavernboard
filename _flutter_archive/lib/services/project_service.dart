import '../models/project.dart';
import 'supabase_client.dart';

class ProjectService {
  Future<List<Project>> fetchProjects() async {
    final data = await supabase
        .from('projects')
        .select()
        .order('created_at', ascending: true) as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(Project.fromJson)
        .toList();
  }

  Future<Project> createProject(Map<String, dynamic> fields) async {
    final data = await supabase
        .from('projects')
        .insert({...fields, 'user_id': supabase.auth.currentUser!.id})
        .select()
        .single();
    return Project.fromJson(data);
  }

  Future<Project> updateProject(String id, Map<String, dynamic> fields) async {
    final data = await supabase
        .from('projects')
        .update(fields)
        .eq('id', id)
        .select()
        .single();
    return Project.fromJson(data);
  }

  Future<void> deleteProject(String id) async {
    await supabase.from('projects').delete().eq('id', id);
  }
}
