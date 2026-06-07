import os
from flask import Flask
from flask_cors import CORS
import re
from .database import db

def create_app() -> Flask:
    app = Flask(__name__)
    CORS(app, origins=re.compile(r"^http://(localhost|127\.0\.0\.1)(:\d+)?$"))
    
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        raise ValueError("DATABASE_URL environment variable is not set and is required.")
        
    app.config["SQLALCHEMY_DATABASE_URI"] = database_url
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    db.init_app(app)
    
    with app.app_context():
        from src.app.controllers.auth import auth_bp
        from src.app.controllers.categories import categories_bp
        from src.app.controllers.transactions import transactions_bp
        from src.app.controllers.budgets import budgets_bp
        from src.app.controllers.goals import goals_bp
        app.register_blueprint(auth_bp)
        app.register_blueprint(categories_bp)
        app.register_blueprint(transactions_bp)
        app.register_blueprint(budgets_bp)
        app.register_blueprint(goals_bp)
    
    @app.route("/")
    def index() -> dict:
        return {"status": "online", "service": "Planeja.AI Flask API"}
    
    return app

app = create_app()
