#1--------------------------------------------------------------------------------------------------------------------------------------
-- =====================================================================================================================================
SELECT 
    chef_id,
    AVG(total_grade) AS average_total_grade_of_chef
FROM (
    SELECT 
        ei.chef_id AS chef_id,
        ei.total_grade AS total_grade
    FROM
        episodes_information ei
    WHERE
        ei.chef_id IS NOT NULL
) AS chef_episodes
GROUP BY
    chef_id;

SELECT 
    ethnic_cuisine_id,
    AVG(total_grade) AS average_total_grade_of_ethnic_cuisine
FROM (
    SELECT 
        eoc.ethnic_id AS ethnic_cuisine_id,
        ei.total_grade AS total_grade
    FROM
        ethnic_of_chef eoc
    JOIN
        episodes_information ei ON eoc.chef_id = ei.chef_id
    WHERE
        eoc.ethnic_id IS NOT NULL
) AS ethnic_cuisine_episodes
GROUP BY
    ethnic_cuisine_id;
    
#2---------------------------------------------------------------------------------------------------------------------------------------
-- ======================================================================================================================================

-- μάγειρες που ανήκουν στην εθνική κουζίνα Mexican
SELECT c.*
FROM chefs c
JOIN ethnic_of_chef eoc ON c.chefs_id = eoc.chef_id
JOIN ethnic_cuisines ec ON eoc.ethnic_id = ec.ethnic_id
WHERE ec.name_of_ethnic = 'Mexican';

-- μάγειρες που ανήκουν στην εθνική κουζίνα Mexican και εμφανίζονται σε κάποιο επεισόδιο της σεζόν 1
SELECT DISTINCT c.*
FROM chefs c
JOIN ethnic_of_chef eoc ON c.chefs_id = eoc.chef_id
JOIN ethnic_cuisines ec ON eoc.ethnic_id = ec.ethnic_id
JOIN episodes_information ei ON c.chefs_id = ei.chef_id
JOIN episodes e ON ei.episode_id = e.episodes_id AND ei.season_of_episode = e.season
WHERE ec.name_of_ethnic = 'Mexican'
AND e.season = 1;


#3-------------------------------------------------------------------------------------------------------------------------------------------
-- ==========================================================================================================================================
SELECT 
    c.chefs_id AS chef_id,
    CONCAT(c.first_name, ' ', c.last_name) AS chef_name,
    TIMESTAMPDIFF(YEAR, c.date_of_birth, CURDATE()) AS chef_age,
    COUNT(r.recipe_id) AS recipes_count
FROM 
    chefs c
LEFT JOIN 
    chefs_of_recipe cr ON c.chefs_id = cr.chef_id
LEFT JOIN 
    recipe r ON cr.recipe_id = r.recipe_id
GROUP BY 
    c.chefs_id, c.first_name, c.last_name, c.date_of_birth
HAVING 
    chef_age < 30
ORDER BY 
    recipes_count DESC;
    
-- 4------------------------------------------------------------------------------------------------------------------------------------
-- =====================================================================================================================================
SELECT chefs_id, first_name, last_name
FROM chefs
WHERE NOT EXISTS (
    SELECT 1
    FROM episodes_information
    WHERE chefs_id = chef_id
    AND role_of_chef = 0
);

-- 5 -------------------------------------------------------------------------------------------------------------------------------
-- =================================================================================================================================
SELECT 
    judge1_id,
    judge2_id,
    appearance_count
FROM (
    SELECT 
        t1.chef_id AS judge1_id,
        t2.chef_id AS judge2_id,
        COUNT(*) AS appearance_count
    FROM 
        episodes_information t1
    JOIN 
        episodes_information t2 
        ON t1.episode_id = t2.episode_id 
        AND t1.season_of_episode = t2.season_of_episode
        AND t1.chef_id < t2.chef_id
    WHERE 
        t1.role_of_chef = 0
        AND t2.role_of_chef = 0
        AND t1.season_of_episode = 2
    GROUP BY 
        t1.chef_id, t2.chef_id
    HAVING 
        appearance_count > 3
) AS judge_pairs;

# 6-----------------------------------------------------------------------------------------------------------------------------------
-- -==================================================================================================================================
-- aplo 
SELECT
    l1.name_of_label AS label1,
    l2.name_of_label AS label2,
    COUNT(*) AS pair_count
FROM
    labels_of_recipe l1
