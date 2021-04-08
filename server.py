#!/usr/bin/python3
import flask
from flask import render_template, request, flash, session, redirect, url_for
from flask_mysqldb import MySQL
import MySQLdb.cursors

import datetime

app = flask.Flask(__name__)
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'user'
app.config['MYSQL_PASSWORD'] = 'dragon1234'
app.config['MYSQL_DB'] = 'giv'; 
app.config['SECRET_KEY'] = "7\xac\xc9\xeeW\x9d\xec^\xf2\xdah\xf5\x8d\x10\x0e\xfc\xdcfY\xd0\x1e\xad\xf98"

mysql = MySQL(app)

@app.route('/')
def home():
    if(session.get('logged_in')):
        return redirect(url_for("feed"))
    return render_template('index.html')

@app.route('/about', methods=["GET", "POST"])
def about():
    # if(request.method == "POST" and "username" in request.form):
        # details = request.form
        # username = details["username"]
        # try:
            # cur = mysql.connection.cursor()
            # cur.execute("SELECT username, email FROM user WHERE username = %s", (username,))
        # data = cur.fetchall()
        # cur.close()
        # return render_template('results.html', data=data)
    # except Exception as e:
        # return "MySQL Error" + str(e.args)
    return render_template('about.html', logged_in = session.get('logged_in')); #TODO

@app.route('/<user>')
def welcome(user):
    return render_template('welcome.html', user=user)

@app.route('/contact')
def contact():
    return render_template('contact.html')

@app.route('/register', methods=["GET", "POST"])
def register():
    if(request.method == "POST"):
        details = request.form
        email = details["email"]
        username = details["username"]
        password = details["password"]
        try:
            cur = mysql.connection.cursor()
            cur.execute("INSERT INTO user(email, username, password) VALUES (%s, %s, %s)", (email, username, password))
            mysql.connection.commit()
            cur.close()
            return "You are now registered :D"
        except Exception as e:
            return "MySQL Error [%d] : %s" % (e.args[0], e.args[1])
    return render_template('register.html'); #TODO

@app.route('/login', methods=["GET", "POST"])
def login():
    if(request.method == "POST" and "username" in request.form and "password" in request.form):
        username = request.form["username"]
        password = request.form["password"]

        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("SELECT * FROM user WHERE username = %s AND password = %s", (username, password))
        user = cursor.fetchone()
        if(user): 
            session['logged_in'] = True
            session['username'] = username
            return redirect(url_for("feed"))
            # return "Logged in :D"
        else:
            flash("Incorrect login details.")
            return render_template('login.html')
    return render_template('login.html')

@app.route('/feed')
def feed():
    if(not session.get('logged_in')):
        return redirect(url_for("home"))

    current_username = session.get('username')
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    #Grab all users current user is following.
    query = """
    SELECT username
    FROM user
    WHERE username IN
    (SELECT following FROM follow WHERE follower = %s)
    """ 
    cursor.execute(query, (current_username,))
    followings = cursor.fetchall();

    #Grab all chat groups the user is part of.
    query = """
    SELECT name, chat_group_id 
    FROM chat_group 
    WHERE chat_group_id IN 

    (SELECT chat_group_id 
    FROM user_chat_info 
    WHERE user_chat_info.username = %s)
    """
    cursor.execute(query, (current_username,))
    chat_groups = cursor.fetchall()

    #Grab all interest groups the user is part of.
    query = """
    SELECT * 
    FROM interest_group
    WHERE name IN

    (SELECT interest_group
    FROM interest_group_participants
    WHERE username = %s);
    """

    cursor.execute(query, (current_username,))
    interest_groups = cursor.fetchall()

    cursor.close();

    return render_template("feed.html", username=session.get('username'), followings=followings, chat_groups=chat_groups, interest_groups=interest_groups)

