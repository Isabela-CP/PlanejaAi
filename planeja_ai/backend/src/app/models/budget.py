import uuid
from src.config.database import db

class Budget(db.Model):
    __tablename__ = 'budgets'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    category_id = db.Column(db.String(36), db.ForeignKey('categories.id', ondelete='CASCADE'), nullable=False)
    limit_value = db.Column(db.Numeric(15, 2), nullable=False)
    month_year = db.Column(db.Date, nullable=False)
    reset_day = db.Column(db.Integer, nullable=False, default=1)

    category = db.relationship('Category', backref='budgets', lazy=True)

    def to_dict(self):
        return {
            'id': self.id,
            'userId': self.user_id,
            'categoryId': self.category_id,
            'monthlyLimit': float(self.limit_value) if self.limit_value is not None else 0.0,
            'monthYear': self.month_year.isoformat() if self.month_year else None,
            'resetDay': self.reset_day,
            'category': self.category.to_dict() if self.category else None,
        }