JOIN
    labels_of_recipe l2 ON l1.recipe_id = l2.recipe_id AND l1.name_of_label < l2.name_of_label
JOIN
    episodes_information ei ON l1.recipe_id = ei.recipe
GROUP BY
    l1.name_of_label, l2.name_of_label
ORDER BY
    pair_count DESC
LIMIT 3;

-- force index
-- CREATE INDEX idx_labels_recipe ON labels_of_recipe(recipe_id, name_of_label);
-- CREATE INDEX idx_episodes_recipe ON episodes_information(recipe);
SELECT
    l1.name_of_label AS label1,
    l2.name_of_label AS label2,
    COUNT(*) AS pair_count
FROM
    labels_of_recipe l1 FORCE INDEX (idx_labels_recipe)
JOIN
    labels_of_recipe l2 FORCE INDEX (idx_labels_recipe)
    ON l1.recipe_id = l2.recipe_id AND l1.name_of_label < l2.name_of_label
JOIN
    episodes_information ei FORCE INDEX (idx_episodes_recipe)
    ON l1.recipe_id = ei.recipe
GROUP BY
    l1.name_of_label, l2.name_of_label
ORDER BY
    pair_count DESC
LIMIT 3;

-- exhghsh aplou 
EXPLAIN SELECT
    l1.name_of_label AS label1,
    l2.name_of_label AS label2,
    COUNT(*) AS pair_count
FROM
    labels_of_recipe l1
JOIN
    labels_of_recipe l2 ON l1.recipe_id = l2.recipe_id AND l1.name_of_label < l2.name_of_label
JOIN
    episodes_information ei ON l1.recipe_id = ei.recipe
GROUP BY
    l1.name_of_label, l2.name_of_label
ORDER BY
    pair_count DESC
LIMIT 3;

-- exhghsh force index
EXPLAIN SELECT
    l1.name_of_label AS label1,
    l2.name_of_label AS label2,
    COUNT(*) AS pair_count
FROM
    labels_of_recipe l1 FORCE INDEX (idx_labels_recipe)
JOIN
    labels_of_recipe l2 FORCE INDEX (idx_labels_recipe)
    ON l1.recipe_id = l2.recipe_id AND l1.name_of_label < l2.name_of_label
JOIN
    episodes_information ei FORCE INDEX (idx_episodes_recipe)
    ON l1.recipe_id = ei.recipe
GROUP BY
    l1.name_of_label, l2.name_of_label
ORDER BY
    pair_count DESC
LIMIT 3;

-- 7 -------------------------------------------------------------------------------------------------------------------------------------
-- =======================================================================================================================================
SELECT 
    chef_id,
    COUNT(*) AS participation_count
FROM 
    episodes_information
WHERE 
    role_of_chef = 1
GROUP BY 
    chef_id
HAVING 
    COUNT(*) <= (
        SELECT 
            MAX(participation_count) - 5
        FROM (
            SELECT 
                chef_id,
                COUNT(*) AS participation_count
            FROM 
                episodes_information
            WHERE 
                role_of_chef = 1
            GROUP BY 
                chef_id
        ) AS chef_participation_counts
);

-- o mageiras me ta perissotera
SELECT 
    chef_id,
    COUNT(*) AS participation_count
FROM 
    episodes_information
WHERE 
    role_of_chef = 1
GROUP BY 
    chef_id
HAVING 
    COUNT(*) = (
        SELECT 
            MAX(participation_count)
        FROM (
            SELECT 
                COUNT(*) AS participation_count
            FROM 
                episodes_information
            WHERE 
                role_of_chef = 1
            GROUP BY 
                chef_id
        ) AS chef_participation_counts
    );

-- 8 ------------------------------------------------------------------------------------------------------------------------------------
-- ======================================================================================================================================
-- aplo query 
SELECT 
    ei.episode_id,
    COUNT(eor.equipment_id) AS equipment_count
FROM 
    episodes_information ei
JOIN 
    equipment_of_recipe eor ON ei.recipe = eor.recipe_id
GROUP BY 
    ei.episode_id
HAVING 
    COUNT(eor.equipment_id) = (
        SELECT 
            MAX(equipment_count)
        FROM (
            SELECT 
                ei_inner.episode_id,
                COUNT(eor_inner.equipment_id) AS equipment_count
            FROM 
                episodes_information ei_inner
            JOIN 
                equipment_of_recipe eor_inner ON ei_inner.recipe = eor_inner.recipe_id
            GROUP BY 
                ei_inner.episode_id
        ) AS MaxEquipmentCounts
    )
