import os
import pytest
from src.app.utils.security import (
    hash_password,
    verify_password,
    generate_token,
    decode_token,
    get_jwt_secret
)

def test_hash_and_verify_password():
    password = "supersecretpassword"
    hashed = hash_password(password)
    
    assert hashed != password
    assert verify_password(password, hashed) is True
    assert verify_password("wrongpassword", hashed) is False

def test_token_generation_and_decoding():
    user_id = "user-12345"
    token = generate_token(user_id)
    
    assert isinstance(token, str)
    
    payload = decode_token(token)
    assert payload["sub"] == user_id

def test_expired_or_invalid_token():
    with pytest.raises(ValueError, match="Token inválido."):
        decode_token("invalid.token.string")

def test_get_jwt_secret_missing(monkeypatch):
    monkeypatch.delenv("JWT_SECRET", raising=False)
    with pytest.raises(ValueError, match="JWT_SECRET environment variable is missing!"):
        get_jwt_secret()