@app.route('/follow/new')
def follow():
    if(not session.get('logged_in')):
        #Not logged in!
        return redirect(url_for("login"))

    current_username = session.get('username')

    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    query = """
    SELECT username, IF(username IN (SELECT following FROM follow WHERE follower = %s), 1, 0) as is_following
    FROM user
    WHERE username <> %s;
    """
    cursor.execute(query, (current_username, current_username))
    users = cursor.fetchall()
    cursor.close()
    return render_template("follow.html", users=users)

@app.route('/chatgroup/new', methods=['GET', 'POST'])
def new_chat_group():
    #TODO: Images?
    if(not session.get('logged_in')):
        return redirect(url_for("login"))
    
    if(request.method == "POST" and "name" in request.form):
        #Keep track of all users in the new group.
        new_group_users = [session.get('username')]
        for v in request.form:
            if "btncheck_" in v:
                username = v[9:]
                new_group_users.append(username)

        chat_group_name = request.form["name"][:30]
        chat_group_desc = None
        if("description" in request.form):
            chat_group_desc = request.form["description"][:100]

        #Get next chat group id by finding the current highest chat group id, then adding 1.
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("SELECT chat_group_id + 1 AS new_chat_group_id FROM chat_group ORDER BY chat_group_id DESC LIMIT 1;")
        new_chat_group_id = cursor.fetchone()["new_chat_group_id"]

        creation_date = datetime.date.today().strftime("%Y-%m-%d")

        image = None
    
        #Insert new chat group into database.
        cursor.execute("INSERT INTO chat_group VALUES (%s, %s, %s, %s, %s)", (new_chat_group_id, chat_group_name, chat_group_desc, image, creation_date))

        #Insert into database all the users info.
        for username in new_group_users:
            #Verify they exist.
            cursor.execute("SELECT * FROM user WHERE username = %s", (username,))
            user = cursor.fetchone()
            if(user):
                cursor.execute("INSERT INTO user_chat_info VALUES (%s, %s)", (username, new_chat_group_id))


        mysql.connection.commit()
        cursor.close()
        return redirect(url_for("feed"))

        
    current_user = session.get('username')

    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute("SELECT username FROM user WHERE username <> %s", (current_user,))
    users = cursor.fetchall()
    cursor.close()
    return render_template("newchatgroup.html", users=users)
    # else:
        # pass
    # return render_template("newchatgroup.html")

@app.route('/chatgroup/<int:chat_id>', methods=["GET", "POST"])
def chat_group(chat_id):
    if(not session.get('logged_in')):
        #Not even logged in...
        return redirect(url_for("login"))

    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

    #Get info about the chat selected.
    cursor.execute("SELECT * FROM chat_group WHERE chat_group_id = %s", (chat_id,))
    chat_group = cursor.fetchone()
    print(chat_group)

    #If user is not in chat group, and thus is not authorized to view:
    current_username = session.get('username')

    cursor.execute("SELECT * FROM user_chat_info WHERE chat_group_id = %s AND username = %s", (chat_id, current_username))
    valid = cursor.fetchone()
    
    if(not valid):
        #User is not in chat group.
        return redirect(url_for("feed"))

    #User can view chat group

    #If user posted message:
    if(request.method == "POST" and "content" in request.form):
        #Get highest message id and add one. Like chat group id basically.
        cursor.execute("SELECT message_id + 1 AS new_message_id FROM message WHERE message.chat_group_id = %s ORDER BY message_id DESC LIMIT 1;", (chat_id,))
        new_message_id = cursor.fetchone()
        if(new_message_id):
            new_message_id = new_message_id["new_message_id"]
        else:
            #No messages in chat group yet.
            new_message_id = 1

        content = request.form["content"]
        sender = session.get('username')
        reply_id = None
        time_sent = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        cursor.execute("INSERT INTO message VALUES (%s, %s, %s, %s, %s, %s)", (chat_id, new_message_id, content, sender, reply_id, time_sent))
        mysql.connection.commit()

    #Get all members of chat group
    # cursor.execute("SELECT username FROM user_chat_info WHERE chat_group_id = %s", (chat_id,))

    query = """
    SELECT username, IF(username IN (SELECT username FROM chat_group_moderators WHERE chat_group_id = %s), 1, 0) as is_mod
    FROM user_chat_info
    WHERE chat_group_id = %s 
    """
    cursor.execute(query, (chat_id, chat_id));
    users = cursor.fetchall()

    #Get current user in this chat group.
    query += "AND username = %s";
    cursor.execute(query, (chat_id, chat_id, current_username))
    current_user = cursor.fetchone();

    #Get all info about messages
    cursor.execute("SELECT * FROM message WHERE chat_group_id = %s ORDER BY time_sent, message_id", (chat_id,))
    messages = cursor.fetchall()

    cursor.close()

    return render_template("chat.html", current_user=current_user, users=users, messages=messages, chat_group=chat_group)

