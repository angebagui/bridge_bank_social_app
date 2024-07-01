import 'dart:io';


abstract class UploadImageService {
  Future<String> uploadImage(File file);
}