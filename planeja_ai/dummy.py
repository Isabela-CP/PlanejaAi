import requests

url = "http://localhost:8000/api/auth/avatar"
headers = {"Authorization": "Bearer dummy"}
files = {"avatar": ("test.jpg", b"fake image bytes", "image/jpeg")}

response = requests.post(url, headers=headers, files=files)
print(response.status_code)
print(response.text)
