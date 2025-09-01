from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import OAuth2PasswordRequestForm
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from passlib.context import CryptContext
from jose import JWTError, jwt
from typing import Optional
from datetime import datetime, timedelta
from pymongo import MongoClient
import os

SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

# MongoDB connection
MONGO_URL = "mongodb://localhost:27017"
DATABASE_NAME = "e-commerce-app"
COLLECTION_NAME = "users"

# Initialize MongoDB client
try:
    client = MongoClient(MONGO_URL)
    db = client[DATABASE_NAME]
    users_collection = db[COLLECTION_NAME]
    # Test connection
    client.admin.command('ping')
    print("MongoDB connection successful!")
except Exception as e:
    print(f"MongoDB connection failed: {e}")
    client = None
    db = None
    users_collection = None

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:64246"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password):
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

class UserCreate(BaseModel):
    username: str
    email: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str

@app.get("/")
def read_root():
    return {"message": "FastAPI Backend with MongoDB is running!"}

@app.get("/health")
def health_check():
    if client and client.admin.command('ping'):
        return {"status": "healthy", "database": "MongoDB connected"}
    return {"status": "unhealthy", "database": "MongoDB disconnected"}

@app.post("/signup", response_model=Token)
def signup(user: UserCreate):
    if not users_collection:
        raise HTTPException(status_code=500, detail="Database connection failed")
    
    # Check if user already exists
    existing_user = users_collection.find_one({"email": user.email})
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # Create new user document
    user_doc = {
        "username": user.username,
        "email": user.email,
        "hashed_password": get_password_hash(user.password),
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow()
    }
    
    # Insert user into MongoDB
    result = users_collection.insert_one(user_doc)
    
    if result.inserted_id:
        access_token = create_access_token(data={"sub": user.email})
        return {"access_token": access_token, "token_type": "bearer"}
    else:
        raise HTTPException(status_code=500, detail="Failed to create user")

@app.post("/login", response_model=Token)
def login(form_data: OAuth2PasswordRequestForm = Depends()):
    if not users_collection:
        raise HTTPException(status_code=500, detail="Database connection failed")
    
    # Find user by email
    user = users_collection.find_one({"email": form_data.username})
    
    if not user or not verify_password(form_data.password, user["hashed_password"]):
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    
    access_token = create_access_token(data={"sub": user["email"]})
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users")
def get_users():
    if not users_collection:
        raise HTTPException(status_code=500, detail="Database connection failed")
    
    users = list(users_collection.find({}, {"hashed_password": 0}))  # Exclude passwords
    return {"users": users, "count": len(users)}

if __name__ == "__main__":
    import uvicorn
    print("Starting FastAPI server with MongoDB...")
    uvicorn.run(app, host="127.0.0.1", port=8000)
