from flask import Flask, render_template, request, redirect, url_for, session, flash
import requests
import datetime
import os

from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, login_user, logout_user, login_required, current_user
from models import db, User, Order

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key'
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get(
    'DATABASE_URL',
    'sqlite:///site.db'  # fallback for local dev
)

db.init_app(app)
login_manager = LoginManager(app)
login_manager.login_view = 'login'

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# Dummy product data (replace with DB/API in production)
PRODUCTS = [
    {"id": 1, "name": "Wireless Mouse", "price": 19.99, "description": "Ergonomic wireless mouse.", "image": "https://via.placeholder.com/300x200?text=Mouse"},
    {"id": 2, "name": "Mechanical Keyboard", "price": 49.99, "description": "RGB backlit mechanical keyboard.", "image": "https://via.placeholder.com/300x200?text=Keyboard"},
    {"id": 3, "name": "HD Monitor", "price": 129.99, "description": "24-inch Full HD monitor.", "image": "https://via.placeholder.com/300x200?text=Monitor"}
]

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/products')
def products():
    return render_template('products.html', products=PRODUCTS)

@app.route('/cart')
def cart():
    cart = session.get('cart', {})
    cart_items = []
    total = 0
    for pid, qty in cart.items():
        product = next((p for p in PRODUCTS if p['id'] == int(pid)), None)
        if product:
            item = product.copy()
            item['quantity'] = qty
            item['total'] = qty * product['price']
            cart_items.append(item)
            total += item['total']
    return render_template('cart.html', cart=cart_items, total=total)

@app.route('/add_to_cart/<int:product_id>')
def add_to_cart(product_id):
    cart = session.get('cart', {})
    cart[str(product_id)] = cart.get(str(product_id), 0) + 1
    session['cart'] = cart
    flash('Product added to cart!')
    return redirect(url_for('products'))

@app.route('/remove_from_cart/<int:product_id>')
def remove_from_cart(product_id):
    cart = session.get('cart', {})
    if str(product_id) in cart:
        del cart[str(product_id)]
        session['cart'] = cart
    return redirect(url_for('cart'))

@app.route('/checkout', methods=['GET', 'POST'])
@login_required
def checkout():
    cart = session.get('cart', {})
    cart_items = []
    total = 0
    for pid, qty in cart.items():
        product = next((p for p in PRODUCTS if p['id'] == int(pid)), None)
        if product:
            item = product.copy()
            item['quantity'] = qty
            item['total'] = qty * product['price']
            cart_items.append(item)
            total += item['total']
    if request.method == 'POST':
        # Save order to DB
        order = Order(user_id=current_user.id, total=total, date=str(datetime.date.today()))
        db.session.add(order)
        db.session.commit()
        session.pop('cart', None)
        flash('Order placed successfully!')
        return redirect(url_for('orders'))
    return render_template('checkout.html', cart=cart_items, total=total)

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        email = request.form['email']
        password = request.form['password']
        print(f"Registering user: {username}, {email}")  # Debug print
        if User.query.filter_by(username=username).first():
            flash('Username already exists')
            return redirect(url_for('register'))
        user = User(username=username, email=email)
        user.set_password(password)
        db.session.add(user)
        db.session.commit()
        print(f"User {username} registered!")  # Debug print
        flash('Registration successful! Please log in.')
        return redirect(url_for('login'))
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        print(f"Login attempt: {username}")  # Debug print
        user = User.query.filter_by(username=username).first()
        if user and user.check_password(password):
            login_user(user)
            flash('Logged in successfully!')
            print(f"User {username} logged in!")  # Debug print
            return redirect(url_for('index'))
        else:
            flash('Invalid username or password')
            print(f"Login failed for {username}")  # Debug print
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('Logged out successfully!')
    return redirect(url_for('login'))

@app.route('/orders')
@login_required
def orders():
    user_orders = Order.query.filter_by(user_id=current_user.id).all()
    return render_template('orders.html', orders=user_orders)

if __name__ == '__main__':
    with app.app_context():
        db.create_all()  # Ensure all tables are created before running
    app.run(host='0.0.0.0', port=5000)
