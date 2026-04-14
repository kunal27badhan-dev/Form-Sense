from pathlib import Path
from threading import Lock
from typing import Any

import joblib

_ARTIFACTS_DIR = Path(__file__).resolve().parents[1] / "model_artifacts"
_CACHE: dict[str, Any] = {}
_LOCK = Lock()


def load_artifact(filename: str) -> Any:
    artifact_path = _ARTIFACTS_DIR / filename
    if not artifact_path.exists():
        raise FileNotFoundError(
            f"Model artifact '{filename}' is missing. Run backend/training/train_models.py first."
        )

    with _LOCK:
        if filename not in _CACHE:
            _CACHE[filename] = joblib.load(artifact_path)
        return _CACHE[filename]


def load_encoders() -> dict[str, dict[str, int]]:
    encoders = load_artifact("encoders.pkl")
    if not isinstance(encoders, dict):
        raise ValueError("encoders.pkl has invalid format.")
    return encoders


def load_metadata() -> dict[str, Any]:
    metadata = load_artifact("metadata.pkl")
    if not isinstance(metadata, dict):
        raise ValueError("metadata.pkl has invalid format.")
    return metadata
