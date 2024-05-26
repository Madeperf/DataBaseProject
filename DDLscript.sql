
DROP SCHEMA if exists `masterchef`;
CREATE SCHEMA `masterchef`;
use masterchef;

-- Απενεργοποίηση των περιορισμών ξένων κλειδιών
SET foreign_key_checks = 0;

-- Διαγραφή όλων των πινάκων
DROP TABLE IF EXISTS ethnic_cuisines;
DROP TABLE IF EXISTS recipe;
DROP TABLE IF EXISTS tips_for_recipe;
DROP TABLE IF EXISTS meal_types;
DROP TABLE IF EXISTS meal_type_of_recipe;
DROP TABLE IF EXISTS steps;
DROP TABLE IF EXISTS steps_of_recipe;
DROP TABLE IF EXISTS equipment;
DROP TABLE IF EXISTS equipment_of_recipe;
DROP TABLE IF EXISTS equipment_of_step;
DROP TABLE IF EXISTS food_group;
DROP TABLE IF EXISTS ingredients;
DROP TABLE IF EXISTS ingredients_of_recipe;
DROP TABLE IF EXISTS time_of_recipe;
DROP TABLE IF EXISTS themes;
DROP TABLE IF EXISTS themes_of_recipe;
DROP TABLE IF EXISTS chefs;
DROP TABLE IF EXISTS chefs_of_recipe;
DROP TABLE IF EXISTS ethnic_of_chef;
DROP TABLE IF EXISTS labels_of_recipe;
DROP TABLE IF EXISTS basic_of_recipe;
DROP TABLE IF EXISTS episodes;
DROP TABLE IF EXISTS episodes_information;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Administrators;

SET foreign_key_checks = 1;

create table ethnic_cuisines(
ethnic_id  int UNSIGNED NOT NULL AUTO_INCREMENT primary key ,
name_of_ethnic varchar(30) UNIQUE NOT NULL
);

create table recipe(
recipe_id int UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
recipe_name VARCHAR(50) ,
basic_category ENUM("savory","pastry"), 
difficulty_level INT UNSIGNED check(difficulty_level BETWEEN 1 AND 5),
short_description VARCHAR(300),
portions int NOT NULL ,
ethnic_cuisine int unsigned NOT NULL,
image varchar(100) not null, 
image_caption varchar(800) not null,
total_calories int,
CONSTRAINT FK_recipe_ethnic foreign key (ethnic_cuisine) references ethnic_cuisines(ethnic_id)
ON DELETE RESTRICT ON UPDATE CASCADE
);


create table tips_for_recipe(
tip_id int NOT NULL,
recipe int Unsigned NOT NULL,
tip_description varchar(400),
primary key( tip_id,recipe) ,
CONSTRAINT tips_for_recipe_recipe_id foreign key(recipe) references recipe(recipe_id)
ON DELETE RESTRICT ON UPDATE CASCADE
);


create table meal_types (
meal_type_id int primary key NOT NULL,
name_of_meal_type varchar(50) NOT NULL,
image varchar(150) not null ,
image_caption varchar(140) not null
);

create table meal_type_of_recipe(
recipe_id int unsigned NOT NULL,
meal_id int NOT NULL,
primary key(recipe_id,meal_id),
CONSTRAINT meal_type_of_recipe_recipe_id foreign key(recipe_id) references recipe(recipe_id)
ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT meal_type_of_recipe_meal_id foreign key(meal_id) references meal_types(meal_type_id)
ON DELETE RESTRICT ON UPDATE CASCADE
);


create table steps (
steps_id int UNSIGNED NOT NULL AUTO_INCREMENT primary key ,
step_description varchar(300) NOT NULL
);

create table steps_of_recipe(
recipe_id int unsigned NOT NULL ,
step_id int unsigned NOT NULL,
counter_for_recipe int NOT NULL,
primary key(recipe_id,step_id),
CONSTRAINT steps_of_recipe_recipe_id foreign key(recipe_id) references recipe(recipe_id)
ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT steps_of_recipe_step_id foreign key(step_id) references steps(steps_id)
ON DELETE RESTRICT ON UPDATE CASCADE
);

