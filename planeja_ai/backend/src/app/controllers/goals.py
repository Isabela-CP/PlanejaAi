from datetime import date, datetime

from flask import Blueprint, jsonify, request

from src.app.controllers.auth import login_required
from src.app.models.category import Category
from src.app.models.goal import Goal
from src.config.database import db

goals_bp = Blueprint("goals", __name__, url_prefix="/api/goals")

CATEGORY_NOT_FOUND_MSG = "Categoria não encontrada"


def parse_and_validate_target(value):
    if value is None:
        return None, "Campos obrigatórios: name, targetValue, deadline"
    try:
        val = float(value)
        if val <= 0:
            return None, "O valor alvo deve ser maior que zero"
        return val, None
    except (ValueError, TypeError):
        return None, "Valor alvo inválido"


def parse_and_validate_current(value):
    try:
        val = float(value)
        if val < 0:
            return None, "O valor atual deve ser maior ou igual a zero"
        return val, None
    except (ValueError, TypeError):
        return None, "Valor atual inválido"


def parse_and_validate_date(date_str):
    if not date_str:
        return None, "O prazo (deadline) é obrigatório"
    try:
        clean_date = date_str.split("T")[0]
        temp_date = datetime.strptime(clean_date, "%Y-%m-%d").date()
        return temp_date, None
    except Exception:
        return None, "Formato de prazo inválido. Use AAAA-MM-DD"


def check_and_update_goal_statuses(goals):
    today = date.today()
    updated = False
    for g in goals:
        if g.current_value >= g.target_value:
            new_status = "completed"
        elif today > g.deadline:
            new_status = "delayed"
        else:
            new_status = "in_progress"

        if g.status != new_status:
            g.status = new_status
            updated = True
    if updated:
        db.session.commit()


@goals_bp.route("", methods=["GET"])
@login_required
def list_goals():
    goals = Goal.query.filter_by(user_id=request.user_id).all()
    check_and_update_goal_statuses(goals)
    return jsonify([g.to_dict() for g in goals]), 200


@goals_bp.route("", methods=["POST"])
@login_required
def create_goal():
    data = request.get_json() or {}
    name = data.get("name")
    target_value = data.get("targetValue")
    deadline_str = data.get("deadline")
    category_id = data.get("categoryId")
    custom_category = data.get("customCategory")

    if not name or name.strip() == "":
        return jsonify({"error": "Nome da meta é obrigatório"}), 400

    target_val, err = parse_and_validate_target(target_value)
    if err:
        return jsonify({"error": err}), 400

    deadline_val, err = parse_and_validate_date(deadline_str)
    if err:
        return jsonify({"error": err}), 400

    # Validar se a categoria existe
    if category_id:
        category = Category.query.filter_by(
            id=category_id, user_id=request.user_id
        ).first()
        if not category:
            return jsonify({"error": CATEGORY_NOT_FOUND_MSG}), 404
        if category.type != "goal":
            return (
                jsonify({"error": "A categoria fornecida deve ser do tipo goal"}),
                400,
            )
        custom_category = None

    new_goal = Goal(
        user_id=request.user_id,
        category_id=category_id,
        custom_category=custom_category,
        name=name.strip(),
        target_value=target_val,
        current_value=0.0,
        deadline=deadline_val,
        status="in_progress",
    )

    db.session.add(new_goal)
    db.session.commit()

    return jsonify(new_goal.to_dict()), 201


def _update_goal_fields(goal, data):
    name = data.get("name")
    if name is not None:
        if not name.strip():
            return "Nome da meta não pode ser vazio"
        goal.name = name.strip()

    target_value = data.get("targetValue")
    if target_value is not None:
        target_val, err = parse_and_validate_target(target_value)
        if err:
            return err
        goal.target_value = target_val

    current_value = data.get("currentValue")
    if current_value is not None:
        current_val, err = parse_and_validate_current(current_value)
        if err:
            return err
        goal.current_value = current_val

    deadline_str = data.get("deadline")
    if deadline_str is not None:
        deadline_val, err = parse_and_validate_date(deadline_str)
        if err:
            return err
        goal.deadline = deadline_val
    return None


def _update_goal_categories(goal, data, user_id):
    category_id = data.get("categoryId")
    if category_id is not None:
        if category_id == "":
            goal.category_id = None
        else:
            category = Category.query.filter_by(id=category_id, user_id=user_id).first()
            if not category:
                return CATEGORY_NOT_FOUND_MSG
            if category.type != "goal":
                return "A categoria fornecida deve ser do tipo goal"
            goal.category_id = category_id
            goal.custom_category = None

    if "customCategory" in data:
        cust = data.get("customCategory")
        goal.custom_category = cust
        if cust:
            goal.category_id = None
    return None


@goals_bp.route("/<string:goal_id>", methods=["PUT"])
@login_required
def update_goal(goal_id):
    goal = Goal.query.filter_by(id=goal_id, user_id=request.user_id).first()
    if not goal:
        return jsonify({"error": "Meta não encontrada"}), 404

    data = request.get_json() or {}

    err = _update_goal_fields(goal, data)
    if err:
        return jsonify({"error": err}), 400

    err = _update_goal_categories(goal, data, request.user_id)
    if err:
        status_code = 404 if err == CATEGORY_NOT_FOUND_MSG else 400
        return jsonify({"error": err}), status_code

    # Atualizar o status antes de salvar e retornar
    check_and_update_goal_statuses([goal])
    db.session.commit()

    return jsonify(goal.to_dict()), 200


@goals_bp.route("/<string:goal_id>", methods=["DELETE"])
@login_required
def delete_goal(goal_id):
    goal = Goal.query.filter_by(id=goal_id, user_id=request.user_id).first()
    if not goal:
        return jsonify({"error": "Meta não encontrada"}), 404

    db.session.delete(goal)
    db.session.commit()

    return jsonify({"message": "Meta removida com sucesso"}), 200
