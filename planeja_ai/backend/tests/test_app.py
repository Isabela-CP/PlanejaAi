def test_home_route(client):
    response = client.get("/")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "online"
    assert "Planeja.AI Flask API" in data["service"]
