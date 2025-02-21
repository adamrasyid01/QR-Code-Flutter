import 'package:http/http.dart' as http;

Future<bool> isMp4File(String url) {
  return http.head(Uri.parse(url)).then((response) {
    final contentType = response.headers['content-type'];
    return contentType != null && contentType.contains('video/mp4');
  }).catchError((e) {
    print('Error checking file type: $e');
    return false;
  });
}

Future<bool> isMp3File(String url) {
  return http.head(Uri.parse(url)).then((response) {
    final contentType = response.headers['content-type'];
    return contentType != null && contentType.contains('audio/mpeg');
  }).catchError((e) {
    print('Error checking file type: $e');
    return false;
  });
}
