def test_home_route(client):
    response = client.get("/")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "online"
    assert "Planeja.AI Flask API" in data["service"]


def test_create_app_missing_database_url(monkeypatch):
    import pytest
    from src.config.app import create_app

    monkeypatch.delenv("DATABASE_URL", raising=False)

    with pytest.raises(ValueError) as excinfo:
        create_app()

    assert "DATABASE_URL environment variable is not set" in str(excinfo.value)
