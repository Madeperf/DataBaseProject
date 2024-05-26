DROP PROCEDURE IF EXISTS CHECK_IF_EPISODE_IS_CORRECT;
DELIMITER //

CREATE PROCEDURE CHECK_IF_EPISODE_IS_CORRECT(IN episode INT, IN season INT, OUT flag_parameter BOOLEAN)
BEGIN
    DECLARE x INT;
    DECLARE y INT;
    DECLARE z INT;

    -- Must be 10  
    SELECT COUNT(DISTINCT T.chef_id) INTO x
    FROM episodes_information AS T
    WHERE T.season_of_episode = season AND T.episode_id = episode AND T.role_of_chef = 1;

    -- Must be 3
    SELECT COUNT(DISTINCT T.chef_id) INTO y
    FROM episodes_information AS T
    WHERE T.season_of_episode = season AND T.episode_id = episode AND T.role_of_chef = 0;

    -- Must be 10
    SELECT COUNT(DISTINCT T.ethnic_cuisine) INTO z
    FROM episodes_information AS T
    WHERE T.episode_id = episode AND T.season_of_episode = season;

    -- Check the conditions and raise errors if they are not met
    IF x <> 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Incorrect number of chefs with role 1. Expected 10.';
    END IF;

    IF y <> 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Incorrect number of chefs with role 0. Expected 3.';
    END IF;

    IF z <> 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Incorrect number of distinct ethnic cuisines. Expected 10.';
    END IF;

    -- If all conditions are met, set flag_parameter to TRUE
    SET flag_parameter = TRUE;
END //

DELIMITER ;



DROP PROCEDURE IF EXISTS CHECK_IF_SEASON_IS_CORRECT ;
DELIMITER //
CREATE PROCEDURE CHECK_IF_SEASON_IS_CORRECT(in season int, out flag_parameter bool)
BEGIN
declare x int;
   
select count(distinct T.episodes_id) into x
from episodes as T
where T.season = season;
   
    if x <> 10    then
    SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Incorrect number of episodes. Expected 10.';
    END IF;

    -- If all conditions are met, set flag_parameter to TRUE
    SET flag_parameter = TRUE;
END //
DELIMITER ;



-- Ενημερωση συνολικων θερμίδων

UPDATE recipe R
JOIN (
    SELECT R.recipe_id, 
           SUM(((0.0004 * N.carb * RI.quantity) / R.portions) +
               ((0.0009 * N.fats * RI.quantity) / R.portions) +
               ((0.0004 * N.protein * RI.quantity) / R.portions)) AS total_calories
    FROM recipe R
    JOIN ingredients_of_recipe RI ON R.recipe_id = RI.recipe_id
    JOIN ingredients N ON RI.ingredient_id = N.ingredients_id
    GROUP BY R.recipe_id
) AS calorie_summary
ON R.recipe_id = calorie_summary.recipe_id
SET R.total_calories = calorie_summary.total_calories;


DROP PROCEDURE IF EXISTS calculate_winner_chef;
DELIMITER //

CREATE PROCEDURE calculate_winner_chef(
    IN p_episode_id INT,
    IN p_season INT,
    OUT p_winner_chef_id INT,
    OUT p_first_name VARCHAR(30),
    OUT p_last_name VARCHAR(30),
    OUT p_phone_number BIGINT,
    OUT p_chef_level VARCHAR(20)
)
BEGIN
    DECLARE max_grade INT;
    DECLARE max_level_value INT;
    DECLARE tie_count INT;

    -- Find the highest total_grade in the episode
    SELECT MAX(total_grade) INTO max_grade
    FROM episodes_information
    WHERE episode_id = p_episode_id AND season_of_episode = p_season AND role_of_chef = '1';

    -- Find the highest chef_level among those with the highest total_grade, using a numeric value for comparison
    SELECT MAX(CASE c.chef_level
                 WHEN 'MASTER CHEF' THEN 5
                 WHEN 'ASSISTANT CHEF' THEN 4
                 WHEN 'A CHEF' THEN 3
                 WHEN 'B CHEF' THEN 2
                 WHEN 'G CHEF' THEN 1
               END) INTO max_level_value
    FROM episodes_information ei
    JOIN chefs c ON ei.chef_id = c.chefs_id
    WHERE ei.episode_id = p_episode_id AND ei.season_of_episode = p_season AND ei.role_of_chef = '1' AND ei.total_grade = max_grade;

    -- Check if there is a tie in total_grade and chef_level
    SELECT COUNT(*) INTO tie_count
    FROM episodes_information ei
    JOIN chefs c ON ei.chef_id = c.chefs_id
    WHERE ei.episode_id = p_episode_id AND ei.season_of_episode = p_season AND ei.role_of_chef = '1' AND ei.total_grade = max_grade
    AND (CASE c.chef_level
          WHEN 'MASTER CHEF' THEN 5
          WHEN 'ASSISTANT CHEF' THEN 4
          WHEN 'A CHEF' THEN 3
          WHEN 'B CHEF' THEN 2
          WHEN 'G CHEF' THEN 1
         END) = max_level_value;

    -- If there's a tie, select one winner randomly
    IF tie_count > 1 THEN
        SELECT ei.chef_id INTO p_winner_chef_id
        FROM episodes_information ei
        JOIN chefs c ON ei.chef_id = c.chefs_id
        WHERE ei.episode_id = p_episode_id AND ei.season_of_episode = p_season AND ei.role_of_chef = '1' AND ei.total_grade = max_grade
        AND (CASE c.chef_level
              WHEN 'MASTER CHEF' THEN 5
              WHEN 'ASSISTANT CHEF' THEN 4
              WHEN 'A CHEF' THEN 3
              WHEN 'B CHEF' THEN 2
              WHEN 'G CHEF' THEN 1
             END) = max_level_value
        ORDER BY RAND()
        LIMIT 1;
    ELSE
        -- If there's no tie, select the chef with the highest grade and level
        SELECT ei.chef_id INTO p_winner_chef_id
        FROM episodes_information ei
        JOIN chefs c ON ei.chef_id = c.chefs_id
        WHERE ei.episode_id = p_episode_id AND ei.season_of_episode = p_season AND ei.role_of_chef = '1' AND ei.total_grade = max_grade
        AND (CASE c.chef_level
              WHEN 'MASTER CHEF' THEN 5
              WHEN 'ASSISTANT CHEF' THEN 4
              WHEN 'A CHEF' THEN 3
              WHEN 'B CHEF' THEN 2
              WHEN 'G CHEF' THEN 1
             END) = max_level_value
        LIMIT 1;
    END IF;

    -- Retrieve the additional attributes of the winning chef
    SELECT c.first_name, c.last_name, c.phone_number, c.chef_level
    INTO p_first_name, p_last_name, p_phone_number, p_chef_level
    FROM chefs c
    WHERE c.chefs_id = p_winner_chef_id;

END //

DELIMITER ;




-- Declare session variables to hold the output
SET @winner_chef_id = NULL;
SET @first_name = NULL;
SET @last_name = NULL;
SET @phone_number = NULL;
SET @chef_level = NULL;

-- Call the procedure with appropriate parameters
CALL calculate_winner_chef(1, 1, @winner_chef_id, @first_name, @last_name, @phone_number, @chef_level);

-- Retrieve the output values
SELECT @winner_chef_id AS winner_chef_id, 
       @first_name AS first_name, 
       @last_name AS last_name, 
       @phone_number AS phone_number, 
       @chef_level AS chef_level;