ORDER BY 
    ei.episode_id;
    
-- 8 force index
-- CREATE INDEX idx_recipe_id ON equipment_of_recipe(recipe_id);
-- CREATE INDEX idx_episodes_recipe ON episodes_information(recipe);

SELECT 
    ei.episode_id,
    COUNT(eor.equipment_id) AS equipment_count
FROM 
    episodes_information ei FORCE INDEX (idx_episodes_recipe)
JOIN 
    equipment_of_recipe eor FORCE INDEX (idx_recipe_id) ON ei.recipe = eor.recipe_id
GROUP BY 
    ei.episode_id
HAVING 
    equipment_count = (
        SELECT 
            MAX(equipment_count)
        FROM (
            SELECT 
                COUNT(eor_inner.equipment_id) AS equipment_count
            FROM 
                episodes_information ei_inner FORCE INDEX (idx_episodes_recipe)
            JOIN 
                equipment_of_recipe eor_inner FORCE INDEX (idx_recipe_id) ON ei_inner.recipe = eor_inner.recipe_id
            GROUP BY 
                ei_inner.episode_id
        ) AS MaxEquipmentCounts
    )
ORDER BY 
    ei.episode_id;        
    
-- exhghsh force index 
EXPLAIN SELECT 
    ei.episode_id,
    COUNT(eor.equipment_id) AS equipment_count
FROM 
    episodes_information ei FORCE INDEX (idx_episodes_recipe)
JOIN 
    equipment_of_recipe eor FORCE INDEX (idx_recipe_id) ON ei.recipe = eor.recipe_id
GROUP BY 
    ei.episode_id
HAVING 
    equipment_count = (
        SELECT 
            MAX(equipment_count)
        FROM (
            SELECT 
                COUNT(eor_inner.equipment_id) AS equipment_count
            FROM 
                episodes_information ei_inner FORCE INDEX (idx_episodes_recipe)
            JOIN 
                equipment_of_recipe eor_inner FORCE INDEX (idx_recipe_id) ON ei_inner.recipe = eor_inner.recipe_id
            GROUP BY 
                ei_inner.episode_id
        ) AS MaxEquipmentCounts
    )
ORDER BY 
    ei.episode_id;
    
-- 9 ----------------------------------------------------------------------------------------------------------------------------------
-- ====================================================================================================================================
SELECT 
    ei.season_of_episode AS year,
    AVG(ir.quantity * (i.carb / 100)) AS avg_carbohydrates
FROM 
    episodes_information ei
JOIN
    ingredients_of_recipe ir ON ei.recipe = ir.recipe_id
JOIN
    ingredients i ON ir.ingredient_id = i.ingredients_id
GROUP BY 
    ei.season_of_episode
ORDER BY 
    year;
    
-- 10 ---------------------------------------------------------------------------------------------------------------------------------
-- ====================================================================================================================================
WITH temp AS (
    SELECT ei.season_of_episode, ei.ethnic_cuisine, COUNT(*) AS freq
    FROM episodes_information AS ei
    WHERE ei.role_of_chef = 1
    GROUP BY ei.season_of_episode, ei.ethnic_cuisine
), two_year_freq AS (
    SELECT t1.season_of_episode, t1.ethnic_cuisine, (t1.freq + t2.freq) AS total_freq
    FROM temp AS t1
    INNER JOIN temp AS t2 ON t1.season_of_episode = t2.season_of_episode - 1 AND t1.ethnic_cuisine = t2.ethnic_cuisine
    WHERE t1.freq >= 3 AND t2.freq >= 3
)
SELECT CONCAT(w1.season_of_episode, '-', w1.season_of_episode + 1) AS period, 
       w1.ethnic_cuisine, 
       w2.ethnic_cuisine, 
       w1.total_freq
FROM two_year_freq AS w1
INNER JOIN two_year_freq AS w2 ON w1.season_of_episode = w2.season_of_episode AND w1.ethnic_cuisine < w2.ethnic_cuisine
WHERE w1.total_freq = w2.total_freq
ORDER BY w1.total_freq DESC;

