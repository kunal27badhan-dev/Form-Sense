from flask import Flask, jsonify
from flask_cors import CORS
from werkzeug.exceptions import HTTPException

from routes.fitness import fitness_bp
from routes.meal import meal_bp
from routes.weight import weight_bp
from routes.workout import workout_bp


def create_app() -> Flask:
    app = Flask(__name__)
    CORS(app)

    app.register_blueprint(meal_bp, url_prefix="/predict")
    app.register_blueprint(workout_bp, url_prefix="/predict")
    app.register_blueprint(weight_bp, url_prefix="/predict")
    app.register_blueprint(fitness_bp, url_prefix="/predict")

    @app.get("/health")
    def health_check():
        return jsonify({"status": "ok"}), 200

    @app.errorhandler(ValueError)
    def handle_value_error(error: ValueError):
        return jsonify({"error": str(error)}), 400

    @app.errorhandler(FileNotFoundError)
    def handle_missing_artifact(error: FileNotFoundError):
        return jsonify({"error": str(error)}), 500

    @app.errorhandler(HTTPException)
    def handle_http_exception(error: HTTPException):
        return jsonify({"error": error.description}), error.code

    @app.errorhandler(Exception)
    def handle_unexpected_error(error: Exception):
        return (
            jsonify(
                {
                    "error": "Internal server error.",
                    "detail": str(error),
                }
            ),
            500,
        )

    return app


app = create_app()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
