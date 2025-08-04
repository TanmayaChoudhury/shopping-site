from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/cart')
def get_cart():
    # Example static response
    return jsonify({"cart": []})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
