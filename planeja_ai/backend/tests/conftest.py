import os
import pytest

os.environ["DATABASE_URL"] = "sqlite:///:memory:"
os.environ["JWT_SECRET"] = "test-jwt-secret-key-for-unit-testing"


@pytest.fixture
def app():
    from src.config.app import create_app
    from src.config.database import db

    app = create_app()
    app.config.update(
        {
            "TESTING": True,
        }
    )

    with app.app_context():
        db.create_all()
        yield app
        db.session.remove()
        db.drop_all()


@pytest.fixture
def client(app):
    return app.test_client()


@pytest.fixture
def runner(app):
    return app.test_cli_runner()
