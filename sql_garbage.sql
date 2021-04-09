DROP DATABASE IF EXISTS giv;
CREATE DATABASE giv;
USE giv;

CREATE TABLE user(
    username varchar(100) NOT NULL,
    password varchar(100) NOT NULL,
    email varchar(100) NOT NULL,
    date_of_birth date,
    country varchar(20),
    num_of_posts int DEFAULT 0,
    PRIMARY KEY (username)
);

CREATE TABLE post(
    post_id int(9) NOT NULL,
    posting_time datetime NOT NULL,
    title varchar(100) NOT NULL,
    content varchar(1000),
    views int NOT NULL,
    likes int NOT NULL,
    posted_by varchar(100) NOT NULL,
    PRIMARY KEY (post_id),
    FOREIGN KEY (posted_by) REFERENCES user(username) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE comment(
    post_id int(9) NOT NULL,
    comment_id int(9) NOT NULL,
    commenting_time datetime NOT NULL,
    content varchar(500) NOT NULL,
    replying_to int(9),
    posted_by varchar(100) NOT NULL,
    PRIMARY KEY (post_id, comment_id),
    FOREIGN KEY (post_id, replying_to) REFERENCES comment(post_id, comment_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (post_id) REFERENCES post(post_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (posted_by) REFERENCES user(username) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE chat_group(
    chat_group_id int(9) NOT NULL,
    name varchar(30) NOT NULL,
    description varchar(100),
    image varchar(200),
    creation_date date,
    PRIMARY KEY (chat_group_id)
);

CREATE TABLE chat_group_moderators(

    chat_group_id int(9) NOT NULL,
    username varchar(100) NOT NULL,
    PRIMARY KEY (chat_group_id, username),
    FOREIGN KEY (chat_group_id) REFERENCES chat_group(chat_group_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (username) REFERENCES user(username) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE message(
    chat_group_id int(9) NOT NULL,
    message_id int(9) NOT NULL,
    content varchar(1000) NOT NULL,
    sender varchar(100) NOT NULL,
    replying_to int(9),
    time_sent datetime,
    PRIMARY KEY (chat_group_id, message_id),
    FOREIGN KEY (chat_group_id) REFERENCES chat_group(chat_group_id),
    FOREIGN KEY (sender) REFERENCES user(username) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (chat_group_id, replying_to) REFERENCES message(chat_group_id, message_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE user_chat_info(
    username varchar(100) NOT NULL,
    chat_group_id int(9) NOT NULL,
    PRIMARY KEY (username, chat_group_id),
    FOREIGN KEY (username) REFERENCES user(username) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (chat_group_id) REFERENCES chat_group(chat_group_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE follow(
    following varchar(100) NOT NULL,
    follower varchar(100) NOT NULL,
    PRIMARY KEY (following, follower),
    FOREIGN KEY (following) REFERENCES user(username) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (follower) REFERENCES user(username) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE interest_group(
    name varchar(100) NOT NULL,
    description varchar(100),
    creation_date date NOT NULL,
    PRIMARY KEY (name)
);

CREATE TABLE posting_info(
    post_id int(9) NOT NULL,
    interest_group varchar(100) NOT NULL,
    username varchar(100) NOT NULL,
    PRIMARY KEY (post_id, interest_group),
    FOREIGN KEY (post_id) REFERENCES post(post_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (interest_group) REFERENCES interest_group(name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (username) REFERENCES user(username) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE interest_group_moderators(
    interest_group varchar(100) NOT NULL,
    username varchar(100) NOT NULL,
    PRIMARY KEY (interest_group, username),
    FOREIGN KEY (interest_group) REFERENCES interest_group(name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (username) REFERENCES user(username) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE interest_group_participants(
    interest_group varchar(100) NOT NULL,
    username varchar(100) NOT NULL,
    PRIMARY KEY (interest_group, username),
    FOREIGN KEY (interest_group) REFERENCES interest_group(name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (username) REFERENCES user(username) ON DELETE CASCADE ON UPDATE CASCADE
);

DELIMITER //
CREATE TRIGGER updatePostCountTrigger AFTER INSERT ON post
FOR EACH ROW
    BEGIN
        UPDATE user SET num_of_posts = num_of_posts + 1 WHERE new.posted_by = user.username;
    END;//

DELIMITER ;

DELETE FROM user;
INSERT INTO user VALUES ("willsuit", "password1234", "willsuit@test.com", "1996-09-14", "Britain", 0);
INSERT INTO user VALUES ("cookie_destroyer", "yumyumyum", "cookies@test.com", "1984-03-13", "Portugal", 0);
INSERT INTO user VALUES ("cow_lover94", "mooooooooooo", "cowsgomoo@test.com", "1992-01-15", "France", 0);
INSERT INTO user VALUES ("tomminute", "securepassword", "tomminute@test.com", "2004-04-09", "Britain", 0);
INSERT INTO user VALUES ("Theseus", "athens", "theseus@greekmythology.com", NULL, "Greece", 0);
INSERT INTO user VALUES ("qwerty", "keyboard", "azerty@isbetter.com", "1870-02-02", "Wisconsin", 0);
INSERT INTO user VALUES ("hello", "world", "helloworld@test.com", "1974-03-09", "Canada", 0);
INSERT INTO user VALUES ("big_dinosaur11", "bestpassword", "dino@saur.com", "1993-03-11", "Montenegro", 0);
INSERT INTO user VALUES ("Angel_of_Death_9999", "luciferiscool", "angel@test.com", "2013-07-30", "Puerto Rico", 0);
INSERT INTO user VALUES ("aquaman", "water", "aqua@man.com", "1995-06-28", "Bangladesh", 0);
INSERT INTO user VALUES ("alphabet_king", "abcdefghij", "alphabet@test.com", "1998-07-07", "Comoros", 0);
INSERT INTO user VALUES ("tee_sword", "suspog", "tee@sword.com", "1999-06-01", "USA", 0);
INSERT INTO user VALUES ("CrispyChips", "sourcream", "crispychips@test.com", "2001-03-16", "Senegal", 0);

DELETE FROM interest_group;
INSERT INTO interest_group VALUES ("Mine Art", "The best mining simulator game!", "2009-05-17");
INSERT INTO interest_group VALUES ("Chess", "An intellectually stimulating strategy game.", "0613-10-15");
INSERT INTO interest_group VALUES ("Jokes", "A very funny place to be.", "2020-05-24");
INSERT INTO interest_group VALUES ("Music", "La la la", "2021-03-15");
INSERT INTO interest_group VALUES ("Chatting", "Friendly interest group <3!", "2020-07-25");
INSERT INTO interest_group VALUES ("Advice", "Give advice to other people who need help!", "2020-10-15");
INSERT INTO interest_group VALUES ("Giv", "Post anything related to the popular social media Giv!", "2021-03-21");

DELETE FROM post;
INSERT INTO post VALUES (1, "2020-09-09", "POG2020", NULL, 1200, 200, "willsuit");
INSERT INTO post VALUES (2, "2020-12-28", "Moooooooooooo", NULL, 3729, 1226, "cow_lover94");
INSERT INTO post VALUES (3, "2020-06-18", "Cookie Monster!", NULL, 487, 282, "cookie_destroyer");
INSERT INTO post VALUES (4, "2021-01-16", "Athens is the best place", NULL, 70, 69, "Theseus");
INSERT INTO post VALUES (5, "2021-10-10", "Bought a new keyboard today \:D", NULL, 96, 3, "qwerty");
INSERT INTO post VALUES (6, "2021-03-21", "Hello World!", NULL, 1, 1, "hello");
INSERT INTO post VALUES (7, "2021-02-22", "I think I'm extinct...", NULL, 649, 248, "big_dinosaur11");
INSERT INTO post VALUES (8, "2021-08-13", "Hell > Heaven", NULL, 231, -84, "Angel_of_Death_9999");
INSERT INTO post VALUES (9, "2021-05-18", "Stay hydrated, folks!", NULL, 9313, 8313, "aquaman");
INSERT INTO post VALUES (10, "2021-08-10", "ABCDEFEGHIJKLMNOPQRSTUVWXYZ", NULL, 679, 275, "alphabet_king");

DELETE FROM posting_info;
INSERT INTO posting_info VALUES (1, "Mine Art", "willsuit");
INSERT INTO posting_info VALUES (2, "Chatting", "cow_lover94");
INSERT INTO posting_info VALUES (2, "Jokes", "cow_lover94");
INSERT INTO posting_info VALUES (3, "Music", "cookie_destroyer");
INSERT INTO posting_info VALUES (4, "Chatting", "Theseus");
INSERT INTO posting_info VALUES (5, "Chatting", "qwerty");
INSERT INTO posting_info VALUES (6, "Giv", "hello");
INSERT INTO posting_info VALUES (7, "Chatting", "big_dinosaur11");
INSERT INTO posting_info VALUES (7, "Advice", "big_dinosaur11");
INSERT INTO posting_info VALUES (8, "Jokes", "Angel_of_Death_9999");
INSERT INTO posting_info VALUES (9, "Advice", "aquaman");
INSERT INTO posting_info VALUES (10, "Chatting", "alphabet_king");

DELETE FROM comment;
INSERT INTO comment VALUES (1, 1, "2020-09-09", "pog", NULL, "willsuit");
INSERT INTO comment VALUES (1, 2, "2020-09-09", "pog", 1, "tomminute");
INSERT INTO comment VALUES (1, 3, "2020-09-09", "pog", 2, "willsuit");
INSERT INTO comment VALUES (1, 4, "2020-09-09", "pog", 3, "tomminute");
INSERT INTO comment VALUES (1, 5, "2020-09-09", "pog", 4, "willsuit");

INSERT INTO comment VALUES (2, 1, "2020-12-28", "moo?", NULL, "Theseus");
INSERT INTO comment VALUES (2, 2, "2020-12-28", "moo!", 1, "cow_lover94");
INSERT INTO comment VALUES (2, 3, "2020-12-28", "moo moo", 2, "Theseus");
INSERT INTO comment VALUES (2, 4, "2020-12-28", "what is this thread rn", 3, "cookie_destroyer");
INSERT INTO comment VALUES (2, 5, "2020-12-29", "intelligent beings communicating \:O", 4, "qwerty");

INSERT INTO comment VALUES (2, 6, "2020-12-28", "Who are the other 93 cow lovers?", NULL, "aquaman");
INSERT INTO comment VALUES (2, 7, "2020-12-28", "moo moo", 6, "cow_lover94");
INSERT INTO comment VALUES (2, 8, "2020-12-29", "i think he's trying to get you to join his cult \:>", 7, "qwerty");
INSERT INTO comment VALUES (2, 9, "2020-12-29", "Uh oh", 8, "aquaman");

INSERT INTO comment VALUES (2, 10, "2020-12-28", "cows together strong", NULL, "big_dinosaur11");
INSERT INTO comment VALUES (2, 11, "2020-12-28", "reject modernity return to C O W", 10, "cow_lover94");
INSERT INTO comment VALUES (2, 12, "2020-12-29", "COWXYZABDEFGHIJKLMNPQRSTUV", 11, "alphabet_king");
INSERT INTO comment VALUES (2, 13, "2020-12-29", "Are you... okay?", 12, "aquaman");

INSERT INTO comment VALUES (5, 1, "2021-10-09", "Looks fantastic!", NULL, "aquaman");
INSERT INTO comment VALUES (5, 2, "2021-10-10", "how do you know? they didn't even post a picture o.O", 1, "qwerty");
INSERT INTO comment VALUES (5, 3, "2021-10-10", "Man just casually commented before the posting time", 2, "tomminute");
INSERT INTO comment VALUES (5, 4, "2021-10-10", "lol i didnt even notice", 3, "qwerty");
INSERT INTO comment VALUES (5, 5, "2021-10-10", "is it possible to learn this power", 4, "cookie_destroyer");

INSERT INTO comment VALUES (7, 1, "2021-02-22", "Go back to the afterlife whence you came...", NULL, "Angel_of_Death_9999");
INSERT INTO comment VALUES (7, 2, "2021-02-22", "go back to chrome whence you came", 1, "qwerty");
INSERT INTO comment VALUES (7, 3, "2021-02-22", "Ah yes, Chrome, my favourite mythological afterlife", 2, "Theseus");
INSERT INTO comment VALUES (7, 4, "2021-02-22", "I prefer Firefox myself!", 3, "aquaman");
INSERT INTO comment VALUES (7, 5, "2021-02-22", "why the hell are we talking about web browsers rn", 4, "cookie_destroyer");
INSERT INTO comment VALUES (7, 6, "2021-02-23", "See? Hell is the best place!", 5, "Angel_of_Death_9999");

INSERT INTO comment VALUES (8, 1, "2021-08-13", "no u \:<", NULL, "qwerty");
INSERT INTO comment VALUES (8, 2, "2021-08-13", "bruh it's a joke", 1, "Angel_of_Death_9999");
INSERT INTO comment VALUES (8, 3, "2021-08-13", "oh lol", 2, "qwerty");

INSERT INTO comment VALUES (8, 4, "2021-08-13", "What do you mean there's only the underworld", NULL, "Theseus");
INSERT INTO comment VALUES (8, 5, "2021-08-13", "true", 4, "Angel_of_Death_9999");
INSERT INTO comment VALUES (8, 6, "2021-08-13", "can't go to Heaven if there is no Heaven", 5, "Angel_of_Death_9999");

INSERT INTO comment VALUES (9, 1, "2021-05-18", "Doing god's work", NULL, "Theseus");
INSERT INTO comment VALUES (9, 2, "2021-05-18", "thanks for reminder \:D", NULL, "qwerty");
INSERT INTO comment VALUES (9, 3, "2021-05-18", "water is a core ingredient for cookies", NULL, "cookie_destroyer");
INSERT INTO comment VALUES (9, 4, "2021-05-18", "fun fact: cows drink up a lot of water per day", NULL, "cow_lover94");
INSERT INTO comment VALUES (9, 5, "2021-05-18", "quality advice", NULL, "cookie_destroyer");
INSERT INTO comment VALUES (9, 6, "2021-05-18", "can't do drugs without water", NULL, "willsuit");
INSERT INTO comment VALUES (9, 7, "2021-05-18", "questionable", 6, "tomminute");

INSERT INTO comment VALUES (10, 1, "2021-08-10", "now do it backwards \:0", NULL, "qwerty");
INSERT INTO comment VALUES (10, 2, "2021-08-10", "ZYXEVUTSRQPONMLKJIHGFEDCBA", 1, "alphabet_king");
INSERT INTO comment VALUES (10, 3, "2021-08-11", "misspelled \"W\"", 2, "cookie_destroyer");
INSERT INTO comment VALUES (10, 4, "2021-08-11", "WXYZABCDEFGHIJKLMNOPQRSTUVWXYZ", 3, "alphabet_king");
INSERT INTO comment VALUES (10, 5, "2021-08-12", "Username checks out!", 4, "aquaman");

DELETE FROM chat_group;
INSERT INTO chat_group VALUES (1, "friends", "group of friends", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (2, "cow cult", "all shall become cows", "https://upload.wikimedia.org/wikipedia/commons/0/0c/Cow_female_black_white.jpg", "2020-12-28");
INSERT INTO chat_group VALUES (3, "myself", "", NULL, "2021-03-21");

DELETE FROM chat_group_moderators;
INSERT INTO chat_group_moderators VALUES (1, "willsuit");
INSERT INTO chat_group_moderators VALUES (2, "cow_lover94");
INSERT INTO chat_group_moderators VALUES (3, "cookie_destroyer");

DELETE FROM message;
INSERT INTO message VALUES (1, 1, "hi", "willsuit", NULL, "2021-03-21");
INSERT INTO message VALUES (1, 2, "why did you create a group chat with only the two of us Will", "tomminute", NULL, "2021-03-21");
INSERT INTO message VALUES (1, 3, "it's a group with all our friends, Tom", "willsuit", NULL, "2021-03-21");
INSERT INTO message VALUES (1, 4, "that's really insulting", "tomminute", NULL, "2021-03-21");
INSERT INTO message VALUES (1, 5, "did you just leave, Tom", "willsuit", NULL, "2021-03-21");
INSERT INTO message VALUES (1, 6, "come back", "willsuit", NULL, "2021-03-21");
INSERT INTO message VALUES (1, 7, "\:(", "willsuit", NULL, "2021-03-21");

INSERT INTO message VALUES (2, 1, "moo", "cow_lover94", NULL, "2020-12-28");
INSERT INTO message VALUES (2, 2, "moo!", "Theseus", NULL, "2020-12-28");
INSERT INTO message VALUES (2, 3, "moo?", "qwerty", NULL, "2020-12-28");
INSERT INTO message VALUES (2, 4, "moo moo!", "cow_lover94", NULL, "2020-12-29");
INSERT INTO message VALUES (2, 5, "moo moo moo", "Theseus", NULL, "2020-12-29");
INSERT INTO message VALUES (2, 6, "why am i added", "aquaman", NULL, "2020-12-29");
INSERT INTO message VALUES (2, 7, "moo moo", "cow_lover94", NULL, "2020-12-29");
INSERT INTO message VALUES (2, 8, "uh oh", "aquaman", NULL, "2020-12-30");

INSERT INTO message VALUES (3, 1, ")\" OR 1=1; --", "cookie_destroyer", NULL, "2021-03-21");
INSERT INTO message VALUES (3, 2, ")' OR 1=1; --", "cookie_destroyer", NULL, "2021-03-21");
INSERT INTO message VALUES (3, 3, "rip sql injection doesn't work on this website", "cookie_destroyer", NULL, "2021-03-21");
INSERT INTO message VALUES (3, 4, "sadded", "cookie_destroyer", NULL, "2021-03-21");

DELETE FROM user_chat_info;
INSERT INTO user_chat_info VALUES ("willsuit", 1);
INSERT INTO user_chat_info VALUES ("tomminute", 1);
INSERT INTO user_chat_info VALUES ("cow_lover94", 2);
INSERT INTO user_chat_info VALUES ("Theseus", 2);
INSERT INTO user_chat_info VALUES ("qwerty", 2);
INSERT INTO user_chat_info VALUES ("aquaman", 2);
INSERT INTO user_chat_info VALUES ("cookie_destroyer", 3);

DELETE FROM follow;
INSERT INTO follow VALUES ("willsuit", "tomminute");
INSERT INTO follow VALUES ("tomminute", "willsuit");
INSERT INTO follow VALUES ("cow_lover94", "Theseus");
INSERT INTO follow VALUES ("cow_lover94", "qwerty");
INSERT INTO follow VALUES ("aquaman", "cow_lover94");
INSERT INTO follow VALUES ("big_dinosaur11", "cow_lover94");
INSERT INTO follow VALUES ("Theseus", "cow_lover94");
INSERT INTO follow VALUES ("qwerty", "cow_lover94");

DELETE FROM interest_group_moderators;
INSERT INTO interest_group_moderators VALUES ("Mine Art", "willsuit");
INSERT INTO interest_group_moderators VALUES ("Mine Art", "tomminute");
INSERT INTO interest_group_moderators VALUES ("Chess", "aquaman");
INSERT INTO interest_group_moderators VALUES ("Jokes", "qwerty");
INSERT INTO interest_group_moderators VALUES ("Music", "qwerty");
INSERT INTO interest_group_moderators VALUES ("Chatting", "cow_lover94");
INSERT INTO interest_group_moderators VALUES ("Advice", "aquaman");
INSERT INTO interest_group_moderators VALUES ("Giv", "hello");

DELETE FROM interest_group_participants;
INSERT INTO interest_group_participants VALUES ("Mine Art", "willsuit");
INSERT INTO interest_group_participants VALUES ("Mine Art", "tomminute");
INSERT INTO interest_group_participants VALUES ("Mine Art", "qwerty");
INSERT INTO interest_group_participants VALUES ("Mine Art", "aquaman");

INSERT INTO interest_group_participants VALUES ("Chess", "aquaman");

INSERT INTO interest_group_participants VALUES ("Jokes", "qwerty");
INSERT INTO interest_group_participants VALUES ("Jokes", "willsuit");
INSERT INTO interest_group_participants VALUES ("Jokes", "tomminute");
INSERT INTO interest_group_participants VALUES ("Jokes", "cow_lover94");
INSERT INTO interest_group_participants VALUES ("Jokes", "big_dinosaur11");
INSERT INTO interest_group_participants VALUES ("Jokes", "Theseus");
INSERT INTO interest_group_participants VALUES ("Jokes", "cookie_destroyer");
INSERT INTO interest_group_participants VALUES ("Jokes", "alphabet_king");

INSERT INTO interest_group_participants VALUES ("Music", "qwerty");
INSERT INTO interest_group_participants VALUES ("Music", "cookie_destroyer");

INSERT INTO interest_group_participants VALUES ("Chatting", "qwerty");
INSERT INTO interest_group_participants VALUES ("Chatting", "willsuit");
INSERT INTO interest_group_participants VALUES ("Chatting", "tomminute");
INSERT INTO interest_group_participants VALUES ("Chatting", "cow_lover94");
INSERT INTO interest_group_participants VALUES ("Chatting", "big_dinosaur11");
INSERT INTO interest_group_participants VALUES ("Chatting", "Theseus");
INSERT INTO interest_group_participants VALUES ("Chatting", "cookie_destroyer");
INSERT INTO interest_group_participants VALUES ("Chatting", "alphabet_king");
INSERT INTO interest_group_participants VALUES ("Chatting", "aquaman");

INSERT INTO interest_group_participants VALUES ("Advice", "qwerty");
INSERT INTO interest_group_participants VALUES ("Advice", "willsuit");
INSERT INTO interest_group_participants VALUES ("Advice", "tomminute");
INSERT INTO interest_group_participants VALUES ("Advice", "cow_lover94");
INSERT INTO interest_group_participants VALUES ("Advice", "big_dinosaur11");
INSERT INTO interest_group_participants VALUES ("Advice", "Theseus");
INSERT INTO interest_group_participants VALUES ("Advice", "cookie_destroyer");
INSERT INTO interest_group_participants VALUES ("Advice", "alphabet_king");
INSERT INTO interest_group_participants VALUES ("Advice", "aquaman");

INSERT INTO interest_group_participants VALUES ("Giv", "hello");

