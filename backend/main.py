from fastapi import FastAPI, HTTPException, Depends, Body
from fastapi.security import OAuth2PasswordRequestForm
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from passlib.context import CryptContext
from jose import JWTError, jwt
from typing import Optional, List, Dict
from datetime import datetime, timedelta
from pymongo import MongoClient
import os

SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60


MONGO_URL = "mongodb://localhost:27017"
DATABASE_NAME = "e-commerce-app"
COLLECTION_NAME = "users"


try:
    client = MongoClient(MONGO_URL)
    db = client[DATABASE_NAME]
    users_collection = db[COLLECTION_NAME]
   
    client.admin.command('ping')
    print("MongoDB connection successful!")
except Exception as e:
    print(f"MongoDB connection failed: {e}")
    client = None
    db = None
    users_collection = None

app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:56493", "http://localhost:8000", "http://127.0.0.1:8000", "http://10.0.2.2:8000", "http://localhost:49887", "http://127.0.0.1:49887"],
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


class Product(BaseModel):
    name: str
    description: Optional[str] = None
    price: float
    category: Optional[str] = None
    in_stock: int
    image_url: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    category: Optional[str] = None
    in_stock: Optional[int] = None
    image_url: Optional[str] = None
    updated_at: Optional[datetime] = None

PRODUCTS_COLLECTION_NAME = "products"
products_collection = db[PRODUCTS_COLLECTION_NAME] if db is not None else None


def insert_sample_products():
    if products_collection is None:
        return
    if products_collection.count_documents({}) == 0:
        sample_products = [
            {
                "name": "Wireless Mouse",
                "description": "A smooth and responsive wireless mouse.",
                "price": 19.99,
                "category": "Electronics",
                "in_stock": 50,
                "image_url": "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=400&q=80",
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow()
            },
            {
                "name": "Bluetooth Headphones",
                "description": "Noise-cancelling over-ear headphones.",
                "price": 59.99,
                "category": "Electronics",
                "in_stock": 30,
                "image_url": "https://images.unsplash.com/photo-1511367461989-f85a21fda167?auto=format&fit=crop&w=400&q=80",
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow()
            },
            {
                "name": "Coffee Mug",
                "description": "Ceramic mug for hot beverages.",
                "price": 7.99,
                "category": "Kitchen",
                "in_stock": 100,
                "image_url": "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80",
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow()
            },
            {
                "name": "Yoga Mat",
                "description": "Non-slip yoga mat for all types of exercise.",
                "price": 25.99,
                "category": "Sports",
                "in_stock": 40,
                "image_url": "https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=400&q=80",
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow()
            },
            {
                "name": "Classic Novel",
                "description": "A timeless piece of literature.",
                "price": 12.49,
                "category": "Books",
                "in_stock": 60,
                "image_url": "https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=400&q=80",
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow()
            },
            {
                "name": "T-shirt",
                "description": "100% cotton unisex t-shirt.",
                "price": 9.99,
                "category": "Clothing",
                "in_stock": 80,
                "image_url": "https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=400&q=80",
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow()
            },
            {
                "name": "Building Blocks Set",
                "description": "Creative toy blocks for kids.",
                "price": 29.99,
                "category": "Toys",
                "in_stock": 35,
                "image_url": "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80",
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow()
            },
            {
                "name": "Face Moisturizer",
                "description": "Hydrating daily face cream.",
                "price": 15.99,
                "category": "Beauty",
                "in_stock": 70,
                "image_url": "https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=400&q=80",
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow()
            },
        ]
        products_collection.insert_many(sample_products)

insert_sample_products()


# --- User-specific Cart and Wishlist (MongoDB) ---
CART_COLLECTION = "cart"
WISHLIST_COLLECTION = "wishlist"
cart_collection = db[CART_COLLECTION] if db is not None else None
wishlist_collection = db[WISHLIST_COLLECTION] if db is not None else None

class CartItem(BaseModel):
    product_id: str
    quantity: int

class Cart(BaseModel):
    user_email: str
    items: list[CartItem] = []

class Wishlist(BaseModel):
    user_email: str
    product_ids: list[str] = []

# --- Discount Strategy OOP ---
class DiscountStrategy:
    def apply(self, total: float) -> float:
        return total

class TenPercentOff(DiscountStrategy):
    def apply(self, total: float) -> float:
        return total * 0.9

class FlatDiscount(DiscountStrategy):
    def __init__(self, amount: float):
        self.amount = amount
    def apply(self, total: float) -> float:
        return max(0, total - self.amount)

# --- Cart Endpoints ---
@app.get("/cart", response_model=dict)
def get_cart(user_email: str):
    if cart_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    cart = cart_collection.find_one({"user_email": user_email})
    items = cart["items"] if cart else []
    return {"items": items}

