import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorage {
  static final supabase = Supabase.instance.client;

  // رفع صورة avatar
  static Future<String> uploadAvatar(File file) async {
    final fileName =
        "avatar_${DateTime.now().millisecondsSinceEpoch}.jpg";

    await supabase.storage
        .from('avatars')
        .upload(fileName, file);

    return supabase.storage
        .from('avatars')
        .getPublicUrl(fileName);
  }

  // رفع الخلفية
  static Future<String> uploadBackground(File file) async {
    final fileName =
        "bg_${DateTime.now().millisecondsSinceEpoch}.jpg";

    await supabase.storage
        .from('backgrounds')
        .upload(fileName, file);

    return supabase.storage
        .from('backgrounds')
        .getPublicUrl(fileName);
  }
}