create table equipment (
equipment_id int UNSIGNED NOT NULL AUTO_INCREMENT primary key ,
name_of_equipment varchar(30) NOT NULL,
equipment_description varchar(300) NOT NULL,
image varchar(100) not null ,
image_caption varchar(40) not null
);

create table equipment_of_recipe(
recipe_id int unsigned NOT NULL,
equipment_id int unsigned NOT NULL,
primary key(recipe_id,equipment_id),
CONSTRAINT equipment_of_recipe_recipe_id foreign key(recipe_id) references recipe(recipe_id)
ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT equipment_of_recipe_equipment_id foreign key(equipment_id) references equipment(equipment_id)
ON DELETE RESTRICT ON UPDATE CASCADE);


create table equipment_of_step(
step_id int unsigned  NOT NULL,
equipment_id int unsigned NOT NULL,
primary key(step_id,equipment_id),
CONSTRAINT equipment_of_step_step_id foreign key(step_id) references steps(steps_id)
ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT equipment_of_step_equipment_id foreign key(equipment_id) references equipment(equipment_id)
ON DELETE RESTRICT ON UPDATE CASCADE
);

create table food_group (
food_group_id int primary key NOT NULL,
name_of_group varchar(30) NOT NULL,
description_of_group varchar(300) NOT NULL,
image varchar(100) not null, 
image_caption varchar(40) not null
);

create table ingredients (
ingredients_id int UNSIGNED NOT NULL AUTO_INCREMENT primary key ,
name_of_ingredient varchar(30) NOT NULL,
food_group int NOT NULL,
fats int NOT NULL,
protein int NOT NULL,
carb int NOT NULL,
image varchar(100) not null, 
image_caption varchar(40) not null,
CONSTRAINT ingredients_food_group foreign key (food_group) references food_group(food_group_id)
ON DELETE RESTRICT ON UPDATE CASCADE
);

create table ingredients_of_recipe(
recipe_id int unsigned NOT NULL,
ingredient_id int unsigned NOT NULL,
quantity int NOT NULL,
primary key(recipe_id,ingredient_id),
CONSTRAINT ingredients_of_recipe_recipe_id foreign key(recipe_id) references recipe(recipe_id)
ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT ingredients_of_recipe_ingredient_id foreign key(ingredient_id) references ingredients(ingredients_id)
ON DELETE RESTRICT ON UPDATE CASCADE
);


create table time_of_recipe (
recipe_id int unsigned  NOT NULL,
preparation_time_in_minutes int  NOT NULL,
cooking_time_in_minutes int NOT NULL,
total_time_in_minutes int  ,
primary key (recipe_id),
CONSTRAINT time_of_recipe_recipe_id foreign key(recipe_id) references recipe(recipe_id)
ON DELETE RESTRICT ON UPDATE CASCADE 
);

create table themes(
themes_id int UNSIGNED NOT NULL AUTO_INCREMENT primary key ,
name_of_themes varchar(30) NOT NULL,
description_of_themes varchar(300) NOT NULL,
image varchar(100) not null,
image_caption varchar(800) not null
);

