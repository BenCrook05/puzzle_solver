from flask import Flask
app = Flask(__name__)

@app.route('/', methods=['POST'])
def endpoint():
    return 'Hello world'