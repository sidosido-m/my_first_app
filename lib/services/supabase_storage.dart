import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorage {
  static final supabase = Supabase.instance.client;

  // ================= AVATAR =================
  static Future<String?> uploadAvatar(File file) async {
    try {
      final fileName =
          "avatar_${DateTime.now().millisecondsSinceEpoch}.jpg";

      await supabase.storage
    .from('avatars')
    .upload(
      fileName,
      file,
      fileOptions: const FileOptions(upsert: true),
    );

      return supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);
    } catch (e) {
      print("Avatar upload error ❌: $e");
      return null;
    }
  }

  // ================= BACKGROUND =================
  static Future<String?> uploadBackground(File file) async {
    try {
      final fileName =
          "bg_${DateTime.now().millisecondsSinceEpoch}.jpg";

      await supabase.storage
          .from('backgrounds')
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      return supabase.storage
          .from('backgrounds')
          .getPublicUrl(fileName);
    } catch (e) {
      print("Background upload error ❌: $e");
      return null;
    }
  }

// ================= PRODUCT =================
static Future<String?> uploadProduct(File file) async {
  try {
    final fileName =
        "product_${DateTime.now().millisecondsSinceEpoch}.jpg";

    await supabase.storage
        .from('products')
        .upload(
          fileName,
          file,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ),
        );

    return supabase.storage
        .from('products')
        .getPublicUrl(fileName);
        
  } catch (e) {
    print("Product upload error ❌: $e");
    return null;
  }
}
}