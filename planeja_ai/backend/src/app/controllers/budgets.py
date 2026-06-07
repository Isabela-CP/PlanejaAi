from datetime import datetime, date
import calendar
from flask import Blueprint, request, jsonify
from sqlalchemy import func
from src.app.controllers.auth import login_required
from src.app.models.budget import Budget
from src.app.models.category import Category
from src.app.models.transaction import Transaction
from src.config.database import db

budgets_bp = Blueprint('budgets', __name__, url_prefix='/api/budgets')

def get_budget_period_dates(month_year, reset_day):
    """Retorna a data de início e fim do ciclo do orçamento."""
    start_date = date(month_year.year, month_year.month, reset_day)
    
    if month_year.month == 12:
        next_month = 1
        next_year = month_year.year + 1
    else:
        next_month = month_year.month + 1
        next_year = month_year.year
        
    import calendar
    _, days_in_next = calendar.monthrange(next_year, next_month)
    
    if reset_day > 1:
        end_day = min(reset_day - 1, days_in_next)
        end_date = date(next_year, next_month, end_day)
    else:
        _, days_in_current = calendar.monthrange(month_year.year, month_year.month)
        end_date = date(month_year.year, month_year.month, days_in_current)
        
    return start_date, end_date

def calculate_budget_spent(user_id, category_id, month_year, reset_day):
    """Calcula a soma das transações de despesa no período do orçamento."""
    start_date, end_date = get_budget_period_dates(month_year, reset_day)
    
    spent = db.session.query(func.coalesce(func.sum(Transaction.value), 0)).filter(
        Transaction.user_id == user_id,
        Transaction.category_id == category_id,
        Transaction.type == 'expense',
        Transaction.date >= start_date,
        Transaction.date <= end_date
    ).scalar()
    
    return float(spent)

@budgets_bp.route('', methods=['GET'])
@login_required
def list_budgets():
    date_str = request.args.get('date')
    if date_str:
        try:
            clean_date = date_str.split('T')[0]
            # Extrai o primeiro dia do mês correspondente
            temp_date = datetime.strptime(clean_date, '%Y-%m-%d').date()
            month_year = date(temp_date.year, temp_date.month, 1)
        except Exception:
            try:
                # Caso venha apenas AAAA-MM
                temp_date = datetime.strptime(date_str, '%Y-%m').date()
                month_year = date(temp_date.year, temp_date.month, 1)
            except Exception:
                return jsonify({'error': 'Formato de data inválido. Use AAAA-MM-DD ou AAAA-MM'}), 400
    else:
        today = date.today()
        month_year = date(today.year, today.month, 1)

    budgets = Budget.query.filter_by(user_id=request.user_id, month_year=month_year).all()
    
    result = []
    for b in budgets:
        b_dict = b.to_dict()
        b_dict['spent'] = calculate_budget_spent(request.user_id, b.category_id, b.month_year, b.reset_day)
        result.append(b_dict)
        
    return jsonify(result), 200

def parse_and_validate_limit(limit_value):
    if limit_value is None:
        return None, 'Campos obrigatórios: categoryId, monthlyLimit'
    try:
        limit_val = float(limit_value)
        if limit_val < 0:
            return None, 'O limite deve ser maior ou igual a zero'
        return limit_val, None
    except (ValueError, TypeError):
        return None, 'Valor de monthlyLimit inválido'

def parse_and_validate_reset_day(reset_day):
    try:
        reset_day_val = int(reset_day)
        if reset_day_val < 1 or reset_day_val > 31:
            return None, 'O resetDay deve ser entre 1 e 31'
        return reset_day_val, None
    except (ValueError, TypeError):
        return None, 'Valor de resetDay inválido'

def parse_and_validate_date(date_str):
    if not date_str:
        today = date.today()
        return date(today.year, today.month, 1), None
    try:
        clean_date = date_str.split('T')[0]
        temp_date = datetime.strptime(clean_date, '%Y-%m-%d').date()
        return date(temp_date.year, temp_date.month, 1), None
    except Exception:
        return None, 'Formato de data inválido. Use AAAA-MM-DD'

@budgets_bp.route('', methods=['POST'])
@login_required
def create_budget():
    data = request.get_json() or {}
    category_id = data.get('categoryId')
    limit_value = data.get('monthlyLimit') or data.get('limitValue')
    date_str = data.get('date')
    reset_day = data.get('resetDay', 1)

    if not category_id:
        return jsonify({'error': 'Campos obrigatórios: categoryId, monthlyLimit'}), 400

    limit_val, err = parse_and_validate_limit(limit_value)
    if err:
        return jsonify({'error': err}), 400

    reset_day_val, err = parse_and_validate_reset_day(reset_day)
    if err:
        return jsonify({'error': err}), 400

    month_year, err = parse_and_validate_date(date_str)
    if err:
        return jsonify({'error': err}), 400

    # Validar se a categoria existe
    category = Category.query.filter_by(id=category_id, user_id=request.user_id).first()
    if not category:
        return jsonify({'error': 'Categoria não encontrada'}), 404
    if category.type != 'transaction':
        return jsonify({'error': 'A categoria fornecida deve ser do tipo transaction'}), 400

    # Validar se já existe orçamento para essa categoria no mês correspondente
    existing = Budget.query.filter_by(user_id=request.user_id, category_id=category_id, month_year=month_year).first()
    if existing:
        return jsonify({'error': 'Já existe um orçamento definido para esta categoria no mês correspondente'}), 400

    new_budget = Budget(
        user_id=request.user_id,
        category_id=category_id,
        limit_value=limit_val,
        month_year=month_year,
        reset_day=reset_day_val
    )

    db.session.add(new_budget)
    db.session.commit()

    b_dict = new_budget.to_dict()
    b_dict['spent'] = calculate_budget_spent(request.user_id, category_id, month_year, reset_day_val)

    return jsonify(b_dict), 201

@budgets_bp.route('/<string:budget_id>', methods=['PUT'])
@login_required
def update_budget(budget_id):
    budget = Budget.query.filter_by(id=budget_id, user_id=request.user_id).first()
    if not budget:
        return jsonify({'error': 'Orçamento não encontrado'}), 404

    data = request.get_json() or {}
    limit_value = data.get('monthlyLimit') or data.get('limitValue')
    reset_day = data.get('resetDay')

    if limit_value is not None:
        try:
            limit_val = float(limit_value)
            if limit_val < 0:
                return jsonify({'error': 'O limite deve ser maior ou igual a zero'}), 400
            budget.limit_value = limit_val
        except (ValueError, TypeError):
            return jsonify({'error': 'Valor de monthlyLimit inválido'}), 400

    if reset_day is not None:
        try:
            reset_val = int(reset_day)
            if reset_val < 1 or reset_val > 31:
                return jsonify({'error': 'O resetDay deve ser entre 1 e 31'}), 400
            budget.reset_day = reset_val
        except (ValueError, TypeError):
            return jsonify({'error': 'Valor de resetDay inválido'}), 400

    db.session.commit()

    b_dict = budget.to_dict()
    b_dict['spent'] = calculate_budget_spent(request.user_id, budget.category_id, budget.month_year, budget.reset_day)

    return jsonify(b_dict), 200

@budgets_bp.route('/<string:budget_id>', methods=['DELETE'])
@login_required
def delete_budget(budget_id):
    budget = Budget.query.filter_by(id=budget_id, user_id=request.user_id).first()
    if not budget:
        return jsonify({'error': 'Orçamento não encontrado'}), 404

    db.session.delete(budget)
    db.session.commit()

    return jsonify({'message': 'Orçamento removido com sucesso'}), 200
