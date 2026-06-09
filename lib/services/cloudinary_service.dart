import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = "dnrceotbg";

  static const String uploadPreset = "lost_found_app";

  Future<String?> uploadImage(Uint8List imageBytes) async {
    try {
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request = http.MultipartRequest("POST", uri);

      request.fields["upload_preset"] = uploadPreset;

      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          imageBytes,
          filename: "report.jpg",
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();

        final json = jsonDecode(body);

        return json["secure_url"];
      }

      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
