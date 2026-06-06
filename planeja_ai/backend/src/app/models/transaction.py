import uuid
from src.config.database import db

class Transaction(db.Model):
    __tablename__ = 'transactions'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    category_id = db.Column(db.String(36), db.ForeignKey('categories.id', ondelete='SET NULL'), nullable=True)
    type = db.Column(db.String(10), nullable=False)  # 'income' ou 'expense'
    value = db.Column(db.Numeric(15, 2), nullable=False)
    date = db.Column(db.Date, nullable=False)
    description = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime(timezone=True), default=db.func.now())

    # Relacionamento para puxar dados da categoria vinculada
    category = db.relationship('Category', backref='transactions', lazy=True)

    def to_dict(self):
        return {
            'id': self.id,
            'userId': self.user_id,
            'categoryId': self.category_id,
            'type': self.type,
            'amount': float(self.value) if self.value is not None else 0.0,
            'date': self.date.isoformat() if self.date else None,
            'description': self.description or '',
            'category': self.category.to_dict() if self.category else None,
            'createdAt': self.created_at.isoformat() if self.created_at else None,
        }