@app.route('/chatgroup/<int:chat_id>/edit', methods=["GET", "POST"])
def edit_chat_group(chat_id):
    if(not session.get('logged_in')):
        #Not even logged in...
        return redirect(url_for("login"))

    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

    #Get info about the chat selected.
    cursor.execute("SELECT * FROM chat_group WHERE chat_group_id = %s", (chat_id,))
    chat_group = cursor.fetchone()
    print(chat_group)

    #If user is moderator of chat group.
    current_username = session.get('username')

    cursor.execute("SELECT * FROM chat_group_moderators WHERE chat_group_id = %s AND username = %s", (chat_id, current_username))
    valid = cursor.fetchone()
    
    if(not valid):
        #User is not moderating chat group.
        return redirect(url_for("chat_group", chat_id=chat_id))
    
    if(request.method == "POST" and "name" in request.form):
        #Keep track of all users in the new group.
        new_group_users = []
        deleted_users = []
        new_group_moderators = []
        dismissed_moderators = []
        for v in request.form:
            if "btncheck_a_" in v:
                username = v[11:]
                new_group_users.append(username)
            elif "btncheck_r_" in v:
                username = v[11:]
                deleted_users.append(username);
            elif "btncheck_m_" in v:
                username = v[11:]
                new_group_moderators.append(username);
            elif "btncheck_d_" in v:
                username = v[11:]
                dismissed_moderators.append(username);

        chat_group_name = request.form["name"][:30]
        chat_group_desc = None
        if("description" in request.form):
            chat_group_desc = request.form["description"][:100]

        #Update into database new info.
        cursor.execute("UPDATE chat_group SET name = %s, description = %s WHERE chat_group_id = %s", (chat_group_name, chat_group_desc, chat_id));
        #Insert into database all the new users info.
        for username in new_group_users:
            #Verify they exist.
            cursor.execute("SELECT * FROM user WHERE username = %s", (username,))
            user = cursor.fetchone()
            if(user):
                cursor.execute("INSERT INTO user_chat_info VALUES (%s, %s)", (username, chat_id))

        #Delete from database all the new users info.
        for username in deleted_users:
            cursor.execute("SELECT * FROM user WHERE username = %s", (username,))
            user = cursor.fetchone()
            if(user):
                cursor.execute("DELETE FROM user_chat_info WHERE username = %s and chat_group_id = %s", (username, chat_id))

        for username in new_group_moderators:
            cursor.execute("SELECT * FROM user WHERE username = %s", (username,))
            user = cursor.fetchone()
            if(user):
                cursor.execute("INSERT INTO chat_group_moderators VALUES (%s, %s)", (chat_id, username));

        for username in dismissed_moderators:
            cursor.execute("SELECT * FROM user WHERE username = %s", (username,))
            user = cursor.fetchone()
            if(user):
                cursor.execute("DELETE FROM chat_group_moderators WHERE chat_group_id = %s AND username = %s", (chat_id, username))

        mysql.connection.commit()
        cursor.close()
        return redirect(url_for("chat_group", chat_id=chat_id))
        
    #Get not added users
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    query = """
    SELECT username 
    FROM user 
    WHERE username <> %s AND username NOT IN
    (SELECT username FROM 
    user_chat_info WHERE chat_group_id = %s)
    """
    cursor.execute(query, (current_username, chat_id))
    not_added_users = cursor.fetchall()

    #Now get added users
    query = """
    SELECT username, IF(username IN (SELECT username FROM chat_group_moderators WHERE chat_group_id = %s), 1, 0) as is_mod
    FROM user_chat_info
    WHERE username <> %s AND chat_group_id = %s
    """
    cursor.execute(query, (chat_id, current_username, chat_id))
    added_users = cursor.fetchall();

    cursor.close()
    return render_template("editchatgroup.html", not_added_users=not_added_users, added_users=added_users, chat_group=chat_group)