@app.post("/cart/add", response_model=dict)
def add_to_cart(user_email: str = Body(...), product_id: str = Body(...), quantity: int = Body(1)):
    if cart_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    cart = cart_collection.find_one({"user_email": user_email})
    items = cart["items"] if cart else []
    found = False
    for item in items:
        if item["product_id"] == product_id:
            item["quantity"] += quantity
            found = True
            break
    if not found:
        items.append({"product_id": product_id, "quantity": quantity})
    cart_collection.update_one(
        {"user_email": user_email},
        {"$set": {"items": items}},
        upsert=True
    )
    return {"message": "Added to cart", "cart": items}

@app.put("/cart/update", response_model=dict)
def update_cart(user_email: str = Body(...), product_id: str = Body(...), quantity: int = Body(...)):
    if cart_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    cart = cart_collection.find_one({"user_email": user_email})
    items = cart["items"] if cart else []
    for item in items:
        if item["product_id"] == product_id:
            if quantity > 0:
                item["quantity"] = quantity
            else:
                items.remove(item)
            break
    cart_collection.update_one(
        {"user_email": user_email},
        {"$set": {"items": items}},
        upsert=True
    )
    return {"message": "Cart updated", "cart": items}

@app.delete("/cart/remove", response_model=dict)
def remove_from_cart(user_email: str = Body(...), product_id: str = Body(...)):
    if cart_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    cart = cart_collection.find_one({"user_email": user_email})
    items = cart["items"] if cart else []
    items = [item for item in items if item["product_id"] != product_id]
    cart_collection.update_one(
        {"user_email": user_email},
        {"$set": {"items": items}},
        upsert=True
    )
    return {"message": "Removed from cart", "cart": items}

@app.post("/cart/clear", response_model=dict)
def clear_cart(user_email: str = Body(...)):
    if cart_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    cart_collection.update_one(
        {"user_email": user_email},
        {"$set": {"items": []}},
        upsert=True
    )
    return {"message": "Cart cleared"}

@app.get("/cart/total", response_model=dict)
def cart_total(user_email: str, discount: str = None):
    if cart_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    cart = cart_collection.find_one({"user_email": user_email})
    items = cart["items"] if cart else []
    total = 0.0
    for item in items:
        product = products_collection.find_one({"_id": __import__('bson').ObjectId(item["product_id"])})
        if product:
            total += product['price'] * item['quantity']
    strategy = get_discount_strategy(discount) if discount else None
    if strategy:
        total = strategy.apply(total)
    return {"total": total}

@app.get("/cart/detailed", response_model=dict)
def get_cart_detailed(user_email: str):
    if cart_collection is None or products_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    cart = cart_collection.find_one({"user_email": user_email})
    items = cart["items"] if cart else []
    detailed_items = []
    from bson import ObjectId
    for item in items:
        try:
            prod = products_collection.find_one({"_id": ObjectId(item["product_id"])})
        except Exception:
            prod = None
        if prod:
            prod["_id"] = str(prod["_id"])
            detailed_items.append({"product": prod, "quantity": item["quantity"]})
    return {"items": detailed_items}

# --- Wishlist Endpoints ---
@app.get("/wishlist", response_model=dict)
def get_wishlist(user_email: str):
    if wishlist_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    wishlist = wishlist_collection.find_one({"user_email": user_email})
    product_ids = wishlist["product_ids"] if wishlist else []
    return {"products": product_ids}

@app.post("/wishlist/add", response_model=dict)
def add_to_wishlist(user_email: str = Body(...), product_id: str = Body(...)):
    if wishlist_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    wishlist = wishlist_collection.find_one({"user_email": user_email})
    product_ids = wishlist["product_ids"] if wishlist else []
    if product_id not in product_ids:
        product_ids.append(product_id)
    wishlist_collection.update_one(
        {"user_email": user_email},
        {"$set": {"product_ids": product_ids}},
        upsert=True
    )
    return {"message": "Added to wishlist", "wishlist": product_ids}

@app.delete("/wishlist/remove", response_model=dict)
def remove_from_wishlist(user_email: str = Body(...), product_id: str = Body(...)):
    if wishlist_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    wishlist = wishlist_collection.find_one({"user_email": user_email})
    product_ids = wishlist["product_ids"] if wishlist else []
    product_ids = [pid for pid in product_ids if pid != product_id]
    wishlist_collection.update_one(
        {"user_email": user_email},
        {"$set": {"product_ids": product_ids}},
        upsert=True
    )
    return {"message": "Removed from wishlist", "wishlist": product_ids}

@app.post("/wishlist/clear", response_model=dict)
def clear_wishlist(user_email: str = Body(...)):
    if wishlist_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    wishlist_collection.update_one(
        {"user_email": user_email},
        {"$set": {"product_ids": []}},
        upsert=True
    )
    return {"message": "Wishlist cleared"}

