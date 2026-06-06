import uuid
from src.config.database import db


class Category(db.Model):
    __tablename__ = 'categories'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    name = db.Column(db.String(100), nullable=False)
    color_hex = db.Column(db.String(7), nullable=False)
    icon_name = db.Column(db.String(50), nullable=False)
    type = db.Column(db.String(20), nullable=False, default='transaction')

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'colorHex': self.color_hex,
            'iconName': self.icon_name,
            'type': self.type,
        }
