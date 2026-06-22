import 'package:http/http.dart' as http;

void main() async {
  var request = http.MultipartRequest('POST', Uri.parse('http://localhost:8000/api/auth/avatar'));
  request.headers['Authorization'] = 'Bearer dummy';
  request.files.add(http.MultipartFile.fromBytes('avatar', [1,2,3], filename: 'test.jpg'));
  
  try {
    var response = await request.send();
    print('Response status: ${response.statusCode}');
  } catch (e) {
    print('Error: $e');
  }
}
