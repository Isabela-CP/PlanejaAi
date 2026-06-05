import os
from flask import Flask
from .database import db

def create_app() -> Flask:
    app = Flask(__name__)
    
    # SonarQube / Security: Never hardcode sensitive credentials. 
    # Always fetch from environment securely.
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        raise ValueError("DATABASE_URL environment variable is not set and is required.")
        
    app.config["SQLALCHEMY_DATABASE_URI"] = database_url
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    
    # Initialize the database extension
    db.init_app(app)
    
    # Registra as rotas
    with app.app_context():
        from src.app.controllers.auth import auth_bp
        app.register_blueprint(auth_bp)
    
    @app.route("/")
    def index() -> dict:
        return {"status": "online", "service": "Planeja.AI Flask API"}
    
    return app

# The instance used by 'flask run'
app = create_app()
