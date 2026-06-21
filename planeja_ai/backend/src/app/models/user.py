import uuid
from src.config.database import db

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(255), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    age = db.Column(db.Integer, nullable=True)
    
    notifications_push = db.Column(db.Boolean, default=True)
    notifications_email = db.Column(db.Boolean, default=True)
    notifications_sms = db.Column(db.Boolean, default=False)
    share_anonymous_data = db.Column(db.Boolean, default=False)
    theme_dark = db.Column(db.Boolean, default=False)
