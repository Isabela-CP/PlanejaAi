from datetime import datetime
from flask import Blueprint, request, jsonify
from src.app.controllers.auth import login_required
from src.app.models.transaction import Transaction
from src.app.models.category import Category
from src.config.database import db

transactions_bp = Blueprint('transactions', __name__, url_prefix='/api/transactions')

def parse_and_validate_amount(amount):
    """Valida e converte o valor da transação. Retorna (valor, erro)."""
    if amount is None:
        return None, None
    try:
        amount_val = float(amount)
        if amount_val <= 0:
            return None, 'O valor deve ser maior que zero'
        return amount_val, None
    except (ValueError, TypeError):
        return None, 'Valor de amount inválido'

def parse_and_validate_date(date_str):
    """Valida e converte a string de data. Retorna (data, erro)."""
    if not date_str:
        return None, None
    try:
        clean_date = date_str.split('T')[0]
        tx_date = datetime.strptime(clean_date, '%Y-%m-%d').date()
        return tx_date, None
    except Exception:
        return None, 'Formato de data inválido. Use AAAA-MM-DD'

def validate_category(category_id, user_id):
    """Valida se a categoria existe e pertence ao usuário e tipo correto. Retorna (categoria, erro)."""
    if not category_id:
        return None, None
    category = Category.query.filter_by(id=category_id, user_id=user_id).first()
    if not category:
        return None, 'Categoria não encontrada'
    if category.type != 'transaction':
        return None, 'A categoria fornecida deve ser do tipo transaction'
    return category, None

@transactions_bp.route('', methods=['GET'])
@login_required
def list_transactions():
    txs = Transaction.query.filter_by(user_id=request.user_id).order_by(Transaction.date.desc(), Transaction.created_at.desc()).all()
    return jsonify([t.to_dict() for t in txs]), 200

@transactions_bp.route('', methods=['POST'])
@login_required
def create_transaction():
    data = request.get_json() or {}
    title = data.get('title', '').strip()
    tx_type = data.get('type', '').strip()
    amount = data.get('amount')
    date_str = data.get('date', '').strip()
    description = data.get('description', '').strip()
    category_id = data.get('categoryId')

    if not title:
        return jsonify({'error': 'Campo obrigatório: title'}), 400

    if not tx_type or amount is None or not date_str:
        return jsonify({'error': 'Campos obrigatórios: type, amount, date'}), 400

    if tx_type not in ['income', 'expense']:
        return jsonify({'error': "O tipo deve ser 'income' ou 'expense'"}), 400

    amount_val, err = parse_and_validate_amount(amount)
    if err:
        return jsonify({'error': err}), 400

    tx_date, err = parse_and_validate_date(date_str)
    if err:
        return jsonify({'error': err}), 400

    if category_id:
        _, err = validate_category(category_id, request.user_id)
        if err:
            status_code = 404 if 'não encontrada' in err else 400
            return jsonify({'error': err}), status_code

    tx = Transaction(
        user_id=request.user_id,
        category_id=category_id,
        title=title,
        type=tx_type,
        value=amount_val,
        date=tx_date,
        description=description
    )

    db.session.add(tx)
    db.session.commit()

    return jsonify(tx.to_dict()), 201

def update_category_field(data, tx, user_id):
    """Valida e aplica a atualização do campo de categoria se fornecido."""
    if 'categoryId' not in data:
        return None, None
    category_id = data.get('categoryId')
    if not category_id:
        tx.category_id = None
        return None, None
    _, err = validate_category(category_id, user_id)
    if err:
        status_code = 404 if 'não encontrada' in err else 400
        return err, status_code
    tx.category_id = category_id
    return None, None

def validate_and_apply_update(data, tx, user_id):
    """Valida as entradas de atualização de uma transação e aplica-as se corretas."""
    title = data.get('title')
    tx_type = data.get('type', tx.type).strip()
    amount = data.get('amount')
    date_str = data.get('date')

    if title is not None:
        title = title.strip()
        if not title:
            return 'O campo title não pode ser vazio', 400
        tx.title = title

    if tx_type not in ['income', 'expense']:
        return "O tipo deve ser 'income' ou 'expense'", 400

    amount_val, err = parse_and_validate_amount(amount)
    if err:
        return err, 400
    if amount_val is not None:
        tx.value = amount_val

    tx_date, err = parse_and_validate_date(date_str)
    if err:
        return err, 400
    if tx_date is not None:
        tx.date = tx_date

    err, status_code = update_category_field(data, tx, user_id)
    if err:
        return err, status_code

    tx.type = tx_type
    tx.description = data.get('description', tx.description)
    return None, None

@transactions_bp.route('/<string:transaction_id>', methods=['PUT'])
@login_required
def update_transaction(transaction_id):
    tx = Transaction.query.filter_by(id=transaction_id, user_id=request.user_id).first()
    if not tx:
        return jsonify({'error': 'Transação não encontrada'}), 404

    data = request.get_json() or {}
    err, status_code = validate_and_apply_update(data, tx, request.user_id)
    if err:
        return jsonify({'error': err}), status_code

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
