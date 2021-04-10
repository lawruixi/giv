#!/usr/bin/python3
import datetime 
import random 

random_year = random.randint(2020, 2021);
random_month = random.randint(1, 12);
random_day = 0;
thirty_one_day_months = [1, 3, 5, 7, 8, 10, 12]

while(True):
    random_day = random.randint(1, 31);
    if(random_month in thirty_one_day_months):
        break
    if(random_day > 28 and random_month == 2): #Screw leap years
        continue
    if(random_day == 31):
        continue
    break

random_hour = random.randint(0, 23);
random_minute = random.randint(0, 59);
random_second = random.randint(0, 59);

random_time = f"{random_year}-{random_month:02}-{random_day:02} {random_hour:02}:{random_minute:02}:{random_second:02}"

users = ["admin", "willsuit", "cookie_destroyer", "cow_lover94", "tomminute", "Theseus", "qwerty", "hello", "big_dinosaur11", "Angel_of_Death_9999", "aquaman", "alphabet_king", "tee_sword", "CrispyChips", "P1ZzA", "seedyguy", "RedLavender", "nether_dragon", "symphony", "ouroboros"]

post_id = str(int(input()));
comment_id = 1;
content = ""
outstring = "";
while(content != "q"):
    content = input();
    if(content == "q"): break;
    replying_to = "NULL"
    posted_by = random.choice(users);
    outstring += f"INSERT INTO comment VALUES ({post_id}, {comment_id}, \"{random_time}\", \"{content}\", {replying_to}, \"{posted_by}\");" + "\n"
    comment_id += 1;

print(outstring);
