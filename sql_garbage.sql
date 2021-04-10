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

CREATE TRIGGER removeChatGroup AFTER DELETE ON user_chat_info
FOR EACH ROW
    BEGIN
        -- SELECT @member_number := count(*) FROM user_chat_info WHERE user_chat_info.username <> "admin" AND user_chat_info.chat_group_id = old.chat_group_id;
        DECLARE member_number int;
        SELECT count(*) INTO member_number FROM user_chat_info WHERE user_chat_info.username <> "admin" AND user_chat_info.chat_group_id = old.chat_group_id;
        IF (member_number = 0) THEN
            DELETE FROM chat_group WHERE chat_group_id = old.chat_group_id;
        END IF;
    END;//

CREATE TRIGGER removeFromModeratorWhenRemovedChat AFTER DELETE ON user_chat_info
FOR EACH ROW
    BEGIN
        DELETE FROM chat_group_moderators WHERE chat_group_moderators.username = old.username AND chat_group_moderators.chat_group_id = old.chat_group_id;
    END;//

CREATE TRIGGER removeFromModeratorWhenRemovedIG AFTER DELETE ON interest_group_participants
FOR EACH ROW
    BEGIN
        DELETE FROM interest_group_moderators WHERE interest_group_moderators.username = old.username AND interest_group_moderators.interest_group = old.interest_group;
    END;//

CREATE TRIGGER insertAdminIntoChat AFTER INSERT ON chat_group
FOR EACH ROW
    BEGIN
        INSERT IGNORE INTO user_chat_info (username, chat_group_id) VALUES ("admin", new.chat_group_id);
        INSERT IGNORE INTO chat_group_moderators(username, chat_group_id) VALUES ("admin", new.chat_group_id);
    END;//

CREATE TRIGGER insertAdminIntoInterestGroup AFTER INSERT ON interest_group
FOR EACH ROW
    BEGIN
        INSERT INTO interest_group_participants(username, interest_group) VALUES ("admin", new.name);
        INSERT INTO interest_group_moderators(username, interest_group) VALUES ("admin", new.name);
    END;//
DELIMITER ;

 -- DELETE FROM user;
INSERT INTO user VALUES ("admin", "c3Ryb25nZXN0IHBhc3N3b3Jk", "h1610060@nushigh.edu.sg", "2003-06-23", "Singapore", 0);
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
INSERT INTO user VALUES ("P1ZzA", "hawaiian", "pizza@pizza.pizza", "1998-03-01", "Chad", 0);
INSERT INTO user VALUES ("seedyguy", "cashews", "seed@guy.com", "1987-02-10", "France", 0);
INSERT INTO user VALUES ("RedLavender", "bluesky", "red@test.com", "2016-08-12", "Burkina Faso", 0);
INSERT INTO user VALUES ("nether_dragon", "rawr", "dragon@test.com", "2019-05-07", "Nigeria", 0);
INSERT INTO user VALUES ("symphony", "aria", "aria@symphony.com", "2003-07-17", "Singapore", 0);
INSERT INTO user VALUES ("ouroboros", "eternal_snek", "hello@world.com", "2003-06-23", "Singapore", 0);

 -- DELETE FROM interest_group;