@app.get("/wishlist/detailed", response_model=dict)
def get_wishlist_detailed(user_email: str):
    if wishlist_collection is None or products_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    wishlist = wishlist_collection.find_one({"user_email": user_email})
    product_ids = wishlist["product_ids"] if wishlist else []
    from bson import ObjectId
    products = []
    for pid in product_ids:
        try:
            prod = products_collection.find_one({"_id": ObjectId(pid)})
        except Exception:
            prod = None
        if prod:
            prod["_id"] = str(prod["_id"])
            products.append(prod)
    return {"products": products}


@app.get("/")
def read_root():
    return {"message": "FastAPI Backend with MongoDB is running!"}

@app.get("/health")
def health_check():
    if client is not None and client.admin.command('ping'):
        return {"status": "healthy", "database": "MongoDB connected"}
    return {"status": "unhealthy", "database": "MongoDB disconnected"}

@app.post("/signup", response_model=Token)
def signup(user: UserCreate):
    if users_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    
    
    existing_user = users_collection.find_one({"email": user.email})
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    
    user_doc = {
        "username": user.username,
        "email": user.email,
        "hashed_password": get_password_hash(user.password),
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow()
    }
    
   
    result = users_collection.insert_one(user_doc)
    
    if result.inserted_id:
        access_token = create_access_token(data={"sub": user.email})
        return {"access_token": access_token, "token_type": "bearer"}
    else:
        raise HTTPException(status_code=500, detail="Failed to create user")

@app.post("/login", response_model=Token)
def login(form_data: OAuth2PasswordRequestForm = Depends()):
    if users_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    
    
    user = users_collection.find_one({"email": form_data.username})
    
    if not user or not verify_password(form_data.password, product["hashed_password"]):
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    
    access_token = create_access_token(data={"sub": user["email"]})
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users")
def get_users():
    if users_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    
    users = list(users_collection.find({}, {"hashed_password": 0})) 
    return {"users": users, "count": len(users)}

@app.post("/products", response_model=dict)
def create_product(product: Product):
    if products_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    now = datetime.utcnow()
    product_dict = product.dict()
    product_dict["created_at"] = now
    product_dict["updated_at"] = now
    result = products_collection.insert_one(product_dict)
    if result.inserted_id:
        product_dict["_id"] = str(result.inserted_id)
        return {"product": product_dict}
    else:
        raise HTTPException(status_code=500, detail="Failed to create product")

@app.get("/products", response_model=dict)
def list_products(skip: int = 0, limit: int = 20):
    if products_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    products = list(products_collection.find().skip(skip).limit(limit))
    for p in products:
        p["_id"] = str(p["_id"])
    return {"products": products, "count": len(products)}

@app.get("/products/search", response_model=dict)
def search_products(
    name: Optional[str] = None,
    category: Optional[str] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    skip: int = 0,
    limit: int = 20
):
    if products_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    query = {}
    if name:
        query["name"] = {"$regex": name, "$options": "i"}
    if category:
        query["category"] = category
    if min_price is not None or max_price is not None:
        price_query = {}
        if min_price is not None:
            price_query["$gte"] = min_price
        if max_price is not None:
            price_query["$lte"] = max_price
        query["price"] = price_query
    products = list(products_collection.find(query).skip(skip).limit(limit))
    for p in products:
        p["_id"] = str(p["_id"])
    return {"products": products, "count": len(products)}

@app.get("/products/{product_id}", response_model=dict)
def get_product(product_id: str):
    if products_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    from bson import ObjectId
    product = products_collection.find_one({"_id": ObjectId(product_id)})
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    product["_id"] = str(product["_id"])
    return {"product": product}

@app.put("/products/{product_id}", response_model=dict)
def update_product(product_id: str, product: ProductUpdate):
    if products_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    from bson import ObjectId
    update_data = {k: v for k, v in product.dict().items() if v is not None}
    update_data["updated_at"] = datetime.utcnow()
    result = products_collection.update_one({"_id": ObjectId(product_id)}, {"$set": update_data})
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Product not found")
    updated_product = products_collection.find_one({"_id": ObjectId(product_id)})
    updated_product["_id"] = str(updated_product["_id"])
    return {"product": updated_product}

@app.delete("/products/{product_id}", response_model=dict)
def delete_product(product_id: str):
    if products_collection is None:
        raise HTTPException(status_code=500, detail="Database connection failed")
    from bson import ObjectId
    result = products_collection.delete_one({"_id": ObjectId(product_id)})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Product not found")
    return {"message": "Product deleted"}

if __name__ == "__main__":
    import uvicorn
    print("Starting FastAPI server with MongoDB...")
    uvicorn.run(app, host="127.0.0.1", port=8000)
