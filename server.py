#!/usr/bin/python3
import flask
from flask import render_template, request, flash, session, redirect, url_for;
from flask_mysqldb import MySQL;
import MySQLdb.cursors;

app = flask.Flask(__name__);
app.config['MYSQL_HOST'] = 'localhost';
app.config['MYSQL_USER'] = 'user';
app.config['MYSQL_PASSWORD'] = 'dragon1234';
app.config['MYSQL_DB'] = 'giv';

app.config['SECRET_KEY'] = "7\xac\xc9\xeeW\x9d\xec^\xf2\xdah\xf5\x8d\x10\x0e\xfc\xdcfY\xd0\x1e\xad\xf98";

mysql = MySQL(app);

@app.route('/')
def home():
    if(session.get('logged_in')):
        return redirect(url_for("feed"));
    return render_template('index.html')

@app.route('/about', methods=["GET", "POST"])
def about():
    # if(request.method == "POST" and "username" in request.form):
        # details = request.form;
        # username = details["username"];
        # try:
            # cur = mysql.connection.cursor();
            # cur.execute("SELECT username, email FROM user WHERE username = %s", (username,));
            # data = cur.fetchall();
            # cur.close();
            # return render_template('results.html', data=data);
        # except Exception as e:
            # return "MySQL Error" + str(e.args);
    return render_template('about.html'); #TODO

@app.route('/<user>')
def welcome(user):
    return render_template('welcome.html', user=user);

@app.route('/contact')
def contact():
    return render_template('contact.html');

@app.route('/register', methods=["GET", "POST"])
def register():
    if(request.method == "POST"):
        details = request.form;
        email = details["email"];
        username = details["username"];
        password = details["password"];
        try:
            cur = mysql.connection.cursor();
            cur.execute("INSERT INTO user(email, username, password) VALUES (%s, %s, %s)", (email, username, password));
            mysql.connection.commit();
            cur.close();
            return "You are now registered :D";
        except Exception as e:
            return "MySQL Error [%d] : %s" % (e.args[0], e.args[1]);
    return render_template('register.html'); #TODO

@app.route('/login', methods=["GET", "POST"])
def login():
    if(request.method == "POST" and "username" in request.form and "password" in request.form):
        username = request.form["username"];
        password = request.form["password"];

        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor);
        cursor.execute("SELECT * FROM user WHERE username = %s AND password = %s", (username, password));
        user = cursor.fetchone();
        if(user): 
            session['logged_in'] = True;
            session['username'] = username;
            return redirect(url_for("feed"));
            # return "Logged in :D";
        else:
            flash("Incorrect login details.");
            return render_template('login.html');
    return render_template('login.html');

@app.route('/feed')
def feed():
    if(not session.get('logged_in')):
        return redirect(url_for("home"));
    return render_template("feed.html");

@app.route('/chatgroup/new', methods=['GET', 'POST'])
def new_chat_group():
    if(not session.get('logged_in')):
        return redirect(url_for("home"));
    
    # if(request.method == "POST" and "username" in request.form):
        # print(request.form);
        # for t in request.form:
            # if(t[0][:8] != "btncheck"):
                # continue;   
        # username = request.form["username"];
        # username = "%" + username + "%";
        
    current_user = session.get('username');

    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor);
    cursor.execute("SELECT username FROM user WHERE username <> %s", (current_user,));
    users = cursor.fetchall();
    return render_template("newchatgroup.html", users=users);
    # else:
        # pass;
    # return render_template("newchatgroup.html");

@app.route('/members')
def members():
    return render_template('members.html');

if __name__ == '__main__':
    app.run();