INSERT INTO interest_group VALUES ("Mine Art", "The best mining simulator game!", "2009-05-17");
INSERT INTO interest_group VALUES ("Chess", "An intellectually stimulating strategy game.", "0613-10-15");
INSERT INTO interest_group VALUES ("Jokes", "A very funny place to be.", "2020-05-24");
INSERT INTO interest_group VALUES ("Music", "La la la", "2021-03-15");
INSERT INTO interest_group VALUES ("Chatting", "Friendly interest group <3!", "2020-07-25");
INSERT INTO interest_group VALUES ("Advice", "Give advice to other people who need help!", "2020-10-15");
INSERT INTO interest_group VALUES ("Giv", "Post anything related to the popular social media Giv!", "2021-03-21");
INSERT INTO interest_group VALUES ("Stories", "For writers wishing to try their hand at telling stories~", "2021-04-10");
INSERT INTO interest_group VALUES ("News", "Get up to date with world happenings!", "1998-06-06");
INSERT INTO interest_group VALUES ("Food", "For all the foodies of the world.", "1992-05-26");
INSERT INTO interest_group VALUES ("Art", "The world would never be the same without art.", "1992-05-26");
INSERT INTO interest_group VALUES ("Math", "Mathemagic", "0000-01-01");
INSERT INTO interest_group VALUES ("Science", "From ashes to ashes, from black holes to atoms", "1999-02-01");
INSERT INTO interest_group VALUES ("Books", "Talk about your favourite books here!", "2003-07-01");
INSERT INTO interest_group VALUES ("Movies", "Blockbuster films!", "2016-10-13");
INSERT INTO interest_group VALUES ("Mine Art II", "The sequel to the best mining simulator game!", "2013-04-29");
INSERT INTO interest_group VALUES ("Birds", "Cute avian appreciators!", "1982-07-08");
INSERT INTO interest_group VALUES ("Announcements", "Important announcement regarding the social media Giv.", "2021-04-11");
INSERT INTO interest_group VALUES ("Programming", "while(true){eat(); sleep();}", "1949-03-13");
INSERT INTO interest_group VALUES ("Puzzles", "For brilliant young minds!", "1767-12-06");

 -- DELETE FROM post;