#11----------------------------------------------------------------------------------------------------------------------------------
-- ==================================================================================================================================
SELECT *
FROM (
    SELECT
        SUM(score) AS total_score, 
        contestant_id, 
        judge_id
    FROM (
        SELECT
            CASE
                WHEN ei1.grade1 IS NOT NULL THEN ei2.grade1
                WHEN ei1.grade2 IS NOT NULL THEN ei2.grade2
                WHEN ei1.grade3 IS NOT NULL THEN ei2.grade3
                ELSE 0
            END AS score,
            ei2.chef_id AS contestant_id,
            ei1.chef_id AS judge_id
        FROM
            episodes_information ei1
        INNER JOIN episodes_information ei2 
            ON ei1.season_of_episode = ei2.season_of_episode 
            AND ei1.episode_id = ei2.episode_id 
            AND ei1.role_of_chef = 0 
            AND ei2.role_of_chef = 1
    ) AS res
    GROUP BY contestant_id, judge_id
) AS temp
ORDER BY total_score DESC
LIMIT 5;


-- 12---------------------------------------------------------------------------------------------------------------------------------
-- ===================================================================================================================================
WITH difficulty_levels AS (
    SELECT 
        ei.season_of_episode,
        ei.episode_id,
        AVG(r.difficulty_level) AS avg_difficulty
    FROM episodes_information AS ei
    INNER JOIN recipe AS r ON ei.recipe = r.recipe_id
    GROUP BY ei.season_of_episode, ei.episode_id
),
max_difficulty_per_season AS (
    SELECT 
        season_of_episode,
        MAX(avg_difficulty) AS max_avg_difficulty
    FROM difficulty_levels
    GROUP BY season_of_episode
)
SELECT DISTINCT
    dl.season_of_episode,
    dl.episode_id,
    dl.avg_difficulty
FROM difficulty_levels AS dl
INNER JOIN max_difficulty_per_season AS md
    ON dl.season_of_episode = md.season_of_episode
    AND dl.avg_difficulty = md.max_avg_difficulty
ORDER BY dl.season_of_episode, dl.episode_id;

#13----------------------------------------------------------------------------------------------------------------------------------------
-- ========================================================================================================================================
WITH ranked_episodes AS (
	SELECT
	ee.season_of_episode,ee.episode_id,
	SUM(CASE
		WHEN c.chef_level = 'G CHEF' THEN 1
		WHEN c.chef_level = 'B CHEF' THEN 2
		WHEN c.chef_level = 'A CHEF' THEN 3
		WHEN c.chef_level = 'ASSISTANT CHEF' THEN 4
		WHEN c.chef_level = 'MASTER CHEF' THEN 5
		ELSE 0
	END) AS total_rank
	FROM episodes_information AS ee
	INNER JOIN chefs AS c ON ee.chef_id = c.chefs_id
	GROUP BY ee.season_of_episode, ee.episode_id
	),
min_ranked_episodes AS (
	SELECT
	MIN(total_rank) AS min_total_rank
	FROM ranked_episodes
	)
SELECT re.*
FROM ranked_episodes AS re
INNER JOIN min_ranked_episodes AS mre
ON re.total_rank = mre.min_total_rank;
-- QUERY 14---------------------------------------------------------------------------------------------------------------------------
-- ===================================================================================================================================

WITH ThemeCounts AS (
    SELECT  
        rt.name_of_themes,
        COUNT(*) AS theme_count
    FROM 
        episodes_information AS ee
    INNER JOIN 
        themes_of_recipe AS rtr ON ee.recipe = rtr.recipe
    INNER JOIN 
        themes AS rt ON rt.themes_id = rtr.theme_id
    GROUP BY  
        rt.name_of_themes
),
MaxThemeCount AS (
    SELECT 
        MAX(theme_count) AS max_count
    FROM 
        ThemeCounts
)
SELECT 
    tc.name_of_themes, 
    tc.theme_count
FROM 
    ThemeCounts tc
JOIN 
    MaxThemeCount mtc ON tc.theme_count = mtc.max_count;


-- CREATE INDEX idx_episodes_recipe ON episodes_information(recipe);
-- CREATE INDEX idx_themes_of_recipe ON themes_of_recipe(recipe);
-- CREATE INDEX idx_themes ON themes(themes_id);

-- 15-----------------------------------------------------------------------------------------------------------------------------------
-- =====================================================================================================================================

SELECT f.name_of_group 
FROM food_group AS f
WHERE f.food_group_id NOT IN (
    SELECT DISTINCT ci.food_group
    FROM episodes_information AS ee
    INNER JOIN ingredients_of_recipe AS ri ON ee.recipe = ri.recipe_id
    INNER JOIN ingredients AS ci ON ci.ingredients_id = ri.ingredient_id
);