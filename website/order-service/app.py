from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/orders')
def get_orders():
    # Example static response
    return jsonify({"orders": []})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
