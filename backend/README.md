# FastAPI Auth Backend

## Setup

1. Create a virtual environment (optional but recommended):
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Run the server:
   ```bash
   uvicorn main:app --reload
   ```

## Endpoints
- `POST /signup` — Register a new user (JSON: username, email, password)
- `POST /login` — Login with email and password (form data)

## Environment Variables
Copy `.env.example` to `.env` and set your secret key, algorithm, and token expiry if needed.

## Notes
- Uses SQLite (`users.db`) for storage.
- Passwords are hashed with bcrypt.
- Returns JWT tokens on signup and login.
