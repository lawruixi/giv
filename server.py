import flask
from flask import render_template;

app = flask.Flask(__name__);

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/about')
def about():
    return render_template('about.html');

@app.route('/<user>')
def welcome(user):
    return render_template('welcome.html', user=user);

@app.route('/contact')
def contact():
    return render_template('contact.html');

@app.route('/members')
def members():
    return render_template('members.html');

if __name__ == '__main__':
    app.run();
