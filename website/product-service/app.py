from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/products')
def get_products():
    # Example static response
    return jsonify([
        {"id": 1, "name": "Product 1", "price": 10.0},
        {"id": 2, "name": "Product 2", "price": 20.0}
    ])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