INSERT INTO post VALUES (1, "2014-12-15 14:31:56", "POG2020", "pog", 1200, 200, "willsuit");
INSERT INTO post VALUES (2, "2020-03-28 07:50:37", "The new update is coming out!", "It drops in one week, folks!", 1200, 200, "willsuit");
INSERT INTO post VALUES (3, "2010-10-22 02:12:42", "Best game ever!\", "I've been playing this game for 11 years, and I still love it", 355, 342, "P1ZzA")
INSERT INTO post VALUES (4, "2016-04-29 09:29:24", "How to get started?", "I just bought the game, and I'm not sure how to play it...", 945, 686, "tee_sword")
INSERT INTO post VALUES (5, "2016-04-30 06:38:52", "Anyone up for a challenge?", "I just beat the game and got first place for the PvP world competition", 903, 543, "tee_sword")
INSERT INTO post VALUES (6, "2012-02-18 24:03:50", "Lost one week of progress...", "Just got slain by an undead kid. I am never playing this game again :(", 898, 811, "P1ZzA")

INSERT INTO post VALUES (7, "2020-12-28 15:34:41", "Moooooooooooo", "mooooooooooooooo", 3729, 1226, "cow_lover94")
INSERT INTO post VALUES (8, "2021-01-16 20:48:25", "Athens is the best place", NULL, 70, 69, "Theseus");
INSERT INTO post VALUES (9, "2021-10-10 14:24:36", "Bought a new keyboard today \:D", NULL, 96, 3, "qwerty");
INSERT INTO post VALUES (10, "2021-02-22 11:32:15", "I think I'm extinct...", NULL, 649, 248, "big_dinosaur11");
INSERT INTO post VALUES (11, "2021-08-10 17:30:20", "ABCDEFEGHIJKLMNOPQRSTUVWXYZ", NULL, 679, 275, "alphabet_king");
INSERT INTO post VALUES (21, "2021-06-23 21:55:30", "I just bought my first bag of chips", "I can't believe I've never tried them before", 3314, 2083, "CrispyChips");
INSERT INTO post VALUES (22, "2020-04-22 07:52:47", "I just beat the final boss of Dragon Knight!", "I've spent sixty hours on this game, genuinely a masterpiece. Goodbye, Dragon Knight", 8125, 4021, "nether_dragon")
INSERT INTO post VALUES (23, "2020-04-04 12:40:50", "Does anyone else like plants?", "i spend so long just staring at trees all day...", 841, 585, "seedyguy")
INSERT INTO post VALUES (24, "2021-07-17 10:58:33", "I like someone, how do I tell them?", "please help i need help", 808, 735, "ouroboros")
INSERT INTO post VALUES (25, "2021-10-23 13:15:30", "Bored...", "Does anyone want to start a conversation? We can just talk about anything", 74, 23, "hello")

INSERT INTO post VALUES (12, "2020-05-04 16:13:55", "Hell > Heaven", "title", 231, -84, "Angel_of_Death_9999");
INSERT INTO post VALUES (13, "2020-06-14 04:31:56", "What did one programmer say to the other?", "You're cyber boolean me", 946, 857, "P1ZzA");
INSERT INTO post VALUES (14, "2020-05-25 14:47:22", "I was reading a book about an immortal dinosaur.", "It was impossible to put down.", 426, 178, "big_dinosaur11");
INSERT INTO post VALUES (15, "2020-11-15 09:52:05", "A proton walked into a bar...", "and decided to walk back out because it was positive", 843, 137, "big_dinosaur11");

INSERT INTO post VALUES (16, "2021-08-19 23:55:34", "Cookie Monster!", "My new album, please listen to it!", 350, 61, "cookie_destroyer");
INSERT INTO post VALUES (17, "2021-12-07 05:23:20", "Check out this new song!", "I Recognize You by Melody Knight", 348, 217, "RedLavender");
INSERT INTO post VALUES (18, "2021-10-29 10:46:50", "I need inspiration...", "composing a song is hard", 937, 280, "nether_dragon");
INSERT INTO post VALUES (19, "2021-12-27 03:22:57", "music is life", "without music life would be boring", 747, 213, "qwerty");
INSERT INTO post VALUES (20, "2021-01-04 13:37:08", "Where can I find good songs?", "I want to listen to good songs while swimming, but I don't know where to find them...", 512, 313, "aquaman");

INSERT INTO post VALUES (7, "2021-03-21", "Hello World!", NULL, 1, 1, "hello");

INSERT INTO post VALUES (10, "2021-05-18 23:53:00", "Stay hydrated, folks!", NULL, 9313, 8313, "aquaman");
INSERT INTO post VALUES (26, "2020-01-05 20:07:39", "How do I resolve this error?", "Help I keep getting some error about my web cookies not existing", 9576, 4585, "CrispyChips")
INSERT INTO post VALUES (27, "2020-01-16 10:49:46", "How do you plan your space more efficiently?", "I am having many space concerns in my house, I'm not really sure how to deal with this. I think I just have too many things", 32, 25, "Theseus")
INSERT INTO post VALUES (28, "2021-10-14 05:34:46", "I'm not sure how to deal with loneliness...", "I'm stuck in my home country and can't travel due to government restrictions, and I can't see my friends :(", 98, 57, "nether_dragon")
INSERT INTO post VALUES (29, "2020-06-14 24:23:19", "how to learn more skills?", "i want to get a better job, but i don't know where i can find places to learn more things", 8773, 6579, "qwerty")
INSERT INTO post VALUES (30, "2020-10-02 01:20:09", "If you ever feel sad, talk to somebody", "It's a small thing, but it really helps :)", 747, 641, "cow_lover94")

INSERT INTO post VALUES (31, "2021-04-10 17:25:26", "Giv official release tomorrow!", "Finally, giv is being released officially tomorrow! Stay tuned, folks!", 23, 15, "admin")
INSERT INTO post VALUES (32, "2021-04-10 11:11:15", "giv's changelog!", "To look through giv's changelog, you can visit our official github page :D", 2, 1, "admin")

INSERT INTO post VALUES (33, "2021-03-01 20:33:48", "Once upon a time...", "There was a prince. The prince was really nice. He would help anyone he met. Unfortunately, one day he met an evil man. Oh no! The email man was drowning, but the prince could not let him be. He jumped into the water and saved this evil man. The evil man recognized him, and cast a spell on him, causing him to fall asleep. Only those of the purest heart could save him! A princess came along and saved him though, so it became a win-win scenario. Without the evil man he would never have met his true love. The end.", 48, 40, "CrispyChips")
INSERT INTO post VALUES (34, "2020-02-22 19:26:45", "So, there was an apple.", "The mystical apple loved conversations. But it did not like Orange. So, when Apple met Orange, he would intentionally exclude Orange from conversations. But Orange never understood why. The poor thing! Orange eventually decided to confront Apple, who revealed he did not like Orange because Orange always spent time with Banana. It turns out Apple liked Banana and was jealous! However, Apple apologized for his behaviour towards Orange, who also made up with Apple. Eventually, the three of them became best friends. The end!", 1, 0, "cow_lover94")
INSERT INTO post VALUES (35, "2021-04-10 17:36:43", "A student was doing his CS Project...", "He spent so long on it. He was doing it for so long, he started to resent his computer. Every time he sat down and closed his eyes, all he could see was characters, SQL SELECT statements, poorly-formatted HTML code swimming before his eyes. He wanted to give up all the time, but he could not. For the deadline drew ever closer. It didn't help that he had work from other subjects to complete too. He worked day and night, day and night. The hours ticked by. He spent so long in his room, his parents started to worry something was wrong. Finally, when it seemed all hope was lost, he finally managed to finish it on the last minute on the final day. But just as he was about to submit it, the most tragic event imaginable happeEveryone was trying to submit their own project at the same time! Microsoft Teams was down, and the student was in despair as his work would never be completed.", 1, 0, "ouroboros")

 -- DELETE FROM posting_info;
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

 -- DELETE FROM comment;
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

 -- DELETE FROM chat_group;
INSERT INTO chat_group VALUES (1, "friends", "group of friends", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (2, "cow cult", "all shall become cows", "https://upload.wikimedia.org/wikipedia/commons/0/0c/Cow_female_black_white.jpg", "2020-12-28");
INSERT INTO chat_group VALUES (3, "myself", "", NULL, "2021-03-21");

 -- DELETE FROM chat_group_moderators;
INSERT INTO chat_group_moderators VALUES (1, "willsuit");
INSERT INTO chat_group_moderators VALUES (2, "cow_lover94");
INSERT INTO chat_group_moderators VALUES (3, "cookie_destroyer");

 -- DELETE FROM message;
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

 -- DELETE FROM user_chat_info;
INSERT INTO user_chat_info VALUES ("willsuit", 1);
INSERT INTO user_chat_info VALUES ("tomminute", 1);
INSERT INTO user_chat_info VALUES ("cow_lover94", 2);
INSERT INTO user_chat_info VALUES ("Theseus", 2);
INSERT INTO user_chat_info VALUES ("qwerty", 2);
INSERT INTO user_chat_info VALUES ("aquaman", 2);
INSERT INTO user_chat_info VALUES ("cookie_destroyer", 3);

 -- DELETE FROM follow;
INSERT INTO follow VALUES ("willsuit", "tomminute");
INSERT INTO follow VALUES ("tomminute", "willsuit");
INSERT INTO follow VALUES ("cow_lover94", "Theseus");
INSERT INTO follow VALUES ("cow_lover94", "qwerty");
INSERT INTO follow VALUES ("aquaman", "cow_lover94");
INSERT INTO follow VALUES ("big_dinosaur11", "cow_lover94");
INSERT INTO follow VALUES ("Theseus", "cow_lover94");
INSERT INTO follow VALUES ("qwerty", "cow_lover94");

 -- DELETE FROM interest_group_moderators;
INSERT INTO interest_group_moderators VALUES ("Mine Art", "willsuit");
INSERT INTO interest_group_moderators VALUES ("Mine Art", "tomminute");
INSERT INTO interest_group_moderators VALUES ("Chess", "aquaman");
INSERT INTO interest_group_moderators VALUES ("Jokes", "qwerty");
INSERT INTO interest_group_moderators VALUES ("Music", "qwerty");
INSERT INTO interest_group_moderators VALUES ("Chatting", "cow_lover94");
INSERT INTO interest_group_moderators VALUES ("Advice", "aquaman");
INSERT INTO interest_group_moderators VALUES ("Giv", "hello");

 -- DELETE FROM interest_group_participants;
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

