import 'dart:io';
import 'dart:convert';
import 'package:bridgebank_social_app/rest/upload/upload_image_service.dart';
import 'package:http/http.dart';

class ImgurService extends UploadImageService {

  final String apiUrl = "https://api.imgur.com";
  final String clientId = "c67cbf8edfce2c2";

  @override
  Future<String> uploadImage(File file) async {

    final Uri uri = Uri.parse("$apiUrl/3/image");
    final MultipartRequest request = MultipartRequest("POST", uri);

    request.files.add(MultipartFile.fromBytes("image", file.readAsBytesSync(), filename: file.path));
    request.headers.addAll({
      "authorization" : "Client-ID $clientId",
    });
    request.fields.addAll(
        {
          "type" : "file",
          "title" : "Simple upload",
          "description" : "This is a simple image upload in Imgur"
        }
    );

    final StreamedResponse streamedResponse = await request.send();
    final Response response = await Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);

      if (json.containsKey("data") && json["data"] != null && json["data"].containsKey("link")) {
        return json["data"]["link"];
      }
    }
    throw Exception(response.body);

  }

}