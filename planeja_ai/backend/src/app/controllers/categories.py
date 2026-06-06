import re
from flask import Blueprint, request, jsonify
from src.app.controllers.auth import login_required
from src.app.models.category import Category
from src.config.database import db

categories_bp = Blueprint('categories', __name__, url_prefix='/api/categories')

_HEX_PATTERN = re.compile(r'^#[0-9A-Fa-f]{6}$')

ALLOWED_ICONS = {
    'utensils', 'car', 'palmtree', 'home', 'trending-up', 'shopping-cart',
    'bus', 'ticket', 'sandwich', 'book-open', 'help-circle', 'heart',
    'briefcase', 'music', 'gamepad-2', 'plane', 'dumbbell', 'baby',
    'shirt', 'wifi', 'zap', 'gift', 'coffee', 'dollar-sign',
    'piggy-bank', 'graduation-cap', 'stethoscope', 'paw-print', 'film',
}


@categories_bp.route('', methods=['GET'])
@login_required
def list_categories():
    cats = Category.query.filter_by(user_id=request.user_id).order_by(Category.name).all()
    return jsonify([c.to_dict() for c in cats]), 200


@categories_bp.route('', methods=['POST'])
@login_required
def create_category():
    data = request.get_json()
    name = (data or {}).get('name', '').strip()
    color_hex = (data or {}).get('colorHex', '').strip()
    icon_name = (data or {}).get('iconName', '').strip()

    if not name or not color_hex or not icon_name:
        return jsonify({'error': 'Campos obrigatórios: name, colorHex, iconName'}), 400
    if not _HEX_PATTERN.match(color_hex):
        return jsonify({'error': 'colorHex inválido. Use o formato #RRGGBB'}), 400
    if icon_name not in ALLOWED_ICONS:
        return jsonify({'error': f'iconName inválido: {icon_name}'}), 400

    exists = Category.query.filter_by(user_id=request.user_id, name=name).first()
    if exists:
        return jsonify({'error': 'Já existe uma categoria com esse nome'}), 409

    cat = Category(user_id=request.user_id, name=name, color_hex=color_hex, icon_name=icon_name)
    db.session.add(cat)
    db.session.commit()
    return jsonify(cat.to_dict()), 201


@categories_bp.route('/<string:category_id>', methods=['PUT'])
@login_required
def update_category(category_id):
    cat = Category.query.filter_by(id=category_id, user_id=request.user_id).first()
    if not cat:
        return jsonify({'error': 'Categoria não encontrada'}), 404

    data = request.get_json() or {}
    name = data.get('name', cat.name).strip()
    color_hex = data.get('colorHex', cat.color_hex).strip()
    icon_name = data.get('iconName', cat.icon_name).strip()

    if not _HEX_PATTERN.match(color_hex):
        return jsonify({'error': 'colorHex inválido. Use o formato #RRGGBB'}), 400
    if icon_name not in ALLOWED_ICONS:
        return jsonify({'error': f'iconName inválido: {icon_name}'}), 400

    duplicate = Category.query.filter(
        Category.user_id == request.user_id,
        Category.name == name,
        Category.id != category_id
    ).first()
    if duplicate:
        return jsonify({'error': 'Já existe uma categoria com esse nome'}), 409

    cat.name = name
    cat.color_hex = color_hex
    cat.icon_name = icon_name
    db.session.commit()
    return jsonify(cat.to_dict()), 200


@categories_bp.route('/<string:category_id>', methods=['DELETE'])
@login_required
def delete_category(category_id):
    cat = Category.query.filter_by(id=category_id, user_id=request.user_id).first()
    if not cat:
        return jsonify({'error': 'Categoria não encontrada'}), 404

    from sqlalchemy import text
    
    t_check = db.session.execute(
        text("SELECT id FROM transactions WHERE category_id = :cat_id LIMIT 1"),
        {"cat_id": category_id}
    ).fetchone()
    if t_check:
        return jsonify({'error': 'Não é possível excluir: existem transações vinculadas a esta categoria'}), 409

    b_check = db.session.execute(
        text("SELECT id FROM budgets WHERE category_id = :cat_id LIMIT 1"),
        {"cat_id": category_id}
    ).fetchone()
    if b_check:
        return jsonify({'error': 'Não é possível excluir: existem orçamentos vinculados a esta categoria'}), 409

    g_check = db.session.execute(
        text("SELECT id FROM goals WHERE category_id = :cat_id LIMIT 1"),
        {"cat_id": category_id}
    ).fetchone()
    if g_check:
        return jsonify({'error': 'Não é possível excluir: existem metas vinculadas a esta categoria'}), 409

    db.session.delete(cat)
    db.session.commit()
    return jsonify({'message': 'Categoria removida com sucesso'}), 200
