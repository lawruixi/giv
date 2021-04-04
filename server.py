#!/usr/bin/python3
import flask
from flask import render_template, request, flash, session, redirect, url_for;
from flask_mysqldb import MySQL;
import MySQLdb.cursors;

import datetime;

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
    return render_template('about.html', logged_in = session.get('logged_in')); #TODO

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

    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor);
    query = """
    SELECT name 
    FROM chat_group 
    WHERE chat_group_id IN 

    (SELECT chat_group_id 
    FROM user_chat_info 
    WHERE user_chat_info.username = %s);
    """;
    cursor.execute(query, (session.get('username'),));
    chat_groups = cursor.fetchall();

    return render_template("feed.html", username=session.get('username'), chat_groups=chat_groups);

@app.route('/chatgroup/new', methods=['GET', 'POST'])
def new_chat_group():
    #TODO: Images? Multiple mods?
    if(not session.get('logged_in')):
        return redirect(url_for("home"));
    
    if(request.method == "POST" and "name" in request.form):
        print(request.form);
        #Keep track of all users in the new group.
        new_group_users = [session.get('username')];
        for v in request.form:
            if "btncheck_" in v:
                username = v[9:];
                new_group_users.append(username);

        chat_group_name = request.form["name"][:30];
        chat_group_desc = None;
        if("description" in request.form):
            chat_group_desc = request.form["description"][:100];

        #Get next chat group id by finding the current highest chat group id, then adding 1.
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor);
        cursor.execute("SELECT chat_group_id + 1 AS new_chat_group_id FROM chat_group ORDER BY chat_group_id DESC LIMIT 1;");
        new_chat_group_id = cursor.fetchone()["new_chat_group_id"];

        creation_date = datetime.date.today().strftime("%Y-%m-%d");

        image = None;
    
        moderator_username = session.get("username");

        #Insert new chat group into database.
        cursor.execute("INSERT INTO chat_group VALUES (%s, %s, %s, %s, %s, %s)", (new_chat_group_id, chat_group_name, chat_group_desc, image, creation_date, moderator_username));

        #Insert into database all the users info.
        for username in new_group_users:
            #Verify they exist.
            cursor.execute("SELECT * FROM user WHERE username = %s", (username,));
            user = cursor.fetchone();
            if(user):
                cursor.execute("INSERT INTO user_chat_info VALUES (%s, %s)", (username, new_chat_group_id));


        mysql.connection.commit();
        cursor.close();
        return redirect(url_for("feed"));

        
    current_user = session.get('username');

    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor);
    cursor.execute("SELECT username FROM user WHERE username <> %s", (current_user,));
    users = cursor.fetchall();
    cursor.close();
    return render_template("newchatgroup.html", users=users);
    # else:
        # pass;
    # return render_template("newchatgroup.html");

@app.route('/logout')
def logout():
    if(not session.get('logged_in')):
        #Not even logged in in the first place...
        return redirect(url_for("login"));
    session.pop("logged_in", None);
    session.pop("username", None);
    return redirect(url_for("login"));

@app.route('/members')
def members():
    return render_template('members.html');

if __name__ == '__main__':
    app.run();