@app.route('/chatgroup/<int:chat_id>/exit', methods=["GET", "POST"])
def exit_chat_group(chat_id):
    if(not session.get('logged_in')):
        #Not even logged in...
        return redirect(url_for("login"))
    
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    current_username = session.get('username');

    #Delete user from user_chat_info
    cursor.execute("DELETE FROM user_chat_info WHERE username = %s AND chat_group_id = %s", (current_username, chat_id));
    mysql.connection.commit()
    cursor.close();

    return redirect(url_for('feed'));

@app.route('/interestgroup/new', methods=['GET', 'POST'])
def new_interest_group():
    if(not session.get('logged_in')):
        #Not even logged in...
        return redirect(url_for("login"))

    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    current_username = session.get('username')

    if(request.method == "POST"):
        #Check which interest group user wants to join.
        for i in request.form:
            if(i[:5] == "join_"):
                interest_group = i[5:];
                
                #Verify interest group exists
                cursor.execute("SELECT * FROM interest_group WHERE name = %s", (interest_group,));
                valid = cursor.fetchone();
                if(valid):
                    cursor.execute("INSERT INTO interest_group_participants VALUES (%s, %s)", (interest_group, current_username))
                    mysql.connection.commit()
                    return redirect(url_for("interest_group", interest_group_name=interest_group))
                else:
                    break;
            break; #We're only expecting one value inside the form.
        flash("Sorry, an unexpected error occurred. Please try again.");
    # query = """
    # SELECT * FROM interest_group
    # WHERE name IN 
    # (
        # SELECT interest_group
        # FROM interest_group_participants
        # WHERE username <> %s
    # )
    # """

    #Get all info about interest groups, and also whether user is currently in it or not.
    query = """
    SELECT *, IF(ig.name IN (SELECT interest_group FROM interest_group_participants WHERE username = %s), 1, 0) AS in_group
    FROM interest_group ig;
    """
    cursor.execute(query, (current_username,))
    interest_groups = cursor.fetchall()

    cursor.close()
    return render_template("newinterestgroup.html", interest_groups=interest_groups)

@app.route('/interestgroup/create', methods=['GET', 'POST'])
def create_interest_group():
    if(not session.get('logged_in')):
        #Not even logged in...
        return redirect(url_for("login"))

    if(request.method == "POST" and "interest_group_name" in request.form):
        interest_group_name = request.form.get("interest_group_name");
        interest_group_desc = request.form.get("interest_group_description");
        creation_date = datetime.date.today().strftime("%Y-%m-%d")

        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        #Check if interest group already exists.
        cursor.execute("SELECT name FROM interest_group WHERE name=%s", (interest_group_name,));
        invalid = cursor.fetchone();
        if(invalid):
            flash("Interest group already exists!")
            return render_template("createinterestgroup.html");

        cursor.execute("INSERT INTO interest_group VALUES (%s, %s, %s)", (interest_group_name, interest_group_desc, creation_date))
        mysql.connection.commit()
        cursor.close()
        return redirect(url_for("interest_group", interest_group_name=interest_group_name))

    return render_template("createinterestgroup.html");

