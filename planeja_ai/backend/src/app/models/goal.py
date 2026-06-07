import uuid
from src.config.database import db

class Goal(db.Model):
    __tablename__ = 'goals'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    category_id = db.Column(db.String(36), db.ForeignKey('categories.id', ondelete='SET NULL'), nullable=True)
    custom_category = db.Column(db.String(255), nullable=True)
    name = db.Column(db.String(255), nullable=False)
    target_value = db.Column(db.Numeric(15, 2), nullable=False)
    current_value = db.Column(db.Numeric(15, 2), nullable=False, default=0.0)
    deadline = db.Column(db.Date, nullable=False)
    status = db.Column(db.String(20), nullable=False, default='in_progress')

    category = db.relationship('Category', backref='goals', lazy=True)

    def to_dict(self):
        return {
            'id': self.id,
            'userId': self.user_id,
            'categoryId': self.category_id,
            'customCategory': self.custom_category,
            'name': self.name,
            'targetValue': float(self.target_value) if self.target_value is not None else 0.0,
            'currentValue': float(self.current_value) if self.current_value is not None else 0.0,
            'deadline': self.deadline.isoformat() if self.deadline else None,
            'status': self.status,
            'category': self.category.to_dict() if self.category else None,
        }
