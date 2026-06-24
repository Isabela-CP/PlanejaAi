from datetime import datetime, date
from flask import Blueprint, request, jsonify
from sqlalchemy import func
from src.app.controllers.auth import login_required
from src.app.models.transaction import Transaction
from src.app.models.category import Category
from src.config.database import db

relatorios_bp = Blueprint('relatorios', __name__, url_prefix='/api/relatorios')

def parse_date(date_str, default_val):
    if not date_str:
        return default_val
    try:
        clean_date = date_str.split('T')[0]
        return datetime.strptime(clean_date, '%Y-%m-%d').date()
    except Exception:
        raise ValueError('Formato de data inválido. Use AAAA-MM-DD')

def get_date_range():
    start_str = request.args.get('start_date') or request.args.get('startDate')
    end_str = request.args.get('end_date') or request.args.get('endDate')
    
    today = date.today()
    try:
        # start_date padrão: primeiro dia do mês atual
        default_start = date(today.year, today.month, 1)
        start_date = parse_date(start_str, default_start)
        
        # end_date padrão: hoje
        end_date = parse_date(end_str, today)
        
        return start_date, end_date, None
    except ValueError as e:
        return None, None, str(e)

def get_months_in_range(start_date, end_date):
    months = []
    current_year = start_date.year
    current_month = start_date.month
    
    while (current_year < end_date.year) or (current_year == end_date.year and current_month <= end_date.month):
        months.append(f"{current_year:04d}-{current_month:02d}")
        current_month += 1
        if current_month > 12:
            current_month = 1
            current_year += 1
    return months

@relatorios_bp.route('/resumo', methods=['GET'])
@login_required
def resumo():
    start_date, end_date, err = get_date_range()
    if err:
        return jsonify({'error': err}), 400
        
    # Total de receitas
    receita = db.session.query(func.coalesce(func.sum(Transaction.value), 0))\
        .filter(Transaction.user_id == request.user_id,
                Transaction.type == 'income',
                Transaction.date >= start_date,
                Transaction.date <= end_date).scalar()
                
    # Total de despesas
    despesa = db.session.query(func.coalesce(func.sum(Transaction.value), 0))\
        .filter(Transaction.user_id == request.user_id,
                Transaction.type == 'expense',
                Transaction.date >= start_date,
                Transaction.date <= end_date).scalar()
                
    # Contagem de transações
    quantidade_transacoes = db.session.query(func.count(Transaction.id))\
        .filter(Transaction.user_id == request.user_id,
                Transaction.date >= start_date,
                Transaction.date <= end_date).scalar()
                
    # Total guardado em metas
    from src.app.models.goal import Goal
    total_metas = db.session.query(func.coalesce(func.sum(Goal.current_value), 0))\
        .filter(Goal.user_id == request.user_id).scalar()
                
    receita_val = float(receita)
    despesa_val = float(despesa)
    economia_val = float(total_metas)
    liquido_val = receita_val - despesa_val - economia_val
    
    return jsonify({
        'receita': receita_val,
        'despesa': despesa_val,
        'economia': economia_val,
        'liquido': liquido_val,
        'quantidade_transacoes': quantidade_transacoes,
        # Compatibilidade com camelCase/inglês
        'totalIncome': receita_val,
        'totalExpenses': despesa_val,
        'totalSavings': economia_val,
        'netIncome': liquido_val,
        'transactionCount': quantidade_transacoes
    }), 200

@relatorios_bp.route('/por-categoria', methods=['GET'])
@login_required
def por_categoria():
    start_date, end_date, err = get_date_range()
    if err:
        return jsonify({'error': err}), 400
        
    results = db.session.query(
        Transaction.category_id,
        Category.name,
        Category.color_hex,
        Category.icon_name,
        func.coalesce(func.sum(Transaction.value), 0).label('amount')
    ).outerjoin(
        Category, Transaction.category_id == Category.id
    ).filter(
        Transaction.user_id == request.user_id,
        Transaction.type == 'expense',
        Transaction.date >= start_date,
        Transaction.date <= end_date
    ).group_by(
        Transaction.category_id, Category.name, Category.color_hex, Category.icon_name
    ).all()
    
    total_despesas = sum(float(r.amount) for r in results)
    
    breakdown = []
    for r in results:
        amount_val = float(r.amount)
        percentage = round((amount_val / total_despesas) * 100, 2) if total_despesas > 0 else 0.0
        
        breakdown.append({
            'categoryId': r.category_id,
            'category': r.name if r.name else 'Sem Categoria',
            'colorHex': r.color_hex if r.color_hex else '#9E9E9E',
            'iconName': r.icon_name if r.icon_name else 'help-circle',
            'amount': amount_val,
            'percentage': percentage
        })
        
    breakdown.sort(key=lambda x: x['amount'], reverse=True)
    
    return jsonify(breakdown), 200

@relatorios_bp.route('/evolucao-saldo', methods=['GET'])
@login_required
def evolucao_saldo():
    start_str = request.args.get('start_date') or request.args.get('startDate')
    end_str = request.args.get('end_date') or request.args.get('endDate')
    
    today = date.today()
    try:
        if not start_str:
            start_month = today.month - 5
            start_year = today.year
            if start_month <= 0:
                start_month += 12
                start_year -= 1
            start_date = date(start_year, start_month, 1)
        else:
            start_date = parse_date(start_str, None)
            
        end_date = parse_date(end_str, today)
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
        
    results = db.session.query(
        func.extract('year', Transaction.date).label('year'),
        func.extract('month', Transaction.date).label('month'),
        Transaction.type,
        func.coalesce(func.sum(Transaction.value), 0).label('total')
    ).filter(
        Transaction.user_id == request.user_id,
        Transaction.date >= start_date,
        Transaction.date <= end_date
    ).group_by(
        func.extract('year', Transaction.date),
        func.extract('month', Transaction.date),
        Transaction.type
    ).all()
    
    monthly_data = {}
    for r in results:
        y = int(r.year)
        m = int(r.month)
        key = f"{y:04d}-{m:02d}"
        if key not in monthly_data:
            monthly_data[key] = {'receitas': 0.0, 'despesas': 0.0}
            
        val = float(r.total)
        if r.type == 'income':
            monthly_data[key]['receitas'] += val
        elif r.type == 'expense':
            monthly_data[key]['despesas'] += val
            
    all_months = get_months_in_range(start_date, end_date)
    
    evolucao = []
    acumulado = 0.0
    
    for key in all_months:
        receitas = monthly_data.get(key, {}).get('receitas', 0.0)
        despesas = monthly_data.get(key, {}).get('despesas', 0.0)
        saldo = receitas - despesas
        acumulado += saldo
        
        evolucao.append({
            'mes': key,
            'receitas': receitas,
            'despesas': despesas,
            'saldo': saldo,
            'acumulado': acumulado,
            # Compatibilidade com camelCase/inglês
            'month': key,
            'income': receitas,
            'expense': despesas,
            'net': saldo,
            'cumulative': acumulado
        })
        
    return jsonify(evolucao), 200
