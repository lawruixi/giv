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
    content varchar(10000),
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
    PRIMARY KEY (post_id, interest_group),
    FOREIGN KEY (post_id) REFERENCES post(post_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (interest_group) REFERENCES interest_group(name) ON DELETE CASCADE ON UPDATE CASCADE
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
INSERT INTO post VALUES (3, "2010-10-22 02:12:42", "Best game ever!", "I've been playing this game for 11 years, and I still love it", 355, 342, "P1ZzA");
INSERT INTO post VALUES (4, "2016-04-29 09:29:24", "How to get started?", "I just bought the game, and I'm not sure how to play it...", 945, 686, "tee_sword");
INSERT INTO post VALUES (5, "2016-04-30 06:38:52", "Anyone up for a challenge?", "I just beat the game and got first place for the PvP world competition", 903, 543, "tee_sword");
INSERT INTO post VALUES (6, "2012-02-18 00:03:50", "Lost one week of progress...", "Just got slain by an undead kid. I am never playing this game again :(", 898, 811, "P1ZzA");

INSERT INTO post VALUES (7, "2020-12-28 15:34:41", "Moooooooooooo", "mooooooooooooooo", 3729, 1226, "cow_lover94");
INSERT INTO post VALUES (8, "2021-01-16 20:48:25", "Athens is the best place", NULL, 70, 69, "Theseus");
INSERT INTO post VALUES (9, "2021-10-10 14:24:36", "Bought a new keyboard today \:D", NULL, 96, 3, "qwerty");
INSERT INTO post VALUES (10, "2021-02-22 11:32:15", "I think I'm extinct...", NULL, 649, 248, "big_dinosaur11");
INSERT INTO post VALUES (11, "2021-08-10 17:30:20", "ABCDEFEGHIJKLMNOPQRSTUVWXYZ", NULL, 679, 275, "alphabet_king");
INSERT INTO post VALUES (21, "2021-06-23 21:55:30", "I just bought my first bag of chips", "I can't believe I've never tried them before", 3314, 2083, "CrispyChips");
INSERT INTO post VALUES (22, "2020-04-22 07:52:47", "I just beat the final boss of Dragon Knight!", "I've spent sixty hours on this game, genuinely a masterpiece. Goodbye, Dragon Knight", 8125, 4021, "nether_dragon");
INSERT INTO post VALUES (23, "2020-04-04 12:40:50", "Does anyone else like plants?", "i spend so long just staring at trees all day...", 841, 585, "seedyguy");
INSERT INTO post VALUES (24, "2021-07-17 10:58:33", "I like someone, how do I tell them?", "please help i need help", 808, 735, "ouroboros");
INSERT INTO post VALUES (25, "2021-10-23 13:15:30", "Bored...", "Does anyone want to start a conversation? We can just talk about anything", 74, 23, "hello");

INSERT INTO post VALUES (12, "2020-05-04 16:13:55", "Hell > Heaven", "title", 231, -84, "Angel_of_Death_9999");
INSERT INTO post VALUES (13, "2020-06-14 04:31:56", "What did one programmer say to the other?", "You're cyber boolean me", 946, 857, "P1ZzA");
INSERT INTO post VALUES (14, "2020-05-25 14:47:22", "I was reading a book about an immortal dinosaur.", "It was impossible to put down.", 426, 178, "big_dinosaur11");
INSERT INTO post VALUES (15, "2020-11-15 09:52:05", "A proton walked into a bar...", "and decided to walk back out because it was positive", 843, 137, "big_dinosaur11");

INSERT INTO post VALUES (16, "2021-08-19 23:55:34", "Cookie Monster!", "My new album, please listen to it!", 350, 61, "cookie_destroyer");
INSERT INTO post VALUES (17, "2021-12-07 05:23:20", "Check out this new song!", "I Recognize You by Melody Knight", 348, 217, "RedLavender");
INSERT INTO post VALUES (18, "2021-10-29 10:46:50", "I need inspiration...", "composing a song is hard", 937, 280, "nether_dragon");
INSERT INTO post VALUES (19, "2021-12-27 03:22:57", "music is life", "without music life would be boring", 747, 213, "qwerty");
INSERT INTO post VALUES (20, "2021-01-04 13:37:08", "Where can I find good songs?", "I want to listen to good songs while swimming, but I don't know where to find them...", 512, 313, "aquaman");

INSERT INTO post VALUES (38, "2021-05-18 23:53:00", "Stay hydrated, folks!", NULL, 9313, 8313, "aquaman");
INSERT INTO post VALUES (26, "2020-01-05 20:07:39", "How do I resolve this error?", "Help I keep getting some error about my web cookies not existing", 9576, 4585, "CrispyChips");
INSERT INTO post VALUES (27, "2020-01-16 10:49:46", "How do you plan your space more efficiently?", "I am having many space concerns in my house, I'm not really sure how to deal with this. I think I just have too many things", 32, 25, "Theseus");
INSERT INTO post VALUES (28, "2021-10-14 05:34:46", "I'm not sure how to deal with loneliness...", "I'm stuck in my home country and can't travel due to government restrictions, and I can't see my friends :(", 98, 57, "nether_dragon");
INSERT INTO post VALUES (29, "2020-06-14 00:23:19", "how to learn more skills?", "i want to get a better job, but i don't know where i can find places to learn more things", 8773, 6579, "qwerty");
INSERT INTO post VALUES (30, "2020-10-02 01:20:09", "If you ever feel sad, talk to somebody", "It's a small thing, but it really helps :)", 747, 641, "cow_lover94");

INSERT INTO post VALUES (31, "2021-04-10 17:25:26", "Giv official release tomorrow!", "Finally, giv is being released officially tomorrow! Stay tuned, folks!", 23, 15, "admin");
INSERT INTO post VALUES (32, "2021-04-10 11:11:15", "giv's changelog!", "To look through giv's changelog, you can visit our official github page \:D", 2, 1, "admin");

INSERT INTO post VALUES (33, "2021-03-01 20:33:48", "Once upon a time...", "There was a prince. The prince was really nice. He would help anyone he met. Unfortunately, one day he met an evil man. Oh no! The email man was drowning, but the prince could not let him be. He jumped into the water and saved this evil man. The evil man recognized him, and cast a spell on him, causing him to fall asleep. Only those of the purest heart could save him! A princess came along and saved him though, so it became a win-win scenario. Without the evil man he would never have met his true love. The end.", 48, 40, "CrispyChips");
INSERT INTO post VALUES (34, "2020-02-22 19:26:45", "So, there was an apple.", "The mystical apple loved conversations. But it did not like Orange. So, when Apple met Orange, he would intentionally exclude Orange from conversations. But Orange never understood why. The poor thing! Orange eventually decided to confront Apple, who revealed he did not like Orange because Orange always spent time with Banana. It turns out Apple liked Banana and was jealous! However, Apple apologized for his behaviour towards Orange, who also made up with Apple. Eventually, the three of them became best friends. The end!", 1, 0, "cow_lover94");
INSERT INTO post VALUES (35, "2021-04-10 17:36:43", "A student was doing his CS Project...", "He spent so long on it. He was doing it for so long, he started to resent his computer. Every time he sat down and closed his eyes, all he could see was characters, SQL SELECT statements, poorly-formatted HTML code swimming before his eyes. He wanted to give up all the time, but he could not. For the deadline drew ever closer. It didn't help that he had work from other subjects to complete too. He worked day and night, day and night. The hours ticked by. He spent so long in his room, his parents started to worry something was wrong. Finally, when it seemed all hope was lost, he finally managed to finish it on the last minute on the final day. But just as he was about to submit it, the most tragic event imaginable happened. Everyone was trying to submit their own project at the same time! Microsoft Teams was down, and the student was in despair as his work would never be completed.", 1, 0, "ouroboros");
INSERT INTO post VALUES (36, "2020-05-02 00:47:01", "Three-word Prompt: Stove, Bag, Brother", "One day, there were two brothers. Their father was a rich and wealthy man, and possessed many different antique and magical items. Among one of these items was a bag. This bag, however, was no normal bag, because this bag could summon a stove at will. All one had to do was to reach into the bag, and they could pull out a magical stove! Needless to say, this bag was a highly coveted item amongst adventurers. Unfortunately, this rich and wealthy father died, and the two brothers had a fierce argument to decide who kept the bag. They decided to have a competition to see who was worthy of the bag, and the rules worked like this: they each had to reach into the bag, pick up the stove, and carry it as far as they possibly could. The one who could bring the stove as far away as possible won the competition. The first brother took his old, trusty car, and drove away with the stove in the back of the car. Unfortunately, the car broke down soon afterwards, since, as it turns out, it's not very healthy for your car to have a massive stove sitting at the back. The second brother then decided to bring a camel. As he rode the camel across the desert, he thought he would win, as camels were generally very strong. However, it proved not to be the case, as the stove was too heavy for even the camel to carry. And that is the story of the stove that broke the camel's back.", 10506, 8304, "cookie_destroyer");

INSERT INTO post VALUES (37, "2020-07-30 03:24:58", "World will be destroyed by climate change by 2050", "sad", 2, 1, "Angel_of_Death_9999");
INSERT INTO post VALUES (39, "2021-03-10 07:18:01", "Iron deficiency leads to many heart problems, doctors find in new study", "As if that wasn't obvious lol", 69, 46, "ouroboros");
INSERT INTO post VALUES (40, "2021-03-25 23:10:35", "Leaders of tomorrow should ensure the world is not doom and gloom", "\"We're just doing our job\", president of ASU, the world's leading nation, says in press conference.", 3, 2, "CrispyChips");
INSERT INTO post VALUES (41, "2021-07-29 00:36:39", "hilarious meme leaves many contracting laughing disease", "\"I can't stop laughing,\" says a man we interviewed, while bursting into giggles. The authorities heavily advise the public against viewing this hilarious meme.", 6331, 5001, "seedyguy");

INSERT INTO post VALUES (42, "2021-07-26 10:54:42", "New Ice with Cream at Dan and Jarry's!", "It tastes not bad actually... slurp!", 3, 1, "big_dinosaur11");
INSERT INTO post VALUES (43, "2021-01-15 04:52:58", "Making my own pizzeria!", "Anyone's free to stop by \:D", 4, 2, "P1ZzA");
INSERT INTO post VALUES (44, "2021-03-23 16:29:19", "ghost salt", "many seem to like ghost pepper, and now I hereby present my ghost salt!", 0, 0, "seedyguy");
INSERT INTO post VALUES (45, "2020-07-28 09:52:00", "Too tough to swallow?", "I always wanted to try eating bread, but it's so hard I can't swallow it!", 8, 6, "aquaman");

INSERT INTO post VALUES (46, "2020-08-13 09:34:54", "my new masterpiece!", "please rate it please \:D", 127, 41, "qwerty");
INSERT INTO post VALUES (47, "2021-07-22 11:12:15", "Trying out new brush techniques...", "It turns out hard brushes aren't useless; they can be used for brushing aggressively!", 6, 4, "P1ZzA");
INSERT INTO post VALUES (48, "2020-05-11 20:01:01", "Any art majors?", "Thinking of whether I should apply for Art degree...", 9083, 7902, "RedLavender");

INSERT INTO post VALUES (49, "2020-12-06 20:36:15", "Pythagorean triplet hunting", "How do you find Pythagorean triplets? Are there any which contain the number 100?", 1, 0, "nether_dragon");
INSERT INTO post VALUES (50, "2020-11-06 20:18:50", "help with algebra", "why can you treat the equation the same way on both sides?? i dont understand", 8, 4, "tee_sword");
INSERT INTO post VALUES (51, "2021-08-21 00:24:51", "The 1089 trick!", "Pick any three digit number ABCDEFGH. Now reverse ABCDEFGH and subtract the smaller from the bigger. Call this IJKLMNOP. If IJKLMNOP is less than 100, put a zero in front. Now reverse IJKLMNOP and add them up. You will get 1089!", 11, 7, "alphabet_king");
INSERT INTO post VALUES (52, "2020-09-10 21:26:54", "Statistically improbable?", "How much is statistically improbable? Is one in 7.5 trillion too unlikely to happen, or is it possible?", 968, 745, "nether_dragon");
INSERT INTO post VALUES (53, "2021-12-01 06:07:34", "For loop in math?", "How do you do a for loop in math? Is there such a thing?", 5, 3, "big_dinosaur11");

INSERT INTO post VALUES (54, "2021-06-12 19:05:05", "Dark hydrogen is so cool!", "A version of hydrogen which cannot be seen... could this have relation to dark matter?", 8, 4, "seedyguy");
INSERT INTO post VALUES (55, "2020-02-06 03:50:00", "Endothermic reactions?", "How do they happen, given they have to suck heat from the surroundings to do it?", 3, 1, "alphabet_king");
INSERT INTO post VALUES (56, "2021-10-03 20:13:26", "Relativistic mechanics", "Why does time slow down? Very weird", 37, 29, "symphony");
INSERT INTO post VALUES (57, "2021-12-03 01:12:18", "Artifical hearts can now be implanted into people!", "You can have double the heart diseases now!", 3, 2, "Angel_of_Death_9999");
INSERT INTO post VALUES (58, "2020-12-01 05:11:48", "Is zero kelvin attainable?", "The absolute cold", 6, 4, "RedLavender");

INSERT INTO post VALUES (59, "2021-12-15 17:59:44", "The Ring of the Lords", "Just read this epic fantasy novel, you guys should really check it out!", 42, 28, "CrispyChips");
INSERT INTO post VALUES (60, "2020-02-11 19:48:29", "You, Human", "A sci-fi book about AI and their evil creation", 6435, 5662, "ouroboros");
INSERT INTO post VALUES (61, "2021-12-01 00:17:20", "Larry Gardener series", "About a gardener who discovers he has magic powers and has to defeat his archnemesis Moldywart", 85, 69, "aquaman");
INSERT INTO post VALUES (62, "2020-12-28 21:35:38", "Midday", "A romance novel about... romance", 96, 66, "willsuit");
INSERT INTO post VALUES (63, "2020-06-02 13:13:00", "The Selfish Jeans", "About a pair of pants who decide they want more than just to be worn", 8, 5, "hello");

INSERT INTO post VALUES (64, "2020-06-22 11:59:23", "Star Skirmishes", "Fantastic movie series every person should enjoy", 9815, 7263, "qwerty");
INSERT INTO post VALUES (65, "2021-04-16 11:39:00", "Thawed", "An animation about two sisters who are princesses and try to reverse an icy spell on their hometown", 19, 15, "cookie_destroyer");
INSERT INTO post VALUES (66, "2021-05-14 07:17:47", "My Name", "touching anime about two people who forget their identities", 10, 6, "RedLavender");
INSERT INTO post VALUES (67, "2021-11-11 08:56:09", "Arachne-Kid", "about a kid who gets bitten by radioactive alien spiders and gains all their superpowers", 0, 0, "CrispyChips");
INSERT INTO post VALUES (68, "2021-02-15 22:18:59", "Middle of Yesterday", "about time travel, back to the middle of yesterday, in an epic war against aliens", 3, 2, "symphony");

INSERT INTO post VALUES (69, "2020-04-23 13:06:40", "Mine Art II released!", "For everyone waiting for the release of the sequel, it's finally out!", 2, 1, "tee_sword");
INSERT INTO post VALUES (70, "2021-05-29 19:28:00", "Upgrade pickaxe", "How expensive is it to upgrade your pickaxe in this game?", 7, 4, "tomminute");
INSERT INTO post VALUES (71, "2020-05-12 23:06:44", "Pets", "Mining pets are so overpowered! I love them <3", 7181, 5672, "CrispyChips");
INSERT INTO post VALUES (72, "2021-09-21 05:59:42", "Mine Art II's graphics are surreal!", "It's almost like it's a different game from Mine Art I!", 9, 8, "Angel_of_Death_9999");
INSERT INTO post VALUES (73, "2021-12-22 07:42:24", "Does anyone else hate Mine Art's unrealistic physics?", "Glad they removed these issues in the sequel \:D", 8, 6, "CrispyChips");

INSERT INTO post VALUES (74, "2020-01-05 09:04:03", "rare yellow bird", "found one when walking in my nearby park this morning lol", 7570, 6434, "qwerty");
INSERT INTO post VALUES (75, "2020-12-23 10:54:57", "birbs", "flying birb", 6, 4, "symphony");
INSERT INTO post VALUES (76, "2020-09-04 13:31:26", "bird watching", "where are good places to birdwatch?", 5, 3, "ouroboros");
INSERT INTO post VALUES (77, "2020-10-31 20:41:05", "Bird Seeds", "Where can I buy high-quality bird seeds?", 4, 3, "seedyguy");

INSERT INTO post VALUES (78, "2021-04-11 00:00:00", "Giv is finally released! Have fun folks!", NULL, 67, 55, "admin");

INSERT INTO post VALUES (79, "2020-03-12 15:04:47", "I can't read my own code...", "i literally wrote it last night", 3, 2, "Theseus");
INSERT INTO post VALUES (80, "2021-09-11 04:25:21", "AI is just a bunch of if statements", "fight me", 5, 3, "nether_dragon");
INSERT INTO post VALUES (81, "2021-05-15 19:23:42", "flask is the most annoying thing ever", "like seriously. dont even get me started on sql", 2786, 2340, "ouroboros");
INSERT INTO post VALUES (82, "2021-04-08 12:39:35", "Why does the word graph have two different meanings??", "I can never remember if I'm on the Programming Interest Group or the Math Interest Group", 555, 333, "RedLavender");
INSERT INTO post VALUES (83, "2021-10-19 19:52:38", "so giv is immune to sql injection...", "shame, since it's made by literally a high school kid. dude knows his stuff.", 5, 3, "cookie_destroyer");

INSERT INTO post VALUES (84, "2020-03-27 04:04:43", "What is 1 + 1?", "The answer will surprise you!", 2, 1, "alphabet_king");
INSERT INTO post VALUES (85, "2020-08-25 04:18:04", "Three kids remove their hats...", "and randomly swap them around. What's the chance of only two kids having their correct hat?", 743, 646, "aquaman");
INSERT INTO post VALUES (86, "2021-10-13 21:44:58", "A bacteria doubles in number every minute...", "If it fills a container in one hour, when does it fill half the container?", 5, 3, "alphabet_king");

 -- DELETE FROM posting_info;
INSERT INTO posting_info VALUES (1, "Mine Art");
INSERT INTO posting_info VALUES (2, "Mine Art");
INSERT INTO posting_info VALUES (3, "Mine Art");
INSERT INTO posting_info VALUES (4, "Mine Art");
INSERT INTO posting_info VALUES (5, "Mine Art");
INSERT INTO posting_info VALUES (6, "Mine Art");

INSERT INTO posting_info VALUES (7, "Chatting");
INSERT INTO posting_info VALUES (8, "Chatting");
INSERT INTO posting_info VALUES (9, "Chatting");
INSERT INTO posting_info VALUES (10, "Chatting");
INSERT INTO posting_info VALUES (11, "Chatting");
INSERT INTO posting_info VALUES (21, "Chatting");
INSERT INTO posting_info VALUES (22, "Chatting");
INSERT INTO posting_info VALUES (23, "Chatting");
INSERT INTO posting_info VALUES (24, "Chatting");
INSERT INTO posting_info VALUES (25, "Chatting");

INSERT INTO posting_info VALUES (10, "Advice");
INSERT INTO posting_info VALUES (24, "Advice");
INSERT INTO posting_info VALUES (38, "Advice");
INSERT INTO posting_info VALUES (26, "Advice");
INSERT INTO posting_info VALUES (27, "Advice");
INSERT INTO posting_info VALUES (28, "Advice");
INSERT INTO posting_info VALUES (29, "Advice");
INSERT INTO posting_info VALUES (30, "Advice");

INSERT INTO posting_info VALUES (12, "Jokes");
INSERT INTO posting_info VALUES (13, "Jokes");
INSERT INTO posting_info VALUES (14, "Jokes");
INSERT INTO posting_info VALUES (15, "Jokes");

INSERT INTO posting_info VALUES (16, "Music");
INSERT INTO posting_info VALUES (17, "Music");
INSERT INTO posting_info VALUES (18, "Music");
INSERT INTO posting_info VALUES (19, "Music");
INSERT INTO posting_info VALUES (20, "Music");

INSERT INTO posting_info VALUES (31, "Giv");
INSERT INTO posting_info VALUES (32, "Giv");

INSERT INTO posting_info VALUES (33, "Stories");
INSERT INTO posting_info VALUES (34, "Stories");
INSERT INTO posting_info VALUES (35, "Stories");

INSERT INTO posting_info VALUES (37, "News");
INSERT INTO posting_info VALUES (39, "News");
INSERT INTO posting_info VALUES (40, "News");
INSERT INTO posting_info VALUES (41, "News");

INSERT INTO posting_info VALUES (42, "Food");
INSERT INTO posting_info VALUES (43, "Food");
INSERT INTO posting_info VALUES (44, "Food");
INSERT INTO posting_info VALUES (45, "Food");

INSERT INTO posting_info VALUES (46, "Art");
INSERT INTO posting_info VALUES (47, "Art");
INSERT INTO posting_info VALUES (48, "Art");

INSERT INTO posting_info VALUES (49, "Math");
INSERT INTO posting_info VALUES (50, "Math");
INSERT INTO posting_info VALUES (51, "Math");
INSERT INTO posting_info VALUES (52, "Math");
INSERT INTO posting_info VALUES (53, "Math");

INSERT INTO posting_info VALUES (54, "Science");
INSERT INTO posting_info VALUES (55, "Science");
INSERT INTO posting_info VALUES (56, "Science");
INSERT INTO posting_info VALUES (57, "Science");
INSERT INTO posting_info VALUES (58, "Science");

INSERT INTO posting_info VALUES (59, "Books");
INSERT INTO posting_info VALUES (60, "Books");
INSERT INTO posting_info VALUES (61, "Books");
INSERT INTO posting_info VALUES (62, "Books");
INSERT INTO posting_info VALUES (63, "Books");

INSERT INTO posting_info VALUES (64, "Movies");
INSERT INTO posting_info VALUES (65, "Movies");
INSERT INTO posting_info VALUES (66, "Movies");
INSERT INTO posting_info VALUES (67, "Movies");
INSERT INTO posting_info VALUES (68, "Movies");

INSERT INTO posting_info VALUES (69, "Mine Art II");
INSERT INTO posting_info VALUES (70, "Mine Art II");
INSERT INTO posting_info VALUES (71, "Mine Art II");
INSERT INTO posting_info VALUES (72, "Mine Art II");
INSERT INTO posting_info VALUES (73, "Mine Art II");

INSERT INTO posting_info VALUES (74, "Birds");
INSERT INTO posting_info VALUES (75, "Birds");
INSERT INTO posting_info VALUES (76, "Birds");
INSERT INTO posting_info VALUES (77, "Birds");

INSERT INTO posting_info VALUES (78, "Announcements");

INSERT INTO posting_info VALUES (79, "Programming");
INSERT INTO posting_info VALUES (80, "Programming");
INSERT INTO posting_info VALUES (81, "Programming");
INSERT INTO posting_info VALUES (82, "Programming");
INSERT INTO posting_info VALUES (83, "Programming");

INSERT INTO posting_info VALUES (84, "Puzzles");
INSERT INTO posting_info VALUES (85, "Puzzles");
INSERT INTO posting_info VALUES (86, "Puzzles");

 -- DELETE FROM comment;
INSERT INTO comment VALUES (1, 1, "2020-09-09 07:47:52", "pog", NULL, "willsuit");
INSERT INTO comment VALUES (1, 2, "2020-09-09 07:47:52", "pog", 1, "tomminute");
INSERT INTO comment VALUES (1, 3, "2020-09-09 07:47:53", "pog", 2, "willsuit");
INSERT INTO comment VALUES (1, 4, "2020-09-09 07:47:53", "pog", 3, "tomminute");
INSERT INTO comment VALUES (1, 5, "2020-09-09 07:47:54", "pog", 4, "willsuit");

INSERT INTO comment VALUES (2, 1, "2020-11-22 10:43:01", "pog", NULL, "P1ZzA");
INSERT INTO comment VALUES (2, 2, "2020-11-22 10:43:01", "yes finally", NULL, "CrispyChips");
INSERT INTO comment VALUES (2, 3, "2020-11-22 10:43:01", "I've been waiting for this for so long!", NULL, "Angel_of_Death_9999");
INSERT INTO comment VALUES (2, 4, "2020-11-22 10:43:01", "it's finally here!!", NULL, "cow_lover94");
INSERT INTO comment VALUES (2, 5, "2020-11-22 10:43:01", "yay let's goooooo", NULL, "ouroboros");

INSERT INTO comment VALUES (3, 1, "2020-06-08 06:45:37", "I know, right?", NULL, "cow_lover94");
INSERT INTO comment VALUES (3, 2, "2020-06-08 06:45:38", "the amount of content in this game never ceases to amaze me", NULL, "qwerty");
INSERT INTO comment VALUES (3, 3, "2020-06-08 06:45:38", "infinite replayability right here", NULL, "big_dinosaur11");
INSERT INTO comment VALUES (3, 4, "2020-06-08 06:45:38", "The devs really outdid themselves!", NULL, "aquaman");

INSERT INTO comment VALUES (4, 1, "2021-06-17 11:18:12", "git gud", NULL, "tomminute");
INSERT INTO comment VALUES (4, 2, "2021-06-17 11:18:13", "Look up some tutorials online, I guess?", NULL, "nether_dragon");
INSERT INTO comment VALUES (4, 3, "2021-06-17 11:18:13", "okay when you first start, you need to gather some materials, then head underground and mine for stuff, good luck", NULL, "cookie_destroyer");

INSERT INTO comment VALUES (5, 1, "2021-09-13 23:58:27", "Didn't you just buy the game yesterday", NULL, "RedLavender");
INSERT INTO comment VALUES (5, 2, "2021-09-13 23:58:27", "man here is an absolute legend", 1, "Theseus");
INSERT INTO comment VALUES (5, 3, "2021-09-13 23:58:28", "Sorry I'm bad at PvP...", NULL, "aquaman");
INSERT INTO comment VALUES (5, 4, "2021-09-13 23:58:28", "q", NULL, "cow_lover94");

INSERT INTO comment VALUES (6, 1, "2020-11-27 19:09:11", "", NULL, "tee_sword");
INSERT INTO comment VALUES (6, 2, "2020-11-27 19:09:12", "F", NULL, "Theseus");
INSERT INTO comment VALUES (6, 3, "2020-11-27 19:09:12", "F", NULL, "willsuit");
INSERT INTO comment VALUES (6, 4, "2020-11-27 19:09:13", "F", NULL, "cookie_destroyer");
INSERT INTO comment VALUES (6, 5, "2020-11-27 19:09:13", "F", NULL, "ouroboros");
INSERT INTO comment VALUES (6, 6, "2020-11-27 19:09:14", "F", NULL, "symphony");
INSERT INTO comment VALUES (6, 7, "2020-11-27 19:09:14", "F", NULL, "RedLavender");

INSERT INTO comment VALUES (7, 1, "2020-12-28", "moo?", NULL, "Theseus");
INSERT INTO comment VALUES (7, 2, "2020-12-28", "moo!", 1, "cow_lover94");
INSERT INTO comment VALUES (7, 3, "2020-12-28", "moo moo", 2, "Theseus");
INSERT INTO comment VALUES (7, 4, "2020-12-28", "what is this thread rn", 3, "cookie_destroyer");
INSERT INTO comment VALUES (7, 5, "2020-12-29", "intelligent beings communicating \:O", 4, "qwerty");

INSERT INTO comment VALUES (7, 6, "2020-12-28", "Who are the other 93 cow lovers?", NULL, "aquaman");
INSERT INTO comment VALUES (7, 7, "2020-12-28", "moo moo", 6, "cow_lover94");
INSERT INTO comment VALUES (7, 8, "2020-12-29", "i think he's trying to get you to join his cult \:>", 7, "qwerty");
INSERT INTO comment VALUES (7, 9, "2020-12-29", "Uh oh", 8, "aquaman");

INSERT INTO comment VALUES (7, 10, "2020-12-28", "cows together strong", NULL, "big_dinosaur11");
INSERT INTO comment VALUES (7, 11, "2020-12-28", "reject modernity return to C O W", 10, "cow_lover94");
INSERT INTO comment VALUES (7, 12, "2020-12-29", "COWXYZABDEFGHIJKLMNPQRSTUV", 11, "alphabet_king");
INSERT INTO comment VALUES (7, 13, "2020-12-29", "Are you... okay?", 12, "aquaman");

INSERT INTO comment VALUES (9, 1, "2021-10-09", "Looks fantastic!", NULL, "aquaman");
INSERT INTO comment VALUES (9, 2, "2021-10-10", "how do you know? they didn't even post a picture o.O", 1, "qwerty");
INSERT INTO comment VALUES (9, 3, "2021-10-10", "Man just casually commented before the posting time", 2, "tomminute");
INSERT INTO comment VALUES (9, 4, "2021-10-10", "lol i didnt even notice", 3, "qwerty");
INSERT INTO comment VALUES (9, 5, "2021-10-10", "is it possible to learn this power", 4, "cookie_destroyer");

INSERT INTO comment VALUES (10, 1, "2021-02-22", "Go back to the afterlife whence you came...", NULL, "Angel_of_Death_9999");
INSERT INTO comment VALUES (10, 2, "2021-02-22", "go back to chrome whence you came", 1, "qwerty");
INSERT INTO comment VALUES (10, 3, "2021-02-22", "Ah yes, Chrome, my favourite mythological afterlife", 2, "Theseus");
INSERT INTO comment VALUES (10, 4, "2021-02-22", "I prefer Firefox myself!", 3, "aquaman");
INSERT INTO comment VALUES (10, 5, "2021-02-22", "why the hell are we talking about web browsers rn", 4, "cookie_destroyer");
INSERT INTO comment VALUES (10, 6, "2021-02-23", "See? Hell is the best place!", 5, "Angel_of_Death_9999");

INSERT INTO comment VALUES (11, 1, "2021-08-10", "now do it backwards \:0", NULL, "qwerty");
INSERT INTO comment VALUES (11, 2, "2021-08-10", "ZYXEVUTSRQPONMLKJIHGFEDCBA", 1, "alphabet_king");
INSERT INTO comment VALUES (11, 3, "2021-08-11", "misspelled \"W\"", 2, "cookie_destroyer");
INSERT INTO comment VALUES (11, 4, "2021-08-11", "WXYZABCDEFGHIJKLMNOPQRSTUVWXYZ", 3, "alphabet_king");
INSERT INTO comment VALUES (11, 5, "2021-08-12", "Username checks out!", 4, "aquaman");

INSERT INTO comment VALUES (21, 1, "2020-04-10 12:48:17", "must have been very crispy", NULL, "symphony");
INSERT INTO comment VALUES (21, 2, "2020-04-10 12:48:17", "username checks out", NULL, "tomminute");
INSERT INTO comment VALUES (21, 3, "2020-04-10 12:48:17", "Yeah, chips are really good!", NULL, "RedLavender");
INSERT INTO comment VALUES (21, 4, "2020-04-10 12:48:17", "what's your favourite flavour?", NULL, "nether_dragon");
INSERT INTO comment VALUES (21, 5, "2020-04-10 12:48:17", "it's sour cream and onion lol", 4, "CrispyChips");
INSERT INTO comment VALUES (21, 6, "2020-04-10 12:48:17", "yeah I love them :)))", NULL, "cookie_destroyer");

INSERT INTO comment VALUES (22, 1, "2020-02-05 11:10:45", "congrats! Dragon Knight is a masterpiece of a game", NULL, "seedyguy");
INSERT INTO comment VALUES (22, 2, "2020-02-05 11:10:45", "this was my childhood lol", NULL, "qwerty");
INSERT INTO comment VALUES (22, 3, "2020-02-05 11:10:45", "Only 60h? When I finished the game I was clocking in like 200", NULL, "nether_dragon");
INSERT INTO comment VALUES (22, 4, "2020-02-05 11:10:45", "I loved Dragon Knight!!", NULL, "aquaman");

INSERT INTO comment VALUES (23, 1, "2020-04-16 23:02:17", "yeah plants are nice", NULL, "alphabet_king");
INSERT INTO comment VALUES (23, 2, "2020-04-16 23:02:17", "I think it's just you...", NULL, "ouroboros");
INSERT INTO comment VALUES (23, 3, "2020-04-16 23:02:17", "nah they're cool", 2, "Angel_of_Death_9999");

INSERT INTO comment VALUES (24, 1, "2020-04-25 06:20:15", "just tell them lol", NULL, "big_dinosaur11");
INSERT INTO comment VALUES (24, 2, "2020-04-25 06:20:16", "It's worth a shot... you miss 100% of the shots you don't take, after all.", NULL, "aquaman");
INSERT INTO comment VALUES (24, 3, "2020-04-25 06:20:17", "wait until the right time, then tell them. curious to know how it goes!", 2, "qwerty");
INSERT INTO comment VALUES (24, 4, "2020-04-25 06:20:17", "i dont think there's any better time than today, it's their birthday today", 3, "ouroboros");
INSERT INTO comment VALUES (24, 5, "2020-04-25 06:20:18", "ohh, all the more you should do something nice for them today then!", 4, "qwerty");
INSERT INTO comment VALUES (24, 6, "2020-04-25 06:20:18", "yeah im planning to go eat lunch with them \:D", 5, "ouroboros");
INSERT INTO comment VALUES (24, 7, "2020-04-25 06:20:19", "all the best! keep us updated!", 6, "symphony");
INSERT INTO comment VALUES (24, 8, "2020-04-25 06:20:19", "good luck my man!", 6, "CrispyChips");

INSERT INTO comment VALUES (25, 1, "2020-04-30 18:03:26", "sure", NULL, "P1ZzA");
INSERT INTO comment VALUES (25, 2, "2020-04-30 18:03:26", "you can start a group chat with me i guess", NULL, "big_dinosaur11");
INSERT INTO comment VALUES (25, 3, "2020-04-30 18:03:26", "haha im socially awkward too :)", 2, "hello");

INSERT INTO comment VALUES (12, 1, "2021-08-13", "no u \:<", NULL, "qwerty");
INSERT INTO comment VALUES (12, 2, "2021-08-13", "bruh it's a joke", 1, "Angel_of_Death_9999");
INSERT INTO comment VALUES (12, 3, "2021-08-13", "oh lol", 2, "qwerty");

INSERT INTO comment VALUES (12, 4, "2021-08-13", "What do you mean there's only the underworld", NULL, "Theseus");
INSERT INTO comment VALUES (12, 5, "2021-08-13", "true", 4, "Angel_of_Death_9999");
INSERT INTO comment VALUES (12, 6, "2021-08-13", "can't go to Heaven if there is no Heaven", 5, "Angel_of_Death_9999");

INSERT INTO comment VALUES (13, 1, "2021-11-23 22:33:55", "that was a bad joke but i still laughed", NULL, "cookie_destroyer");
INSERT INTO comment VALUES (13, 2, "2021-11-23 22:33:55", "thanks for that lol", NULL, "nether_dragon");
INSERT INTO comment VALUES (13, 3, "2021-11-23 22:33:55", "no problem :)", NULL, "P1ZzA");

INSERT INTO comment VALUES (14, 1, "2020-05-17 09:39:19", "Oh, that's a new one.", NULL, "cookie_destroyer");
INSERT INTO comment VALUES (14, 2, "2020-05-17 09:39:19", "nice joke lol", NULL, "P1ZzA");

INSERT INTO comment VALUES (17, 1, "2021-03-04 12:41:02", "oh that's my favourite song!", NULL, "ouroboros");
INSERT INTO comment VALUES (17, 2, "2021-03-04 12:41:02", "Really like that one, upvote!", NULL, "symphony");
INSERT INTO comment VALUES (17, 3, "2021-03-04 12:41:02", "really nice and calming, i love it!", NULL, "qwerty");

INSERT INTO comment VALUES (18, 1, "2020-09-17 05:12:24", "can't wait to hear it!", NULL, "qwerty");
INSERT INTO comment VALUES (18, 2, "2020-09-17 05:12:24", "go out and look around i guess? i get some inspiration that way", NULL, "CrispyChips");

INSERT INTO comment VALUES (19, 1, "2021-04-01 09:48:13", "true", NULL, "hello");
INSERT INTO comment VALUES (19, 2, "2021-04-01 09:48:13", "true", NULL, "ouroboros");

INSERT INTO comment VALUES (20, 1, "2020-09-04 19:03:05", "I think the bigger question is how you listen to music while swimming in the first place", NULL, "CrispyChips");
INSERT INTO comment VALUES (20, 2, "2020-09-04 19:03:05", "Man be made of water", NULL, "nether_dragon");
INSERT INTO comment VALUES (20, 3, "2020-09-04 19:03:05", "I recommend Singing with the Seas", NULL, "cow_lover94");
INSERT INTO comment VALUES (20, 4, "2020-09-04 19:03:05", "ah yes good pick", NULL, "qwerty");

INSERT INTO comment VALUES (38, 1, "2021-05-18", "Doing god's work", NULL, "Theseus");
INSERT INTO comment VALUES (38, 2, "2021-05-18", "thanks for reminder \:D", NULL, "qwerty");
INSERT INTO comment VALUES (38, 3, "2021-05-18", "water is a core ingredient for cookies", NULL, "cookie_destroyer");
INSERT INTO comment VALUES (38, 4, "2021-05-18", "fun fact: cows drink up a lot of water per day", NULL, "cow_lover94");
INSERT INTO comment VALUES (38, 5, "2021-05-18", "quality advice", NULL, "cookie_destroyer");
INSERT INTO comment VALUES (38, 6, "2021-05-18", "can't do drugs without water", NULL, "willsuit");
INSERT INTO comment VALUES (38, 7, "2021-05-18", "questionable", 6, "tomminute");

INSERT INTO comment VALUES (26, 1, "2021-07-20 09:45:44", "cookie_destroyer", NULL, "Angel_of_Death_9999");
INSERT INTO comment VALUES (26, 2, "2021-07-20 09:45:44", "cookie_destroyer", NULL, "nether_dragon");
INSERT INTO comment VALUES (26, 3, "2021-07-20 09:45:44", "cookie_destroyer", NULL, "tee_sword");
INSERT INTO comment VALUES (26, 4, "2021-07-20 09:45:44", "?", NULL, "CrispyChips");

INSERT INTO comment VALUES (27, 1, "2020-08-01 22:46:16", "throw them away duhhhh", NULL, "tomminute");
INSERT INTO comment VALUES (27, 2, "2020-08-01 22:46:16", "clear them out", NULL, "P1ZzA");
INSERT INTO comment VALUES (27, 3, "2020-08-01 22:46:16", "get someone to clear them out for you?", NULL, "symphony");

INSERT INTO comment VALUES (28, 1, "2021-06-28 08:26:00", "rip", NULL, "Angel_of_Death_9999");
INSERT INTO comment VALUES (28, 2, "2021-06-28 08:26:00", "Get to know people around you? You can make more friends", NULL, "ouroboros");
INSERT INTO comment VALUES (28, 3, "2021-06-28 08:26:00", "distract yourself with hobbies i guess?", NULL, "CrispyChips");

INSERT INTO comment VALUES (29, 1, "2021-06-11 19:19:45", "edX", NULL, "big_dinosaur11");
INSERT INTO comment VALUES (29, 2, "2021-06-11 19:19:45", "online courses", NULL, "tomminute");
INSERT INTO comment VALUES (29, 3, "2021-06-11 19:19:45", "MySkillsFuture", NULL, "qwerty");
INSERT INTO comment VALUES (29, 4, "2021-06-11 19:19:45", "edX", NULL, "nether_dragon");

INSERT INTO comment VALUES (30, 1, "2020-08-20 09:47:13", "thank you!", NULL, "hello");
INSERT INTO comment VALUES (30, 2, "2020-08-20 09:47:13", "that's true, maybe I should get out more", NULL, "seedyguy");
INSERT INTO comment VALUES (30, 3, "2020-08-20 09:47:13", "lonely and depressed with no friends rn", NULL, "nether_dragon");
INSERT INTO comment VALUES (30, 4, "2020-08-20 09:47:13", "I can talk to you \:D", NULL, "cow_lover94");

INSERT INTO comment VALUES (32, 1, "2021-11-20 20:35:53", "where?", NULL, "qwerty");
INSERT INTO comment VALUES (32, 2, "2021-11-20 20:35:53", "it's private", NULL, "admin");
INSERT INTO comment VALUES (32, 3, "2021-11-20 20:35:53", "that kinda sucks", NULL, "RedLavender");

INSERT INTO comment VALUES (33, 1, "2020-01-04 00:56:15", "ah yes I too like the email man", NULL, "RedLavender");
INSERT INTO comment VALUES (33, 2, "2020-01-04 00:56:15", "the mailman, but electronic versiojn", 1, "Angel_of_Death_9999");
INSERT INTO comment VALUES (33, 3, "2020-01-04 00:56:15", "mail man 2: electric boogalo", 2, "big_dinosaur11");
INSERT INTO comment VALUES (33, 4, "2020-01-04 00:56:15", "this sounds like a children's book", NULL, "Angel_of_Death_9999");
INSERT INTO comment VALUES (33, 5, "2020-01-04 00:56:15", "it probably is", NULL, "RedLavender");

INSERT INTO comment VALUES (34, 1, "2020-12-22 04:00:11", "aww what a wholesome story", NULL, "ouroboros");
INSERT INTO comment VALUES (34, 2, "2020-12-22 04:00:11", "i really like this one :)", NULL, "qwerty");

INSERT INTO comment VALUES (35, 1, "2020-08-06 13:59:43", "why does this sound like it's based off a real story", NULL, "seedyguy");
INSERT INTO comment VALUES (35, 2, "2020-08-06 13:59:43", "is it?", NULL, "ouroboros");

INSERT INTO comment VALUES (36, 1, "2020-05-29 23:25:00", "this was the funniest thing I've seen today", NULL, "CrispyChips");
INSERT INTO comment VALUES (36, 2, "2020-05-29 23:25:00", "thank you for this story", NULL, "Theseus");
INSERT INTO comment VALUES (36, 3, "2020-05-29 23:25:00", "I really liked this one lol", NULL, "ouroboros");

INSERT INTO comment VALUES (37, 1, "2020-04-04 18:45:52", "aww, but I like the world", NULL, "RedLavender");
INSERT INTO comment VALUES (37, 2, "2020-04-04 18:45:52", "rip climate change", NULL, "qwerty");

INSERT INTO comment VALUES (39, 1, "2021-01-23 02:18:43", "who'd have guessed", NULL, "nether_dragon");
INSERT INTO comment VALUES (39, 2, "2021-01-23 02:18:43", "eat your meat kids", NULL, "Angel_of_Death_9999");
INSERT INTO comment VALUES (39, 3, "2021-01-23 02:18:43", "vegetarians: am i a joke to you?", NULL, "ouroboros");
INSERT INTO comment VALUES (39, 4, "2021-01-23 02:18:43", "iron supplements: am i a joke to you?", NULL, "Angel_of_Death_9999");

INSERT INTO comment VALUES (41, 1, "2020-04-14 04:45:52", "that's it, I'm sticking to giv memes", NULL, "CrispyChips");
INSERT INTO comment VALUES (41, 2, "2020-04-14 04:45:52", "what if the meme is here too \:O", NULL, "ouroboros");

INSERT INTO comment VALUES (42, 1, "2021-10-05 11:21:58", "we call that 'Ice Cream'", NULL, "CrispyChips");
INSERT INTO comment VALUES (42, 2, "2021-10-05 11:21:58", "sounds delicious!", NULL, "cookie_destroyer");
INSERT INTO comment VALUES (42, 3, "2021-10-05 11:21:58", "dessert time", NULL, "qwerty");

INSERT INTO comment VALUES (43, 1, "2021-03-24 23:22:07", "sure i will", NULL, "tee_sword");
INSERT INTO comment VALUES (43, 2, "2021-03-24 23:22:07", "thanks!", NULL, "P1ZzA");

INSERT INTO comment VALUES (45, 1, "2020-10-04 08:22:57", "Have you... never eaten bread?", NULL, "aquaman");
INSERT INTO comment VALUES (45, 2, "2020-10-04 08:22:57", "that sounds serious", NULL, "RedLavender");
INSERT INTO comment VALUES (45, 3, "2020-10-04 08:22:57", "rip", NULL, "ouroboros");

INSERT INTO comment VALUES (46, 1, "2020-04-27 17:06:39", "how? we can't even see your artwork", NULL, "tomminute");
INSERT INTO comment VALUES (46, 2, "2020-04-27 17:06:39", "giv doesn't support image posting right now unfortunately...", NULL, "cow_lover94");
INSERT INTO comment VALUES (46, 3, "2020-04-27 17:06:39", "i guess we have to wait for future updates", NULL, "tomminute");

INSERT INTO comment VALUES (48, 1, "2020-06-02 18:52:43", "sadly the future is in STEM", NULL, "qwerty");
INSERT INTO comment VALUES (48, 2, "2020-06-02 18:52:43", "I mean, you can go do stuff like graphics and design, I heard that's kind of in demand lately?", NULL, "nether_dragon");

INSERT INTO comment VALUES (49, 1, "2020-11-14 09:53:17", "6^2, 8^2 and 10^2 is one", NULL, "Angel_of_Death_9999");
INSERT INTO comment VALUES (49, 2, "2020-11-14 09:53:17", "anything else?", 1, "nether_dragon");
INSERT INTO comment VALUES (49, 3, "2020-11-14 09:53:17", "idk", 2, "Angel_of_Death_9999");
INSERT INTO comment VALUES (49, 4, "2020-11-14 09:53:17", "there's that method where you square it, subtract one and halve it but it only works for odd numbers", NULL, "qwerty");

INSERT INTO comment VALUES (50, 1, "2021-05-08 00:43:10", "it's an equation. Since both sides are the same thing, you can freely do anything you want as long as you do the same thing on both sides so they are equal", NULL, "CrispyChips");
INSERT INTO comment VALUES (50, 2, "2021-05-08 00:43:10", "ah, I understand, thanks", NULL, "tee_sword");

INSERT INTO comment VALUES (51, 1, "2021-02-09 21:09:06", "i like how he does algebra even with his love for letters", NULL, "hello");

INSERT INTO comment VALUES (52, 1, "2020-03-12 22:45:46", "I'd say those odds are very impossible.", NULL, "RedLavender");
INSERT INTO comment VALUES (52, 2, "2020-03-12 22:45:46", "It depends on what you're doing. If I say your chance of dying for every centimetre you walk is one in 7.5 trillion, I don't think you'd say that's small at all. But if let's say I was trading, and the chance of me getting a good deal is 1 in 7.5 trillion, yeah, it's not happening", NULL, "P1ZzA");

INSERT INTO comment VALUES (53, 1, "2021-10-31 14:37:36", "kind of? with sigma and pi function", NULL, "Theseus");
INSERT INTO comment VALUES (53, 2, "2021-10-31 14:37:36", "No, math isn't really suited for writing algorithms and stuff. Closest is sum and product.", NULL, "aquaman");

INSERT INTO comment VALUES (54, 1, "2021-09-27 21:39:27", "probably not, they're entirely different things.", NULL, "big_dinosaur11");
INSERT INTO comment VALUES (54, 2, "2021-09-27 21:39:27", "Dark Hydrogen is really cool, yeah", NULL, "cow_lover94");

INSERT INTO comment VALUES (55, 1, "2021-10-03 11:12:46", "it's entropy-driven", NULL, "big_dinosaur11");
INSERT INTO comment VALUES (55, 2, "2021-10-03 11:12:46", "the change in entropy is greater than the change in enthalpy and it is entropy driven, thus there is still net driving force for forward reaction", NULL, "qwerty");

INSERT INTO comment VALUES (56, 1, "2021-04-16 21:32:42", "it is weird, but that's just how physics works", NULL, "nether_dragon");
INSERT INTO comment VALUES (56, 2, "2021-04-16 21:32:42", "yeah, if you go faster than light, which reqires infinite energy, you'll go back through time whoa", NULL, "RedLavender");

INSERT INTO comment VALUES (57, 1, "2020-04-15 04:04:56", "that... is a way of looking at it", NULL, "cow_lover94");
INSERT INTO comment VALUES (57, 2, "2020-04-15 04:04:56", "I guess... yeah.", NULL, "seedyguy");

INSERT INTO comment VALUES (58, 1, "2021-09-22 06:00:49", "No, it's another infinite energy problem to slow down an atom so that it has no energy", NULL, "P1ZzA");

INSERT INTO comment VALUES (70, 1, "2021-02-12 15:16:04", "endgame it's really hard and requires some grinding, but early game it's kind of easy", NULL, "ouroboros");
INSERT INTO comment VALUES (70, 2, "2021-02-12 15:16:04", "not that hard if you're good at the game", NULL, "nether_dragon");
INSERT INTO comment VALUES (70, 3, "2021-02-12 15:16:04", "help i need money", NULL, "qwerty");
INSERT INTO comment VALUES (70, 4, "2021-02-12 15:16:04", "You can trade with villages for money!", NULL, "cow_lover94");

INSERT INTO comment VALUES (71, 1, "2021-09-12 16:34:55", "Prepare for the nerf hammer!", NULL, "aquaman");
INSERT INTO comment VALUES (71, 2, "2021-09-12 16:34:55", "yeah I really like them", NULL, "alphabet_king");
INSERT INTO comment VALUES (71, 3, "2021-09-12 16:34:55", "enjoy them while you can bud", NULL, "big_dinosaur11");

INSERT INTO comment VALUES (72, 1, "2020-08-23 11:38:50", "yeah plus it's much faster and smoother", NULL, "ouroboros");

INSERT INTO comment VALUES (73, 1, "2020-05-25 11:21:15", "yeah, some quality of life changes", NULL, "symphony");
INSERT INTO comment VALUES (73, 2, "2020-05-25 11:21:15", "omg that infuriated me so much, luckily it's gone now", NULL, "cookie_destroyer");

INSERT INTO comment VALUES (74, 1, "2020-08-05 15:19:10", "Whoa, yeah, those are rare...", NULL, "aquaman");
INSERT INTO comment VALUES (74, 2, "2020-08-05 15:19:10", "I've never seen one before", NULL, "hello");
INSERT INTO comment VALUES (74, 3, "2020-08-05 15:19:10", "giv picture functionality when", NULL, "alphabet_king");

INSERT INTO comment VALUES (75, 1, "2021-12-18 01:00:05", "birb", NULL, "ouroboros");
INSERT INTO comment VALUES (75, 2, "2021-12-18 01:00:05", "birb", NULL, "alphabet_king");
INSERT INTO comment VALUES (75, 3, "2021-12-18 01:00:05", "birb", NULL, "CrispyChips");
INSERT INTO comment VALUES (75, 4, "2021-12-18 01:00:05", "birb", NULL, "qwerty");

INSERT INTO comment VALUES (76, 1, "2020-06-12 21:40:36", "outside my house there's a lot of birds in the trees lol", NULL, "hello");
INSERT INTO comment VALUES (76, 2, "2020-06-12 21:40:36", "try the national parks", NULL, "CrispyChips");

INSERT INTO comment VALUES (77, 1, "2020-09-09 06:24:30", "the supermarket?", NULL, "qwerty");
INSERT INTO comment VALUES (77, 2, "2020-09-09 06:24:30", "Pet store!", NULL, "cow_lover94");

INSERT INTO comment VALUES (79, 1, "2021-06-12 07:09:56", "why is this so relatable", NULL, "qwerty");
INSERT INTO comment VALUES (79, 2, "2021-06-12 07:09:56", "happens to all of us", NULL, "cookie_destroyer");
INSERT INTO comment VALUES (79, 3, "2021-06-12 07:09:56", "this is me so hard", NULL, "P1ZzA");

INSERT INTO comment VALUES (80, 1, "2020-12-30 06:56:21", "no u", NULL, "Theseus");
INSERT INTO comment VALUES (80, 2, "2020-12-30 06:56:21", "bruh", NULL, "seedyguy");
INSERT INTO comment VALUES (80, 3, "2020-12-30 06:56:21", "true", NULL, "alphabet_king");

INSERT INTO comment VALUES (81, 1, "2020-08-09 15:37:30", "this website was built using flask and sql lol", NULL, "big_dinosaur11");
INSERT INTO comment VALUES (81, 2, "2020-08-09 15:37:30", "hmmmm", 1, "nether_dragon");
INSERT INTO comment VALUES (81, 3, "2020-08-09 15:37:30", "hmmmm indeed", 2, "ouroboros");

INSERT INTO comment VALUES (82, 1, "2020-12-07 01:20:02", "lol graph go brrrr", NULL, "nether_dragon");

INSERT INTO comment VALUES (83, 1, "2020-09-17 19:37:37", "how did you know", NULL, "nether_dragon");
INSERT INTO comment VALUES (83, 2, "2020-09-17 19:37:37", "i have my ways lol", NULL, "cookie_destroyer");

INSERT INTO comment VALUES (84, 1, "2020-03-13 11:21:33", "what is the answer", NULL, "hello");
INSERT INTO comment VALUES (84, 2, "2020-03-13 11:21:33", "2", NULL, "qwerty");
INSERT INTO comment VALUES (84, 3, "2020-03-13 11:21:33", "2", NULL, "P1ZzA");
INSERT INTO comment VALUES (84, 4, "2020-03-13 11:21:33", "2", NULL, "symphony");
INSERT INTO comment VALUES (84, 5, "2020-03-13 11:21:33", "3", NULL, "symphony");
INSERT INTO comment VALUES (84, 6, "2020-03-13 11:21:33", "1+1", NULL, "symphony");

INSERT INTO comment VALUES (85, 1, "2021-02-27 01:53:27", "zero", NULL, "symphony");
INSERT INTO comment VALUES (85, 2, "2021-02-27 01:53:27", "0", NULL, "CrispyChips");
INSERT INTO comment VALUES (85, 3, "2021-02-27 01:53:27", "this is so easy lol", NULL, "alphabet_king");

INSERT INTO comment VALUES (86, 1, "2020-03-17 19:57:38", "59 minutes", NULL, "hello");
INSERT INTO comment VALUES (86, 2, "2020-03-17 19:57:38", "59 min", NULL, "CrispyChips");
INSERT INTO comment VALUES (86, 3, "2020-03-17 19:57:38", "59", NULL, "ouroboros");
INSERT INTO comment VALUES (86, 4, "2020-03-17 19:57:38", "this is overused", NULL, "qwerty");
INSERT INTO comment VALUES (86, 5, "2020-03-17 19:57:38", "30?", NULL, "cookie_destroyer");

 -- DELETE FROM chat_group;
INSERT INTO chat_group VALUES (1, "friends", "group of friends", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (2, "cow cult", "all shall become cows", "https://upload.wikimedia.org/wikipedia/commons/0/0c/Cow_female_black_white.jpg", "2020-12-28");
INSERT INTO chat_group VALUES (3, "myself", "", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (4, "ouroboros and symphony", "\:D", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (5, "casual chatting", "lol description", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (6, "classmates!", "class of 2050!", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (7, "snoozing club", "yknow", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (8, "programmers unite!", "", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (9, "P1ZzA", "casual chat", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (10, "big_dinosaur11 and hello", "", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (11, "Mine Art Guild", "Mine Art rules", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (12, "artists unite", "art rules", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (13, "food for thought", "foodies <3", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (14, "Theseus bullies tomminute", "", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (15, "death takes all", "", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (16, "Programming Horror", "", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (17, "aquaman interest group", "", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (18, "who is admin", "", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (19, "A GANG", "for all the glorious people whose usernames starts with A", NULL, "2021-03-21");
INSERT INTO chat_group VALUES (20, "math_and_science", "", NULL, "2021-03-21");

 -- DELETE FROM chat_group_moderators;
INSERT INTO chat_group_moderators VALUES (1, "willsuit");
INSERT INTO chat_group_moderators VALUES (2, "cow_lover94");
INSERT INTO chat_group_moderators VALUES (3, "cookie_destroyer");
INSERT INTO chat_group_moderators VALUES (4, "ouroboros");
INSERT INTO chat_group_moderators VALUES (5, "big_dinosaur11");
INSERT INTO chat_group_moderators VALUES (6, "nether_dragon");
INSERT INTO chat_group_moderators VALUES (7, "tee_sword");
INSERT INTO chat_group_moderators VALUES (8, "ouroboros");
INSERT INTO chat_group_moderators VALUES (9, "P1ZzA");
INSERT INTO chat_group_moderators VALUES (10, "hello");
INSERT INTO chat_group_moderators VALUES (11, "willsuit");
INSERT INTO chat_group_moderators VALUES (12, "RedLavender");
INSERT INTO chat_group_moderators VALUES (13, "ouroboros");
INSERT INTO chat_group_moderators VALUES (14, "Theseus");
INSERT INTO chat_group_moderators VALUES (15, "Angel_of_Death_9999");
INSERT INTO chat_group_moderators VALUES (16, "qwerty");
INSERT INTO chat_group_moderators VALUES (17, "aquaman");
INSERT INTO chat_group_moderators VALUES (18, "CrispyChips");
INSERT INTO chat_group_moderators VALUES (19, "alphabet_king");
INSERT INTO chat_group_moderators VALUES (20, "nether_dragon");

 -- DELETE FROM message;
INSERT INTO message VALUES (1, 1, "hi", "willsuit", NULL, "2021-03-21 00:54:00");
INSERT INTO message VALUES (1, 2, "why did you create a group chat with only the two of us Will", "tomminute", NULL, "2021-03-21 00:54:00");
INSERT INTO message VALUES (1, 3, "it's a group with all our friends, Tom", "willsuit", NULL, "2021-03-21 00:54:00");
INSERT INTO message VALUES (1, 4, "that's really insulting", "tomminute", NULL, "2021-03-21 00:54:00");
INSERT INTO message VALUES (1, 5, "did you just leave, Tom", "willsuit", NULL, "2021-03-21 00:54:00");
INSERT INTO message VALUES (1, 6, "come back", "willsuit", NULL, "2021-03-21 00:54:00");
INSERT INTO message VALUES (1, 7, "\:(", "willsuit", NULL, "2021-03-21 00:54:00");

INSERT INTO message VALUES (2, 1, "moo", "cow_lover94", NULL, "2020-12-28 14:46:17");
INSERT INTO message VALUES (2, 2, "moo!", "Theseus", NULL, "2020-12-28 14:46:17");
INSERT INTO message VALUES (2, 3, "moo?", "qwerty", NULL, "2020-12-28 14:46:17");
INSERT INTO message VALUES (2, 4, "moo moo!", "cow_lover94", NULL, "2020-12-28 14:46:17");
INSERT INTO message VALUES (2, 5, "moo moo moo", "Theseus", NULL, "2020-12-28 14:46:17");
INSERT INTO message VALUES (2, 6, "why am i added", "aquaman", NULL, "2020-12-28 14:46:17");
INSERT INTO message VALUES (2, 7, "moo moo", "cow_lover94", NULL, "2020-12-28 14:46:17");
INSERT INTO message VALUES (2, 8, "uh oh", "aquaman", NULL, "2020-12-28 14:46:17");

INSERT INTO message VALUES (3, 1, ")\" OR 1=1; --", "cookie_destroyer", NULL, "2021-03-21 16:06:55");
INSERT INTO message VALUES (3, 2, ")' OR 1=1; --", "cookie_destroyer", NULL, "2021-03-21 16:06:55");
INSERT INTO message VALUES (3, 3, "rip sql injection doesn't work on this website", "cookie_destroyer", NULL, "2021-03-21 16:06:55");
INSERT INTO message VALUES (3, 4, "sadded", "cookie_destroyer", NULL, "2021-03-21 16:06:55");

INSERT INTO message VALUES (4, 1, "hey are you there?", "ouroboros", NULL, "2021-07-17 08:27:20");
INSERT INTO message VALUES (4, 2, "yeah", "symphony", NULL, "2021-07-17 08:27:20");
INSERT INTO message VALUES (4, 3, "so i wanted to say this for a long time", "ouroboros", NULL, "2021-07-17 08:27:20");
INSERT INTO message VALUES (4, 4, "i really like you", "ouroboros", NULL, "2021-07-17 08:27:20");
INSERT INTO message VALUES (4, 5, "and i understand if you dont", "ouroboros", NULL, "2021-07-17 08:27:20");
INSERT INTO message VALUES (4, 6, "yknow", "symphony", NULL, "2021-07-17 08:27:20");
INSERT INTO message VALUES (4, 7, "I never thought I'd say this", "symphony", NULL, "2021-07-17 08:27:20");
INSERT INTO message VALUES (4, 8, "but I...", "symphony", NULL, "2021-07-17 08:27:20");
INSERT INTO message VALUES (4, 9, "I think I like you too", "symphony", NULL, "2021-07-17 08:27:20");
INSERT INTO message VALUES (4, 10, "...wow", "ouroboros", NULL, "2021-07-17 08:27:20");
INSERT INTO message VALUES (4, 11, "I never thought...", "ouroboros", NULL, "2021-07-17 08:27:20");
INSERT INTO message VALUES (4, 12, "do you want to go for lunch today?", "ouroboros", NULL, "2021-07-17 08:27:20");
INSERT INTO message VALUES (4, 13, "same place and time?", "symphony", NULL, "2021-07-17 08:27:20");
INSERT INTO message VALUES (4, 14, "sure \:D", "ouroboros", NULL, "2021-07-17 08:27:20");
INSERT INTO message VALUES (4, 15, "I'll be there \:D", "symphony", NULL, "2021-07-17 08:27:20");

INSERT INTO message VALUES (5, 1, "does anyone want to chat?", "big_dinosaur11", NULL, "2021-02-14 19:25:05");

INSERT INTO message VALUES (6, 1, "hey long time no see", "nether_dragon", NULL, "2020-07-20 02:29:08");
INSERT INTO message VALUES (6, 2, "yo!", "RedLavender", NULL, "2020-07-20 02:29:08");

INSERT INTO message VALUES (7, 1, "hey guys want to play some Mine Art?", "tee_sword", NULL, "2020-10-14 08:14:44");
INSERT INTO message VALUES (7, 2, "yoooooooo", "willsuit", NULL, "2020-10-14 08:14:44");
INSERT INTO message VALUES (7, 3, "sure!", "tomminute", NULL, "2020-10-14 08:14:44");
INSERT INTO message VALUES (7, 4, "will i need your password", "tomminute", NULL, "2020-10-14 08:14:44");
INSERT INTO message VALUES (7, 5, "why do you need my password", "willsuit", NULL, "2020-10-14 08:14:44");
INSERT INTO message VALUES (7, 6, "reasons", "tomminute", NULL, "2020-10-14 08:14:44");
INSERT INTO message VALUES (7, 7, "No, Tom", "willsuit", NULL, "2020-10-14 08:14:44");
INSERT INTO message VALUES (7, 8, "Well, it was worth a shot", "tomminute", NULL, "2020-10-14 08:14:44");

INSERT INTO message VALUES (9, 1, "hey, how's your day?", "P1ZzA", NULL, "2020-07-20 00:27:01");
INSERT INTO message VALUES (9, 2, "really great, thank you!", "hello", NULL, "2020-07-20 00:27:01");

INSERT INTO message VALUES (10, 1, "hello!", "big_dinosaur11", NULL, "2020-07-20 00:27:01");
INSERT INTO message VALUES (10, 2, "hey!", "hello", NULL, "2020-07-20 00:27:01");

INSERT INTO message VALUES (12, 1, "does anyone want to go to the art museum today?", "RedLavender", NULL, "2020-07-21 16:51:40");
INSERT INTO message VALUES (12, 2, "is it open?", "qwerty", NULL, "2020-07-20 16:51:40");
INSERT INTO message VALUES (12, 3, "i dont know", "RedLavender", NULL, "2020-07-20 16:51:40");
INSERT INTO message VALUES (12, 4, "that sounds like something we should check before we go there", "alphabet_king", NULL, "2020-07-20 16:51:40");
INSERT INTO message VALUES (12, 5, "apparently it is not", "RedLavender", NULL, "2020-07-20 16:51:40");
INSERT INTO message VALUES (12, 6, "oof", "qwerty", NULL, "2020-07-20 16:51:40");
INSERT INTO message VALUES (12, 7, "nevermind then", "qwerty", NULL, "2020-07-20 16:51:40");

INSERT INTO message VALUES (18, 1, "Who's the admin of giv?", "CrispyChips", NULL, "2020-08-12 22:05:11");
INSERT INTO message VALUES (18, 2, "i dont know", "big_dinosaur11", NULL, "2020-08-12 22:05:11");
INSERT INTO message VALUES (18, 3, "hello", "admin", NULL, "2020-08-12 22:05:11");
INSERT INTO message VALUES (18, 4, "omg he's actually here", "CrispyChips", NULL, "2020-08-12 22:05:11");
INSERT INTO message VALUES (18, 5, "\:O", "big_dinosaur11", NULL, "2020-08-12 22:05:11");

INSERT INTO message VALUES (19, 1, "greetings fellow A's!", "alphabet_king", NULL, "2020-07-20 07:48:19");
INSERT INTO message VALUES (19, 2, "Uhh... hello?", "aquaman", NULL, "2020-07-20 07:48:19");
INSERT INTO message VALUES (19, 3, "Why are we here?", "Angel_of_Death_9999", NULL, "2020-07-20 07:48:19");

 -- DELETE FROM user_chat_info;
INSERT INTO user_chat_info VALUES ("willsuit", 1);
INSERT INTO user_chat_info VALUES ("tomminute", 1);
INSERT INTO user_chat_info VALUES ("cow_lover94", 2);
INSERT INTO user_chat_info VALUES ("Theseus", 2);
INSERT INTO user_chat_info VALUES ("qwerty", 2);
INSERT INTO user_chat_info VALUES ("aquaman", 2);
INSERT INTO user_chat_info VALUES ("cookie_destroyer", 3);
INSERT INTO user_chat_info VALUES ("ouroboros", 4);
INSERT INTO user_chat_info VALUES ("symphony", 4);
INSERT INTO user_chat_info VALUES ("big_dinosaur11", 5);
INSERT INTO user_chat_info VALUES ("cookie_destroyer", 5);
INSERT INTO user_chat_info VALUES ("cow_lover94", 5);
INSERT INTO user_chat_info VALUES ("Theseus", 5);
INSERT INTO user_chat_info VALUES ("qwerty", 5);
INSERT INTO user_chat_info VALUES ("hello", 5);
INSERT INTO user_chat_info VALUES ("nether_dragon", 6);
INSERT INTO user_chat_info VALUES ("RedLavender", 6);
INSERT INTO user_chat_info VALUES ("willsuit", 7);
INSERT INTO user_chat_info VALUES ("tomminute", 7);
INSERT INTO user_chat_info VALUES ("P1ZzA", 7);
INSERT INTO user_chat_info VALUES ("tee_sword", 7);
INSERT INTO user_chat_info VALUES ("ouroboros", 8);
INSERT INTO user_chat_info VALUES ("qwerty", 8);
INSERT INTO user_chat_info VALUES ("P1ZzA", 9);
INSERT INTO user_chat_info VALUES ("hello", 9);
INSERT INTO user_chat_info VALUES ("big_dinosaur11", 10);
INSERT INTO user_chat_info VALUES ("hello", 10);
INSERT INTO user_chat_info VALUES ("willsuit", 11);
INSERT INTO user_chat_info VALUES ("tomminute", 11);
INSERT INTO user_chat_info VALUES ("tee_sword", 11);
INSERT INTO user_chat_info VALUES ("alphabet_king", 12);
INSERT INTO user_chat_info VALUES ("RedLavender", 12);
INSERT INTO user_chat_info VALUES ("qwerty", 12);
INSERT INTO user_chat_info VALUES ("P1ZzA", 12);
INSERT INTO user_chat_info VALUES ("seedyguy", 13);
INSERT INTO user_chat_info VALUES ("tomminute", 14);
INSERT INTO user_chat_info VALUES ("Theseus", 14);
INSERT INTO user_chat_info VALUES ("Angel_of_Death_9999", 15);
INSERT INTO user_chat_info VALUES ("qwerty", 16);
INSERT INTO user_chat_info VALUES ("ouroboros", 16);
INSERT INTO user_chat_info VALUES ("aquaman", 17);
INSERT INTO user_chat_info VALUES ("big_dinosaur11", 18);
INSERT INTO user_chat_info VALUES ("CrispyChips", 18);
INSERT INTO user_chat_info VALUES ("alphabet_king", 19);
INSERT INTO user_chat_info VALUES ("aquaman", 19);
INSERT INTO user_chat_info VALUES ("Angel_of_Death_9999", 19);
INSERT INTO user_chat_info VALUES ("nether_dragon", 20);
INSERT INTO user_chat_info VALUES ("P1ZzA", 20);

 -- DELETE FROM follow;
INSERT INTO follow VALUES ("willsuit", "tomminute");
INSERT INTO follow VALUES ("tomminute", "willsuit");
INSERT INTO follow VALUES ("P1ZzA", "tee_sword");
INSERT INTO follow VALUES ("tee_sword", "P1ZzA");
INSERT INTO follow VALUES ("cow_lover94", "Theseus");
INSERT INTO follow VALUES ("cow_lover94", "qwerty");
INSERT INTO follow VALUES ("aquaman", "cow_lover94");
INSERT INTO follow VALUES ("big_dinosaur11", "cow_lover94");
INSERT INTO follow VALUES ("Theseus", "cow_lover94");
INSERT INTO follow VALUES ("qwerty", "cow_lover94");
INSERT INTO follow VALUES ("hello", "cow_lover94");
INSERT INTO follow VALUES ("cow_lover94", "hello");
INSERT INTO follow VALUES ("nether_dragon", "RedLavender");
INSERT INTO follow VALUES ("RedLavender", "nether_dragon");
INSERT INTO follow VALUES ("CrispyChips", "RedLavender");
INSERT INTO follow VALUES ("RedLavender", "CrispyChips");
INSERT INTO follow VALUES ("alphabet_king", "seedyguy");
INSERT INTO follow VALUES ("seedyguy", "alphabet_king");
INSERT INTO follow VALUES ("ouroboros", "symphony");
INSERT INTO follow VALUES ("symphony", "ouroboros");
INSERT INTO follow VALUES ("Theseus", "tomminute");

 -- DELETE FROM interest_group_moderators;
INSERT INTO interest_group_moderators VALUES ("Mine Art", "willsuit");
INSERT INTO interest_group_moderators VALUES ("Mine Art", "tomminute");
INSERT INTO interest_group_moderators VALUES ("Chess", "aquaman");
INSERT INTO interest_group_moderators VALUES ("Jokes", "qwerty");
INSERT INTO interest_group_moderators VALUES ("Music", "symphony");
INSERT INTO interest_group_moderators VALUES ("Chatting", "cow_lover94");
INSERT INTO interest_group_moderators VALUES ("Advice", "aquaman");
INSERT INTO interest_group_moderators VALUES ("Giv", "hello");
INSERT INTO interest_group_moderators VALUES ("Stories", "qwerty");
INSERT INTO interest_group_moderators VALUES ("News", "ouroboros");
INSERT INTO interest_group_moderators VALUES ("Food", "P1ZzA");
INSERT INTO interest_group_moderators VALUES ("Art", "qwerty");
INSERT INTO interest_group_moderators VALUES ("Math", "aquaman");
INSERT INTO interest_group_moderators VALUES ("Science", "qwerty");
INSERT INTO interest_group_moderators VALUES ("Books", "qwerty");
INSERT INTO interest_group_moderators VALUES ("Movies", "qwerty");
INSERT INTO interest_group_moderators VALUES ("Mine Art II", "qwerty");
INSERT INTO interest_group_moderators VALUES ("Birds", "symphony");
INSERT INTO interest_group_moderators VALUES ("Announcements", "hello");
INSERT INTO interest_group_moderators VALUES ("Programming", "qwerty");
INSERT INTO interest_group_moderators VALUES ("Puzzles", "P1ZzA");

 -- DELETE FROM interest_group_participants;
INSERT INTO interest_group_participants VALUES ("Mine Art", "willsuit");
INSERT INTO interest_group_participants VALUES ("Mine Art", "tomminute");
INSERT INTO interest_group_participants VALUES ("Mine Art", "P1ZzA");
INSERT INTO interest_group_participants VALUES ("Mine Art", "tee_sword");
INSERT INTO interest_group_participants VALUES ("Mine Art", "qwerty");
INSERT INTO interest_group_participants VALUES ("Mine Art", "aquaman");
INSERT INTO interest_group_participants VALUES ("Mine Art", "hello");
INSERT INTO interest_group_participants VALUES ("Mine Art", "CrispyChips");
INSERT INTO interest_group_participants VALUES ("Mine Art", "Angel_of_Death_9999");
INSERT INTO interest_group_participants VALUES ("Mine Art", "cow_lover94");
INSERT INTO interest_group_participants VALUES ("Mine Art", "ouroboros");
INSERT INTO interest_group_participants VALUES ("Mine Art", "big_dinosaur11");
INSERT INTO interest_group_participants VALUES ("Mine Art", "nether_dragon");
INSERT INTO interest_group_participants VALUES ("Mine Art", "cookie_destroyer");
INSERT INTO interest_group_participants VALUES ("Mine Art", "RedLavender");
INSERT INTO interest_group_participants VALUES ("Mine Art", "Theseus");
INSERT INTO interest_group_participants VALUES ("Mine Art", "symphony");

INSERT INTO interest_group_participants VALUES ("Chess", "aquaman");

INSERT INTO interest_group_participants VALUES ("Jokes", "qwerty");
INSERT INTO interest_group_participants VALUES ("Jokes", "Theseus");
INSERT INTO interest_group_participants VALUES ("Jokes", "cookie_destroyer");
INSERT INTO interest_group_participants VALUES ("Jokes", "P1ZzA");
INSERT INTO interest_group_participants VALUES ("Jokes", "Angel_of_Death_9999");
INSERT INTO interest_group_participants VALUES ("Jokes", "nether_dragon");

INSERT INTO interest_group_participants VALUES ("Music", "qwerty");
INSERT INTO interest_group_participants VALUES ("Music", "hello");
INSERT INTO interest_group_participants VALUES ("Music", "aquaman");
INSERT INTO interest_group_participants VALUES ("Music", "cookie_destroyer");
INSERT INTO interest_group_participants VALUES ("Music", "cow_lover94");
INSERT INTO interest_group_participants VALUES ("Music", "RedLavender");
INSERT INTO interest_group_participants VALUES ("Music", "nether_dragon");
INSERT INTO interest_group_participants VALUES ("Music", "symphony");
INSERT INTO interest_group_participants VALUES ("Music", "ouroboros");
INSERT INTO interest_group_participants VALUES ("Music", "CrispyChips");

INSERT INTO interest_group_participants VALUES ("Chatting", "qwerty");
INSERT INTO interest_group_participants VALUES ("Chatting", "willsuit");
INSERT INTO interest_group_participants VALUES ("Chatting", "tomminute");
INSERT INTO interest_group_participants VALUES ("Chatting", "cow_lover94");
INSERT INTO interest_group_participants VALUES ("Chatting", "big_dinosaur11");
INSERT INTO interest_group_participants VALUES ("Chatting", "Theseus");
INSERT INTO interest_group_participants VALUES ("Chatting", "cookie_destroyer");
INSERT INTO interest_group_participants VALUES ("Chatting", "alphabet_king");
INSERT INTO interest_group_participants VALUES ("Chatting", "aquaman");
INSERT INTO interest_group_participants VALUES ("Chatting", "hello");
INSERT INTO interest_group_participants VALUES ("Chatting", "CrispyChips");
INSERT INTO interest_group_participants VALUES ("Chatting", "nether_dragon");
INSERT INTO interest_group_participants VALUES ("Chatting", "seedyguy");
INSERT INTO interest_group_participants VALUES ("Chatting", "ouroboros");
INSERT INTO interest_group_participants VALUES ("Chatting", "Angel_of_Death_9999");
INSERT INTO interest_group_participants VALUES ("Chatting", "symphony");
INSERT INTO interest_group_participants VALUES ("Chatting", "RedLavender");
INSERT INTO interest_group_participants VALUES ("Chatting", "P1ZzA");

INSERT INTO interest_group_participants VALUES ("Advice", "willsuit");
INSERT INTO interest_group_participants VALUES ("Advice", "cookie_destroyer");
INSERT INTO interest_group_participants VALUES ("Advice", "cow_lover94");
INSERT INTO interest_group_participants VALUES ("Advice", "tomminute");
INSERT INTO interest_group_participants VALUES ("Advice", "Theseus");
INSERT INTO interest_group_participants VALUES ("Advice", "qwerty");
INSERT INTO interest_group_participants VALUES ("Advice", "hello");
INSERT INTO interest_group_participants VALUES ("Advice", "big_dinosaur11");
INSERT INTO interest_group_participants VALUES ("Advice", "Angel_of_Death_9999");
INSERT INTO interest_group_participants VALUES ("Advice", "tee_sword");
INSERT INTO interest_group_participants VALUES ("Advice", "CrispyChips");
INSERT INTO interest_group_participants VALUES ("Advice", "P1ZzA");
INSERT INTO interest_group_participants VALUES ("Advice", "seedyguy");
INSERT INTO interest_group_participants VALUES ("Advice", "nether_dragon");
INSERT INTO interest_group_participants VALUES ("Advice", "symphony");
INSERT INTO interest_group_participants VALUES ("Advice", "ouroboros");

INSERT INTO interest_group_participants VALUES ("Giv", "hello");
INSERT INTO interest_group_participants VALUES ("Giv", "qwerty");
INSERT INTO interest_group_participants VALUES ("Giv", "RedLavender");

INSERT INTO interest_group_participants VALUES ("Stories", "cookie_destroyer");
INSERT INTO interest_group_participants VALUES ("Stories", "cow_lover94");
INSERT INTO interest_group_participants VALUES ("Stories", "Theseus");
INSERT INTO interest_group_participants VALUES ("Stories", "qwerty");
INSERT INTO interest_group_participants VALUES ("Stories", "big_dinosaur11");
INSERT INTO interest_group_participants VALUES ("Stories", "Angel_of_Death_9999");
INSERT INTO interest_group_participants VALUES ("Stories", "CrispyChips");
INSERT INTO interest_group_participants VALUES ("Stories", "seedyguy");
INSERT INTO interest_group_participants VALUES ("Stories", "RedLavender");
INSERT INTO interest_group_participants VALUES ("Stories", "ouroboros");

INSERT INTO interest_group_participants VALUES ("News", "qwerty");
INSERT INTO interest_group_participants VALUES ("News", "Angel_of_Death_9999");
INSERT INTO interest_group_participants VALUES ("News", "CrispyChips");
INSERT INTO interest_group_participants VALUES ("News", "seedyguy");
INSERT INTO interest_group_participants VALUES ("News", "RedLavender");
INSERT INTO interest_group_participants VALUES ("News", "nether_dragon");
INSERT INTO interest_group_participants VALUES ("News", "ouroboros");

INSERT INTO interest_group_participants VALUES ("Food", "cookie_destroyer");
INSERT INTO interest_group_participants VALUES ("Food", "qwerty");
INSERT INTO interest_group_participants VALUES ("Food", "big_dinosaur11");
INSERT INTO interest_group_participants VALUES ("Food", "aquaman");
INSERT INTO interest_group_participants VALUES ("Food", "tee_sword");
INSERT INTO interest_group_participants VALUES ("Food", "CrispyChips");
INSERT INTO interest_group_participants VALUES ("Food", "P1ZzA");
INSERT INTO interest_group_participants VALUES ("Food", "seedyguy");
INSERT INTO interest_group_participants VALUES ("Food", "RedLavender");
INSERT INTO interest_group_participants VALUES ("Food", "ouroboros");

INSERT INTO interest_group_participants VALUES ("Art", "cow_lover94");
INSERT INTO interest_group_participants VALUES ("Art", "tomminute");
INSERT INTO interest_group_participants VALUES ("Art", "qwerty");
INSERT INTO interest_group_participants VALUES ("Art", "P1ZzA");
INSERT INTO interest_group_participants VALUES ("Art", "RedLavender");
INSERT INTO interest_group_participants VALUES ("Art", "nether_dragon");

INSERT INTO interest_group_participants VALUES ("Math", "Theseus");
INSERT INTO interest_group_participants VALUES ("Math", "qwerty");
INSERT INTO interest_group_participants VALUES ("Math", "hello");
INSERT INTO interest_group_participants VALUES ("Math", "big_dinosaur11");
INSERT INTO interest_group_participants VALUES ("Math", "Angel_of_Death_9999");
INSERT INTO interest_group_participants VALUES ("Math", "aquaman");
INSERT INTO interest_group_participants VALUES ("Math", "alphabet_king");
INSERT INTO interest_group_participants VALUES ("Math", "tee_sword");
INSERT INTO interest_group_participants VALUES ("Math", "CrispyChips");
INSERT INTO interest_group_participants VALUES ("Math", "P1ZzA");
INSERT INTO interest_group_participants VALUES ("Math", "RedLavender");
INSERT INTO interest_group_participants VALUES ("Math", "nether_dragon");

INSERT INTO interest_group_participants VALUES ("Science", "cow_lover94");
INSERT INTO interest_group_participants VALUES ("Science", "qwerty");
INSERT INTO interest_group_participants VALUES ("Science", "big_dinosaur11");
INSERT INTO interest_group_participants VALUES ("Science", "Angel_of_Death_9999");
INSERT INTO interest_group_participants VALUES ("Science", "alphabet_king");
INSERT INTO interest_group_participants VALUES ("Science", "P1ZzA");
INSERT INTO interest_group_participants VALUES ("Science", "seedyguy");
INSERT INTO interest_group_participants VALUES ("Science", "RedLavender");
INSERT INTO interest_group_participants VALUES ("Science", "nether_dragon");
INSERT INTO interest_group_participants VALUES ("Science", "symphony");

INSERT INTO interest_group_participants VALUES ("Books", "CrispyChips");
INSERT INTO interest_group_participants VALUES ("Books", "ouroboros");
INSERT INTO interest_group_participants VALUES ("Books", "aquaman");
INSERT INTO interest_group_participants VALUES ("Books", "willsuit");
INSERT INTO interest_group_participants VALUES ("Books", "hello");

INSERT INTO interest_group_participants VALUES ("Movies", "qwerty");
INSERT INTO interest_group_participants VALUES ("Movies", "cookie_destroyer");
INSERT INTO interest_group_participants VALUES ("Movies", "RedLavender");
INSERT INTO interest_group_participants VALUES ("Movies", "CrispyChips");
INSERT INTO interest_group_participants VALUES ("Movies", "symphony");

INSERT INTO interest_group_participants VALUES ("Mine Art II", "cookie_destroyer");
INSERT INTO interest_group_participants VALUES ("Mine Art II", "cow_lover94");
INSERT INTO interest_group_participants VALUES ("Mine Art II", "tomminute");
INSERT INTO interest_group_participants VALUES ("Mine Art II", "qwerty");
INSERT INTO interest_group_participants VALUES ("Mine Art II", "big_dinosaur11");
INSERT INTO interest_group_participants VALUES ("Mine Art II", "Angel_of_Death_9999");
INSERT INTO interest_group_participants VALUES ("Mine Art II", "aquaman");
INSERT INTO interest_group_participants VALUES ("Mine Art II", "alphabet_king");
INSERT INTO interest_group_participants VALUES ("Mine Art II", "tee_sword");
INSERT INTO interest_group_participants VALUES ("Mine Art II", "CrispyChips");
INSERT INTO interest_group_participants VALUES ("Mine Art II", "nether_dragon");
INSERT INTO interest_group_participants VALUES ("Mine Art II", "symphony");
INSERT INTO interest_group_participants VALUES ("Mine Art II", "ouroboros");

INSERT INTO interest_group_participants VALUES ("Birds", "cow_lover94");
INSERT INTO interest_group_participants VALUES ("Birds", "qwerty");
INSERT INTO interest_group_participants VALUES ("Birds", "hello");
INSERT INTO interest_group_participants VALUES ("Birds", "aquaman");
INSERT INTO interest_group_participants VALUES ("Birds", "alphabet_king");
INSERT INTO interest_group_participants VALUES ("Birds", "CrispyChips");
INSERT INTO interest_group_participants VALUES ("Birds", "seedyguy");
INSERT INTO interest_group_participants VALUES ("Birds", "symphony");
INSERT INTO interest_group_participants VALUES ("Birds", "ouroboros");

INSERT INTO interest_group_participants VALUES ("Programming", "cookie_destroyer");
INSERT INTO interest_group_participants VALUES ("Programming", "Theseus");
INSERT INTO interest_group_participants VALUES ("Programming", "qwerty");
INSERT INTO interest_group_participants VALUES ("Programming", "big_dinosaur11");
INSERT INTO interest_group_participants VALUES ("Programming", "alphabet_king");
INSERT INTO interest_group_participants VALUES ("Programming", "P1ZzA");
INSERT INTO interest_group_participants VALUES ("Programming", "seedyguy");
INSERT INTO interest_group_participants VALUES ("Programming", "RedLavender");
INSERT INTO interest_group_participants VALUES ("Programming", "nether_dragon");
INSERT INTO interest_group_participants VALUES ("Programming", "ouroboros");

INSERT INTO interest_group_participants VALUES ("Puzzles", "cookie_destroyer");
INSERT INTO interest_group_participants VALUES ("Puzzles", "qwerty");
INSERT INTO interest_group_participants VALUES ("Puzzles", "hello");
INSERT INTO interest_group_participants VALUES ("Puzzles", "aquaman");
INSERT INTO interest_group_participants VALUES ("Puzzles", "alphabet_king");
INSERT INTO interest_group_participants VALUES ("Puzzles", "CrispyChips");
INSERT INTO interest_group_participants VALUES ("Puzzles", "P1ZzA");
INSERT INTO interest_group_participants VALUES ("Puzzles", "symphony");
INSERT INTO interest_group_participants VALUES ("Puzzles", "ouroboros");