create table themes_of_recipe(
recipe int unsigned NOT NULL,
theme_id int unsigned  NOT NULL,
primary key(recipe,theme_id),
CONSTRAINT themes_of_recipe_recipe_id foreign key(recipe) references recipe(recipe_id)
ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT themes_of_recipe_theme_id  foreign key(theme_id) references themes(themes_id)
ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE TABLE chefs (
chefs_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(30) NOT NULL,
last_name VARCHAR(30) NOT NULL,
phone_number BIGINT UNIQUE NOT NULL CHECK (phone_number BETWEEN 6900000000 AND 6999999999),
date_of_birth DATE NOT NULL,
age int unsigned,
years_of_experience INT NOT NULL,
image VARCHAR(100) NOT NULL ,
image_caption VARCHAR(800) NOT NULL,
chef_level ENUM('G CHEF ', 'B CHEF', 'A CHEF', 'ASSISTANT CHEF', 'MASTER CHEF')
);



create table chefs_of_recipe(
recipe_id int unsigned NOT NULL ,
chef_id int unsigned  NOT NULL,
primary key(recipe_id,chef_id),
CONSTRAINT chefs_of_recipe_recipe_id foreign key(recipe_id) references recipe(recipe_id),
CONSTRAINT chefs_of_recipe_chef_id foreign key(chef_id) references chefs(chefs_id)
);

create table ethnic_of_chef(
chef_id int unsigned NOT NULL,
ethnic_id int unsigned NOT NULL,
primary key(ethnic_id,chef_id),
CONSTRAINT ethnic_of_chef_ethnic_id foreign key(ethnic_id) references ethnic_cuisines(ethnic_id)
ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT ethnic_of_chef_chef_id foreign key(chef_id) references chefs(chefs_id)
ON DELETE RESTRICT ON UPDATE CASCADE
);


create table labels_of_recipe(
labels_of_recipe_id int UNSIGNED NOT NULL AUTO_INCREMENT ,
recipe_id int unsigned NOT NULL,
name_of_label varchar(80) NOT NULL ,
primary key(labels_of_recipe_id) ,
CONSTRAINT labels_of_recipe_recipe_id foreign key(recipe_id) references recipe(recipe_id)
ON DELETE RESTRICT ON UPDATE CASCADE,
UNIQUE KEY (recipe_id, name_of_label)
) ;

create table basic_of_recipe(
recipe_id int unsigned  NOT NULL,
basic_ingredient int unsigned  NOT NULL,
category varchar(30) NOT NULL,
primary key(recipe_id) ,
CONSTRAINT basic_of_recipe_recipe_id foreign key(recipe_id) references recipe(recipe_id)
ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT basic_of_recipe_basic_ingredient foreign key(basic_ingredient) references ingredients(ingredients_id)
ON DELETE RESTRICT ON UPDATE CASCADE
);

create table episodes(
episodes_id int UNSIGNED NOT NULL AUTO_INCREMENT,
season int UNSIGNED NOT NULL,
primary key(episodes_id,season)
);

create table episodes_information(
episode_id int unsigned NOT NULL,
season_of_episode int unsigned not null,
chef_id int unsigned NOT NULL,
role_of_chef boolean, -- role of chef = 1 μαγειρας / role of chef = 0 κριτης 
recipe int unsigned,
ethnic_cuisine int unsigned,
grade1 int check(grade1 BETWEEN 1 AND 5),
grade2 int  check(grade2 BETWEEN 1 AND 5),
grade3 int  check(grade3 BETWEEN 1 AND 5),
total_grade int UNSIGNED,
primary key (episode_id,season_of_episode,chef_id),
CONSTRAINT episodes_information_episode_id foreign key (episode_id,season_of_episode) references episodes(episodes_id,season)
ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT episodes_information_chef_id foreign key (chef_id) references chefs(chefs_id)
ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT episodes_information_recipe foreign key (recipe) references recipe(recipe_id)
ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT episodes_information_ethnic_cuisine foreign key (ethnic_cuisine) references ethnic_cuisines(ethnic_id)
ON DELETE RESTRICT ON UPDATE CASCADE
);



#indexes
CREATE UNIQUE INDEX  chef_pk ON chefs(chefs_id);
CREATE UNIQUE INDEX  recipe_pk ON recipe(recipe_id);
CREATE UNIQUE INDEX  ingredients_pk ON ingredients(ingredients_id);

CREATE INDEX name_of_recipe ON recipe(recipe_name);
CREATE INDEX name_of_chef ON chefs(first_name, last_name);
CREATE INDEX chefs_of_recipe_chefs_id ON chefs_of_recipe(chef_id);
CREATE INDEX ingredients_of_recipe_recipe_id ON ingredients_of_recipe(recipe_id);
CREATE INDEX ethnic_of_chef_chef_id ON ethnic_of_chef(chef_id);
CREATE INDEX episodes_information_chef_id ON episodes_information(chef_id);
CREATE INDEX episodes_information_ethnic ON episodes_information(ethnic_cuisine);
CREATE INDEX idx_episodes_recipe ON episodes_information(recipe);
CREATE INDEX episodes_information_season ON episodes_information(season_of_episode);
CREATE INDEX idx_recipe_id ON equipment_of_recipe(recipe_id);
CREATE INDEX meal_type_of_recipe_recipe_id ON meal_type_of_recipe(recipe_id);
CREATE INDEX steps_of_recipe_recipe_id ON steps_of_recipe(recipe_id);
CREATE INDEX idx_themes ON themes(themes_id);
CREATE INDEX idx_themes_of_recipe ON themes_of_recipe(recipe);
CREATE INDEX idx_labels_recipe ON labels_of_recipe(recipe_id, name_of_label);



#triggers
DROP TRIGGER IF EXISTS before_insert_chefs;
DELIMITER //

CREATE TRIGGER before_insert_chefs
BEFORE INSERT ON chefs
FOR EACH ROW
BEGIN
    -- Calculate the age of the chef
    SET NEW.age = TIMESTAMPDIFF(YEAR, NEW.date_of_birth, CURDATE());
    
    -- Check if years of experience is valid
    IF NEW.years_of_experience >= NEW.age THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Years of experience must be less than age';
    END IF;
END //
DELIMITER ;



DROP TRIGGER IF EXISTS enforce_max_tips;
DELIMITER //
CREATE TRIGGER enforce_max_tips
BEFORE INSERT ON tips_for_recipe
FOR EACH ROW
BEGIN
    DECLARE tip_count INT;
    SELECT COUNT(*) INTO tip_count FROM tips_for_recipe WHERE recipe = NEW.recipe;
    IF tip_count >= 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A recipe can have a maximum of 3 tips';
    END IF;
END //
DELIMITER ;



DROP TRIGGER IF EXISTS check_chef_ethnic_before_insert;
-- role of chef = 1 μαγειρας
-- role of chef = 0 κριτης  
-- ελεγχος οτι ο καθε σεφ που μπαινει με role_of_chef = 1 στο table episode_infrormation εχει ethnic το οποιο του αντιστοιχει
-- με βαση το table ethnic_of_chef
DELIMITER //
CREATE TRIGGER check_chef_ethnic_before_insert
BEFORE INSERT ON episodes_information
FOR EACH ROW
BEGIN
    DECLARE chef_ethnic_exists INT;
    IF NEW.role_of_chef = 1 THEN
    -- Check if role_of_chef is '1'
    -- IF NEW.role_of_chef = '1' THEN
        -- Check if the chef_id and ethnic_cuisine tuple exists in ethnics_of_chef
        SELECT COUNT(*) INTO chef_ethnic_exists
        FROM ethnic_of_chef
        WHERE chef_id = NEW.chef_id AND ethnic_id = NEW.ethnic_cuisine;

        -- If the tuple does not exist, raise an error
        IF chef_ethnic_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The chef_id and ethnic_cuisine tuple does not exist in ethnics_of_chef';
        END IF ;
    END IF ;
END //
DELIMITER ;



DROP TRIGGER IF EXISTS check_recipe_ethnic_before_insert;
-- ελεγχος οτι η καθε συνταγη που μπαινει με role_of_chef = 1 στο table episode_infrormation εχει ethnic το οποιο της αντιστοιχει
-- με βαση το table recipe

DELIMITER //
CREATE TRIGGER check_recipe_ethnic_before_insert
BEFORE INSERT ON episodes_information
FOR EACH ROW
BEGIN
    DECLARE recipe_ethnic_exists INT;

    -- Check if role_of_chef is '1'
    IF NEW.role_of_chef = '1' THEN
        -- Check if the combination of recipe and ethnic_cuisine exists in the recipe table
        SELECT COUNT(*) INTO recipe_ethnic_exists
        FROM recipe
        WHERE recipe_id = NEW.recipe AND ethnic_cuisine = NEW.ethnic_cuisine;

        -- If the combination does not exist, raise an error
        IF recipe_ethnic_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The combination of recipe and ethnic_cuisine does not exist in the recipe table';
        END IF;
    END IF;
END //
DELIMITER;



DROP TRIGGER IF EXISTS check_skipped_steps_before_insert;

DELIMITER //
CREATE TRIGGER check_skipped_steps_before_insert
BEFORE INSERT ON steps_of_recipe
FOR EACH ROW
BEGIN
    DECLARE last_step INT;

    -- Find the latest counter_for_recipe for the given recipe_id
    SELECT IFNULL(MAX(counter_for_recipe), 0) INTO last_step
    FROM steps_of_recipe
    WHERE recipe_id = NEW.recipe_id;

    -- If the new step is not the next in the sequence, raise an error
    IF last_step <> 0 AND NEW.counter_for_recipe <> last_step + 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Steps cannot be skipped. The new step must follow the last step in sequence.';
    END IF;

    -- If no steps yet, the first step must be 1
    IF last_step = 0 AND NEW.counter_for_recipe <> 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The first step must be 1.';
    END IF;
END //

DELIMITER ;



DROP TRIGGER IF EXISTS check_three_consecutive_episodes_chefs;
DELIMITER //

CREATE TRIGGER check_three_consecutive_episodes_chefs
AFTER INSERT ON episodes_information
FOR EACH ROW
BEGIN
    DECLARE episode_count INT DEFAULT 0;
    DECLARE latest_episode INT DEFAULT NULL;
    DECLARE second_latest_episode INT DEFAULT NULL;
    DECLARE third_latest_episode INT DEFAULT NULL;

    -- Get the latest episode where the chef is a cooking chef (role_of_chef = 1)
    SELECT episode_id
    INTO latest_episode
    FROM episodes_information 
    WHERE chef_id = NEW.chef_id 
      AND role_of_chef = 1
    ORDER BY episode_id DESC 
    LIMIT 1;

    -- Get the second latest episode
    SELECT episode_id
    INTO second_latest_episode
    FROM episodes_information 
    WHERE chef_id = NEW.chef_id 
      AND role_of_chef = 1
      AND episode_id < latest_episode 
    ORDER BY episode_id DESC 
    LIMIT 1;

    -- Get the third latest episode
    SELECT episode_id
    INTO third_latest_episode
    FROM episodes_information 
    WHERE chef_id = NEW.chef_id 
      AND role_of_chef = 1
      AND episode_id < second_latest_episode 
    ORDER BY episode_id DESC 
    LIMIT 1;

    -- Check if we have three episodes
    IF latest_episode = 1+ second_latest_episode AND second_latest_episode=1+ third_latest_episode THEN
        -- Check if the chef has participated as a cooking chef in all three episodes
        SELECT COUNT(DISTINCT episode_id)
        INTO episode_count
        FROM episodes_information
        WHERE chef_id = NEW.chef_id
          AND role_of_chef = 1
          AND episode_id IN (latest_episode, second_latest_episode, third_latest_episode);

        IF episode_count = 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Chef cannot participate as a cooking chef in three consecutive episodes.';
        END IF;
    END IF;
END //

DELIMITER ;



DROP TRIGGER IF EXISTS check_three_consecutive_episodes_judges;

DELIMITER //
CREATE TRIGGER check_three_consecutive_episodes_judges -- 3 κριτες σε 3 συνεχομενα επεισοδια
AFTER INSERT ON episodes_information
FOR EACH ROW
BEGIN
    DECLARE episode_count INT DEFAULT 0;
    DECLARE latest_episode INT DEFAULT NULL;
    DECLARE second_latest_episode INT DEFAULT NULL;
    DECLARE third_latest_episode INT DEFAULT NULL;

    -- Get the latest episode where the chef is a cooking chef (role_of_chef = 1)
    SELECT episode_id
    INTO latest_episode
    FROM episodes_information 
    WHERE chef_id = NEW.chef_id 
      AND role_of_chef = 0
    ORDER BY episode_id DESC 
    LIMIT 1;

    -- Get the second latest episode
    SELECT episode_id
    INTO second_latest_episode
    FROM episodes_information 
    WHERE chef_id = NEW.chef_id 
      AND role_of_chef = 0
      AND episode_id < latest_episode 
    ORDER BY episode_id DESC 
    LIMIT 1;

    -- Get the third latest episode
    SELECT episode_id
    INTO third_latest_episode
    FROM episodes_information 
    WHERE chef_id = NEW.chef_id 
      AND role_of_chef = 0
      AND episode_id < second_latest_episode 
    ORDER BY episode_id DESC 
    LIMIT 1;

    -- Check if we have three episodes
    IF latest_episode = 1+ second_latest_episode AND second_latest_episode=1+ third_latest_episode THEN
        -- Check if the chef has participated as a cooking chef in all three episodes
        SELECT COUNT(DISTINCT episode_id)
        INTO episode_count
        FROM episodes_information
        WHERE chef_id = NEW.chef_id
          AND role_of_chef = 0
          AND episode_id IN (latest_episode, second_latest_episode, third_latest_episode);

        IF episode_count = 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Judge cannot participate as a cooking chef in three consecutive episodes.';
        END IF;
    END IF;
END //
DELIMITER ;



DROP TRIGGER IF EXISTS check_three_consecutive_episodes_ethnic_cuisine;
DELIMITER //
CREATE TRIGGER check_three_consecutive_episodes_ethnic_cuisine
AFTER INSERT ON episodes_information
FOR EACH ROW
BEGIN
    DECLARE episode_count INT DEFAULT 0;
    DECLARE latest_episode INT DEFAULT NULL;
    DECLARE second_latest_episode INT DEFAULT NULL;
    DECLARE third_latest_episode INT DEFAULT NULL;

    -- Get the latest episode where the ethnic cuisine appears
    SELECT episode_id
    INTO latest_episode
    FROM episodes_information 
    WHERE ethnic_cuisine = NEW.ethnic_cuisine 
    ORDER BY episode_id DESC 
    LIMIT 1;

    -- Get the second latest episode
    SELECT episode_id
    INTO second_latest_episode
    FROM episodes_information 
    WHERE ethnic_cuisine = NEW.ethnic_cuisine 
      AND episode_id < latest_episode 
    ORDER BY episode_id DESC 
    LIMIT 1;

    -- Get the third latest episode
    SELECT episode_id
    INTO third_latest_episode
    FROM episodes_information 
    WHERE ethnic_cuisine = NEW.ethnic_cuisine 
      AND episode_id < second_latest_episode 
    ORDER BY episode_id DESC 
    LIMIT 1;

    -- Check if we have three consecutive episodes
    IF latest_episode = second_latest_episode + 1 AND second_latest_episode = third_latest_episode + 1 THEN
        -- Check if the ethnic cuisine appears in all three episodes
        SELECT COUNT(DISTINCT episode_id)
        INTO episode_count
        FROM episodes_information
        WHERE ethnic_cuisine = NEW.ethnic_cuisine
          AND episode_id IN (latest_episode, second_latest_episode, third_latest_episode);

        IF episode_count = 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ethnic cuisine cannot appear in three consecutive episodes.';
        END IF;
    END IF;
END //

DELIMITER ;




-- Authorization
DROP VIEW IF EXISTS my_recipes;
DROP VIEW IF EXISTS my_chef;

CREATE VIEW my_recipes AS 
SELECT 
    r.recipe_id,
    r.recipe_name, 
    r.basic_category, 
    r.difficulty_level,
    r.short_description, 
    r.portions, 
    r.ethnic_cuisine, 
    r.image,
    r.image_caption,
    r.total_calories
FROM 
    recipe AS r 
INNER JOIN 
    chefs_of_recipe AS cr 
ON 
    cr.recipe_id = r.recipe_id
WHERE
	cr.chef_id = 50;


CREATE VIEW my_chef AS 
SELECT *  
FROM chefs
WHERE chefs_id = 50;


DROP USER IF EXISTS 'admin'@'localhost';
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin';
GRANT ALL PRIVILEGES ON masterchef.* TO 'admin'@'localhost' WITH GRANT OPTION;


DROP USER IF EXISTS 'chef'@'localhost';
CREATE USER 'chef'@'localhost' IDENTIFIED BY 'chef';

GRANT ALL PRIVILEGES ON masterchef.my_recipes TO 'chef'@'localhost';
GRANT ALL PRIVILEGES ON masterchef.my_chef TO 'chef'@'localhost';



DROP PROCEDURE IF EXISTS InsertOrUpdateRecipe;
DELIMITER //
CREATE PROCEDURE InsertOrUpdateRecipe(
    IN chef_id INT UNSIGNED,
    IN recipe_name VARCHAR(50),
    IN basic_category ENUM("savory","pastry"),
    IN difficulty_level INT UNSIGNED,
    IN short_description VARCHAR(300),
    IN portions INT,
    IN ethnic_cuisine INT UNSIGNED,
    IN image VARCHAR(100),
    IN image_caption VARCHAR(800),
    IN total_calories INT
)
BEGIN
    DECLARE recipe_id INT;

    -- Check if the recipe already exists
    SELECT r.recipe_id INTO recipe_id
    FROM recipe r
    WHERE r.recipe_name = recipe_name;

    IF recipe_id IS NULL THEN
        -- If the recipe doesn't exist, insert it into the recipe table
        INSERT INTO recipe (recipe_name, basic_category, difficulty_level, short_description, portions, ethnic_cuisine, image, image_caption, total_calories)
        VALUES (recipe_name, basic_category, difficulty_level, short_description, portions, ethnic_cuisine, image, image_caption, total_calories);
        SET recipe_id = LAST_INSERT_ID();
    END IF;
    INSERT IGNORE INTO chefs_of_recipe (recipe_id, chef_id) VALUES (recipe_id, chef_id);
END //
DELIMITER ;

GRANT EXECUTE ON PROCEDURE masterchef.InsertOrUpdateRecipe TO 'chef'@'localhost';



DROP PROCEDURE IF EXISTS UpdateChefInfo;
DELIMITER //
CREATE PROCEDURE UpdateChefInfo(
    IN _user_id INT UNSIGNED,
    IN _first_name VARCHAR(30),
    IN _last_name VARCHAR(30),
    IN _phone_number BIGINT,
    IN _date_of_birth DATE,
    IN _years_of_experience INT,
    IN _image VARCHAR(100),
    IN _image_caption VARCHAR(800),
    IN _chef_level ENUM('G CHEF ', 'B CHEF', 'A CHEF', 'ASSISTANT CHEF', 'MASTER CHEF')
)
BEGIN
    DECLARE _chef_id INT UNSIGNED;

    -- Fetch the chef_id associated with the given user_id
    SELECT chefs_id INTO _chef_id FROM chefs WHERE user_id = _user_id;

    -- Update chef information if the chef_id matches the logged-in user
    IF _chef_id IS NOT NULL THEN
        UPDATE chefs
        SET first_name = _first_name,
            last_name = _last_name,
            phone_number = _phone_number,
            date_of_birth = _date_of_birth,
            years_of_experience = _years_of_experience,
            image = _image,
            image_caption = _image_caption,
            chef_level = _chef_level
        WHERE chefs_id = _chef_id;
        
        SELECT 'Chef information updated successfully.';
    ELSE
        SELECT 'Chef information not found for the logged-in user.';
    END IF;
END //
DELIMITER ;

GRANT EXECUTE ON PROCEDURE masterchef.UpdateChefInfo TO 'chef'@'localhost';