@app.route('/interestgroup/<string:interest_group_name>')
def interest_group(interest_group_name):
    if(not session.get('logged_in')):
        #Not even logged in...
        return redirect(url_for("login"))

    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute("SELECT * FROM interest_group WHERE name = %s", (interest_group_name,));
    interest_group = cursor.fetchone();
        
    #If interest group does not exist:
    if(not interest_group):
        return redirect(url_for("feed"));

    #Get all posts in the interest group.
    cursor.execute("SELECT * FROM post LEFT JOIN posting_info ON post.post_id = posting_info.post_id WHERE posting_info.interest_group = %s", (interest_group_name,));
    posts = cursor.fetchall();

    return render_template("interestgroup.html", interest_group=interest_group, posts=posts);

@app.route('/interestgroup/<string:interest_group_name>/post/new', methods=['GET', 'POST'])
def createpost(interest_group_name):
    if(not session.get('logged_in')):
        #Not even logged in...
        return redirect(url_for("login"))

    if(request.method == "POST" and "title" in request.form):
        current_username = session.get('username')
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("SELECT * FROM interest_group WHERE name = %s", (interest_group_name,));
        interest_group = cursor.fetchone();

        if(interest_group):
            #interest group exists, posting is allowed
            cursor.execute("SELECT post_id + 1 AS new_post_id FROM post ORDER BY post_id DESC LIMIT 1;")
            post_id = cursor.fetchone()["new_post_id"];

            posting_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            post_title = request.form['title'];
            post_content = request.form['content'];
            views = 0;
            likes = 0;
            posted_by = current_username;

            cursor.execute("INSERT INTO post VALUES (%s, %s, %s, %s, %s, %s, %s)", (post_id, posting_time, posting_time, post_content, views, likes, posted_by))
            cursor.execute("INSERT INTO posting_info VALUES (%s, %s, %s)", (post_id, interest_group_name, current_username));
            mysql.connection.commit()
            cursor.close();
            return redirect(url_for("post", interest_group_name=interest_group_name, post_id=post_id))

    return render_template("createpost.html");

@app.route('/interestgroup/<string:interest_group_name>/post/<int:post_id>', methods=['GET', 'POST'])
def post(interest_group_name, post_id):
    if(not session.get('logged_in')):
        #Not even logged in...
        return redirect(url_for("login"))

    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute("SELECT * FROM interest_group WHERE name = %s", (interest_group_name,));
    interest_group = cursor.fetchone();
        
    #If interest group does not exist:
    if(not interest_group):
        return redirect(url_for("feed"));

    cursor.execute("SELECT * FROM post LEFT JOIN posting_info ON post.post_id = posting_info.post_id WHERE interest_group = %s AND post.post_id = %s", (interest_group_name, post_id));
    post = cursor.fetchone(); #Get post

    #If post does not exist:
    if(not post):
        return redirect(url_for("feed"));

    #Handle user comment
    if(request.method == "POST" and "content" in request.form):
        #Get highest message id and add one. Like chat group id basically.
        cursor.execute("SELECT comment_id + 1 AS new_comment_id FROM comment WHERE comment.post_id = %s ORDER BY comment_id DESC LIMIT 1;", (post_id,))
        new_comment_id = cursor.fetchone()
        if(new_comment_id):
            new_comment_id = new_comment_id["new_comment_id"]
        else:
            #No messages in chat group yet.
            new_comment_id = 1

        time_commented = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        content = request.form["content"]
        reply_id = None
        posted_by = session.get('username')
        
        cursor.execute("INSERT INTO comment VALUES (%s, %s, %s, %s, %s, %s)", (post_id, new_comment_id, time_commented, content, reply_id, posted_by))
        mysql.connection.commit()

    #Get comments about post:
    cursor.execute("SELECT * FROM comment WHERE post_id = %s", (post_id,));
    comments = cursor.fetchall(); #Get post

    return render_template("post.html", post=post, comments=comments);

@app.route('/logout')
def logout():
    if(not session.get('logged_in')):
        #Not even logged in in the first place...
        return redirect(url_for("login"))
    session.pop("logged_in", None)
    session.pop("username", None)
    return redirect(url_for("login"))


@app.route('/members')
def members():
    return render_template('members.html')

if __name__ == '__main__':
    app.run()
