import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolinked/utils/app_exports.dart';

class StorageService {
  StorageService._internal();
  static final StorageService instance = StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage and returns the download URL.
  Future<String?> uploadFile({
    required File file,
    required String path,
  }) async {
    try {
      final Reference ref = _storage.ref().child(path);
      final UploadTask task = ref.putFile(file);
      final TaskSnapshot snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  /// Deletes a file from Firebase Storage.
  Future<void> deleteFile(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  /// Uploads an image specifically for an Ask or Broadcast.
  /// Paths are structured as posts/{folder}/{userId}/{fileName} for security.
  Future<String?> uploadPostImage(File file, String folder) async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    return await uploadFile(
      file: file,
      path: 'posts/$folder/$userId/$fileName',
    );
  }
}
