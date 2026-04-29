import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const supabaseRedirectUrl = String.fromEnvironment('SUPABASE_REDIRECT_URL');

SupabaseClient get supabase => Supabase.instance.client;
