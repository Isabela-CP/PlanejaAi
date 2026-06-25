import datetime
import os

import bcrypt
import jwt


def get_jwt_secret() -> str:
    """Safely retrieves the JWT secret from environment variables."""
    secret = os.environ.get("JWT_SECRET")
    if not secret:
        raise ValueError("JWT_SECRET environment variable is missing!")
    return secret


def hash_password(password: str) -> str:
    """Hashes a plaintext password using bcrypt with a salt."""
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode("utf-8"), salt)
    return hashed.decode("utf-8")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifies a plaintext password against a bcrypt hashed password."""
    return bcrypt.checkpw(
        plain_password.encode("utf-8"), hashed_password.encode("utf-8")
    )


def generate_token(user_id: str) -> str:
    """Generates a JWT access token for the given user_id."""
    payload = {
        "sub": user_id,
        "iat": datetime.datetime.now(datetime.timezone.utc),
        "exp": datetime.datetime.now(datetime.timezone.utc)
        + datetime.timedelta(hours=24),
    }
    return jwt.encode(payload, get_jwt_secret(), algorithm="HS256")


def decode_token(token: str) -> dict:
    """Decodes a JWT token and returns its payload, handling errors."""
    try:
        payload = jwt.decode(token, get_jwt_secret(), algorithms=["HS256"])
        return payload
    except jwt.ExpiredSignatureError:
        raise ValueError("Token expirado.")
    except jwt.InvalidTokenError:
        raise ValueError("Token inválido.")
