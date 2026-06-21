import 'package:http/http.dart' as http;
void main() async {
  try {
    var response = await http.post(Uri.parse('http://localhost:8000/api/auth/login'), body: '{"email":"test","password":"test"}');
    print(response.statusCode);
  } catch(e) {
    print(e);
  }
}
