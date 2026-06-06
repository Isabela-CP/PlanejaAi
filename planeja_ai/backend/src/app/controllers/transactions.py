from datetime import datetime
from flask import Blueprint, request, jsonify
from src.app.controllers.auth import login_required
from src.app.models.transaction import Transaction
from src.app.models.category import Category
from src.config.database import db

transactions_bp = Blueprint('transactions', __name__, url_prefix='/api/transactions')

@transactions_bp.route('', methods=['GET'])
@login_required
def list_transactions():
    txs = Transaction.query.filter_by(user_id=request.user_id).order_by(Transaction.date.desc(), Transaction.created_at.desc()).all()
    return jsonify([t.to_dict() for t in txs]), 200

@transactions_bp.route('', methods=['POST'])
@login_required
def create_transaction():
    data = request.get_json() or {}
    tx_type = data.get('type', '').strip()
    amount = data.get('amount')
    date_str = data.get('date', '').strip()
    description = data.get('description', '').strip()
    category_id = data.get('categoryId')

    if not tx_type or amount is None or not date_str:
        return jsonify({'error': 'Campos obrigatórios: type, amount, date'}), 400

    if tx_type not in ['income', 'expense']:
        return jsonify({'error': "O tipo deve ser 'income' ou 'expense'"}), 400

    try:
        amount_val = float(amount)
        if amount_val <= 0:
            return jsonify({'error': 'O valor deve ser maior que zero'}), 400
    except (ValueError, TypeError):
        return jsonify({'error': 'Valor de amount inválido'}), 400

    try:
        clean_date = date_str.split('T')[0]
        tx_date = datetime.strptime(clean_date, '%Y-%m-%d').date()
    except Exception:
        return jsonify({'error': 'Formato de data inválido. Use AAAA-MM-DD'}), 400

    if category_id:
        category = Category.query.filter_by(id=category_id, user_id=request.user_id).first()
        if not category:
            return jsonify({'error': 'Categoria não encontrada'}), 404
        if category.type != 'transaction':
            return jsonify({'error': 'A categoria fornecida deve ser do tipo transaction'}), 400

    tx = Transaction(
        user_id=request.user_id,
        category_id=category_id,
        type=tx_type,
        value=amount_val,
        date=tx_date,
        description=description
    )

    db.session.add(tx)
    db.session.commit()

    return jsonify(tx.to_dict()), 201

@transactions_bp.route('/<string:transaction_id>', methods=['PUT'])
@login_required
def update_transaction(transaction_id):
    tx = Transaction.query.filter_by(id=transaction_id, user_id=request.user_id).first()
    if not tx:
        return jsonify({'error': 'Transação não encontrada'}), 404

    data = request.get_json() or {}
    tx_type = data.get('type', tx.type).strip()
    amount = data.get('amount')
    date_str = data.get('date')
    description = data.get('description', tx.description)
    category_id = data.get('categoryId')

    if tx_type not in ['income', 'expense']:
        return jsonify({'error': "O tipo deve ser 'income' ou 'expense'"}), 400

    if amount is not None:
        try:
            amount_val = float(amount)
            if amount_val <= 0:
                return jsonify({'error': 'O valor deve ser maior que zero'}), 400
            tx.value = amount_val
        except (ValueError, TypeError):
            return jsonify({'error': 'Valor de amount inválido'}), 400

    if date_str:
        try:
            clean_date = date_str.split('T')[0]
            tx.date = datetime.strptime(clean_date, '%Y-%m-%d').date()
        except Exception:
            return jsonify({'error': 'Formato de data inválido. Use AAAA-MM-DD'}), 400

    if 'categoryId' in data:
        if category_id:
            category = Category.query.filter_by(id=category_id, user_id=request.user_id).first()
            if not category:
                return jsonify({'error': 'Categoria não encontrada'}), 404
            if category.type != 'transaction':
                return jsonify({'error': 'A categoria fornecida deve ser do tipo transaction'}), 400
            tx.category_id = category_id
        else:
            tx.category_id = None

    tx.type = tx_type
    tx.description = description

    db.session.commit()
    return jsonify(tx.to_dict()), 200

@transactions_bp.route('/<string:transaction_id>', methods=['DELETE'])
@login_required
def delete_transaction(transaction_id):
    tx = Transaction.query.filter_by(id=transaction_id, user_id=request.user_id).first()
    if not tx:
        return jsonify({'error': 'Transação não encontrada'}), 404

    db.session.delete(tx)
    db.session.commit()
    return jsonify({'message': 'Transação removida com sucesso'}), 200
