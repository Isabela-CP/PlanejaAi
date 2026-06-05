from flask import Blueprint, request, jsonify
from functools import wraps
from src.app.models.user import User
from src.app.utils.security import hash_password, verify_password, generate_token, decode_token
from src.config.database import db

auth_bp = Blueprint('auth', __name__, url_prefix='/api/auth')

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({"error": "Token ausente ou inválido"}), 401
        
        token = auth_header.split(" ")[1]
        try:
            payload = decode_token(token)
            request.user_id = payload['sub']
        except ValueError as e:
            return jsonify({"error": str(e)}), 401
            
        return f(*args, **kwargs)
    return decorated_function

# Etapa 4: Registro e Login
@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    if not data or not data.get('email') or not data.get('password') or not data.get('name'):
        return jsonify({"error": "Dados incompletos"}), 400
        
    if User.query.filter_by(email=data['email']).first():
        return jsonify({"error": "E-mail já cadastrado"}), 409
        
    hashed_pw = hash_password(data['password'])
    new_user = User(
        name=data['name'],
        email=data['email'],
        password_hash=hashed_pw
    )
    
    db.session.add(new_user)
    db.session.commit()
    
    return jsonify({"message": "Usuário criado com sucesso!"}), 201

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({"error": "Dados incompletos"}), 400
        
    user = User.query.filter_by(email=data['email']).first()
    if not user or not verify_password(data['password'], user.password_hash):
        return jsonify({"error": "Credenciais inválidas"}), 401
        
    token = generate_token(user.id)
    return jsonify({
        "token": token, 
        "user": {"id": user.id, "name": user.name, "email": user.email}
    }), 200

# Etapa 5: Rotas Autenticadas e Logout
@auth_bp.route('/me', methods=['GET'])
@login_required
def me():
    user = db.session.get(User, request.user_id)
    if not user:
        return jsonify({"error": "Usuário não encontrado"}), 404
        
    return jsonify({
        "id": user.id,
        "name": user.name,
        "email": user.email,
        "age": user.age,
        "theme_dark": user.theme_dark
    }), 200

@auth_bp.route('/logout', methods=['POST'])
@login_required
def logout():
    return jsonify({"message": "Logout realizado com sucesso!"}), 200
