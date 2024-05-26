-- 3.1
-- Μέση βαθμολογία ανά μάγειρα.
SELECT CONCAT(name_of_cook,' ',surname_of_cook) 'Contestant Name', avg_grade 'Avarage Grade'
FROM cooks
JOIN(
SELECT contestant_id, AVG(grade) avg_grade
FROM evaluation
GROUP BY 1) grade_of_cook ON contestant_id=cook_id;

-- Μέση βαθμολογία ανά εθνική κουζίνα.
SELECT national_cuisine 'National Cuisine', AVG(grade) 'Avarage Grade'
FROM cooks_recipes_per_episode a
JOIN recipe USING (rec_name)
JOIN evaluation b ON (a.current_year,a.episode_number,a.cook_id)=(b.current_year,b.episode_number,b.contestant_id)
GROUP BY national_cuisine;

-- 3.2
SELECT CONCAT(name_of_cook,' ',surname_of_cook) 'Cook name', 
						national_cuisine 'National Cuisine', 
                        current_year 'Year of the episode'
FROM cooks
JOIN (
		SELECT DISTINCT cook_id, national_cuisine , current_year 
		FROM cooks_recipes_per_episode
		JOIN recipe USING (rec_name)
		WHERE current_year=2020 
		AND national_cuisine='Mordovian' -- This condition is to check if the cook actually represents this national cuisine on an episode. 
		) tempor USING (cook_id)
;

-- 3.3
-- Θεωρούμε ότι η φράση, "που έχουν τις περισσότερες συνταγές",
-- σημαίνει "που έχουν εκετελέσει τις περισσότερες διαφορετικές συνταγές στον διαγωνισμό".
WITH rec_count AS (SELECT cook_id,COUNT(DISTINCT rec_name) recipe_count
					FROM cooks_recipes_per_episode
					JOIN cooks USING (cook_id)
					WHERE age<30
					GROUP BY cook_id
					) -- this subquery finds how many different recipes each cook has cooked in the competition.
SELECT CONCAT(name_of_cook,' ',surname_of_cook) 'Cook name', recipe_count
FROM rec_count
JOIN cooks USING (cook_id)
WHERE recipe_count=(SELECT MAX(recipe_count) -- keep only the cooks with the highest recipe_count (could be more than 1 cook, in case of a draw)
					FROM rec_count);


-- 3.4
SELECT CONCAT(name_of_cook,' ',surname_of_cook) 'Cooks that have never been a judge'
FROM cooks
WHERE cook_id NOT IN (SELECT judge_id
						FROM evaluation);
                        
-- 3.5
WITH appearances AS (
	SELECT current_year , judge_id, COUNT(DISTINCT episode_number) Number_of_Appearances
	FROM evaluation
	GROUP BY current_year, judge_id
	HAVING Number_of_Appearances>3
    ) -- this subquery finds the number appearances per year, of its judge that has more than 3 per year.
SELECT a.current_year, CONCAT(name_of_cook,' ',surname_of_cook) Cook_name, a.Number_of_Appearances
FROM appearances a
JOIN cooks ON cook_id=judge_id
JOIN ( SELECT current_year, Number_of_Appearances, COUNT(judge_id) apps_count
		FROM appearances
		GROUP BY current_year, Number_of_Appearances
		HAVING apps_count>1) b USING (current_year, Number_of_Appearances) -- this subquery finds which number of appearances that appear more than once.
        ;
        

-- 3.6
SELECT a_tag_name, b_tag_name, COUNT(*) Tag_Couple_Appearances
FROM(
	SELECT a.tag_name a_tag_name, b.tag_name b_tag_name
	FROM cooks_recipes_per_episode competition
	JOIN tags a USING (rec_name)
	JOIN tags b ON a.rec_name=b.rec_name AND a.tag_name<b.tag_name
) possible_couples_of_tags -- this subquery finds the possible couples of tags that appeared in the competition. 
							-- The couple is contained in the query as many times as it appears in the competition.
GROUP BY a_tag_name, b_tag_name
ORDER BY Tag_Couple_Appearances DESC
LIMIT 3;

-- Εναλλακτικό query plan #1
EXPLAIN format = json
SELECT a_tag_name, b_tag_name, COUNT(*) Tag_Couple_Appearances
FROM(
	SELECT a.tag_name a_tag_name, b.tag_name b_tag_name
	FROM cooks_recipes_per_episode competition
	JOIN tags a USING (rec_name)
	JOIN tags b IGNORE INDEX (f_key_tags_recipe) ON a.rec_name=b.rec_name AND a.tag_name<b.tag_name
) possible_couples_of_tags -- this subquery finds the possible couples of tags that appeared in the competition. 
							-- The couple is contained in the query as many times as it appears in the competition.
GROUP BY a_tag_name, b_tag_name
ORDER BY Tag_Couple_Appearances DESC
LIMIT 3;


-- Εναλλακτικό query plan #2
EXPLAIN format = json
SELECT a_tag_name, b_tag_name, COUNT(*) Tag_Couple_Appearances
FROM(
	SELECT STRAIGHT_JOIN a.tag_name a_tag_name, b.tag_name b_tag_name
	FROM cooks_recipes_per_episode competition
	JOIN tags a USING (rec_name)
	JOIN tags b IGNORE INDEX (f_key_tags_recipe) ON a.rec_name=b.rec_name AND a.tag_name<b.tag_name
) possible_couples_of_tags -- this subquery finds the possible couples of tags that appeared in the competition. 
							-- The couple is contained in the query as many times as it appears in the competition.
GROUP BY a_tag_name, b_tag_name
ORDER BY Tag_Couple_Appearances DESC
LIMIT 3;

-- 3.7
WITH cooks_apps AS(
	SELECT cook_id, COUNT(episode_number) Number_of_Appearances
	FROM cooks_recipes_per_episode
	GROUP BY cook_id) -- This subquery finds the number of appearances of each cook. 
SELECT CONCAT(name_of_cook,' ',surname_of_cook) Cook_name, Number_of_Appearances
FROM cooks_apps
JOIN cooks USING (cook_id)
HAVING Number_of_Appearances +5 <= (
	SELECT MAX(Number_of_Appearances) max_apps
	FROM cooks_apps);

-- 3.8
WITH amount AS (
	SELECT current_year, episode_number, COUNT(*) Amount_of_Equipment
	FROM cooks_recipes_per_episode force index for group by (f_key_cooks_recipes_per_episode_episodes_per_year)
	JOIN uses_equipment USING (rec_name)
	GROUP BY current_year, episode_number) -- This subquery finds the amount of equipment for each episode.
SELECT current_year, episode_number, Amount_of_Equipment
FROM amount
WHERE Amount_of_Equipment= (
	SELECT MAX(Amount_of_Equipment)
	FROM amount
    ) -- This subquery finds the max amount of equipment an episode any had.
    -- The overall query could find more than 1 episode in case of a draw. 
    -- (More than 1 episode could have the max amount of equipment)
    ;
    
    
    -- Εναλλακτικό query plan 
EXPLAIN
WITH amount AS (
	SELECT current_year, episode_number, COUNT(*) Amount_of_Equipment
	FROM uses_equipment IGNORE INDEX(PRIMARY)
	JOIN cooks_recipes_per_episode USING (rec_name)
	GROUP BY current_year, episode_number) -- This subquery finds the amount of equipment for each episode.
SELECT current_year, episode_number, Amount_of_Equipment
FROM amount
WHERE Amount_of_Equipment= (
	SELECT MAX(Amount_of_Equipment)
	FROM amount
    ) -- This subquery finds the max amount of equipment an episode any had.
    -- The overall query could find more than 1 episode in case of a draw. 
    -- (More than 1 episode could have the max amount of equipment)
   ; 

-- 3.9
SELECT current_year, AVG(grams_of_carbohydrates) 'Avarage Grams of Carbohydrates per Year'
FROM(
	SELECT current_year, grams_of_carbohydrates_per_portion*portions grams_of_carbohydrates
	FROM cooks_recipes_per_episode
	JOIN recipe USING (rec_name)) carbohydrates_of_each_recipe
GROUP BY current_year;

-- 3.10
-- Store the number of apps of each national cuisine for each year.
-- If a cuisine does not appear in a year, then number of apps will be null.
CREATE TEMPORARY TABLE nat_cus_year_apps
SELECT DISTINCT current_year, national_cuisine, Number_of_apps
FROM episodes_per_year
JOIN (
	SELECT DISTINCT national_cuisine
	FROM cooks_recipes_per_episode
	JOIN recipe USING(rec_name)
) nat_cus_appearing -- creates a table with every possible combination (year,national cuisine that has ever appeared).
LEFT JOIN (
	SELECT current_year, national_cuisine, COUNT(rec_name) Number_of_apps
	FROM(
		SELECT current_year, rec_name, national_cuisine
		FROM cooks_recipes_per_episode
		JOIN recipe USING(rec_name)
	) nat_cus_rec_per_year
	GROUP BY current_year, national_cuisine
) apps_of_nat_cus_per_year USING (current_year, national_cuisine) -- This subquery finds the cuisines that appear each year
																	-- and their apps that year.
;


-- Exclude national cuisines that do not appear at least 3 times each year.
CREATE TEMPORARY TABLE nat_cus_min_3apps_per_year
SELECT current_year, national_cuisine, Number_of_apps
FROM nat_cus_year_apps
WHERE national_cuisine NOT IN (SELECT DISTINCT national_cuisine
								FROM nat_cus_year_apps
								WHERE Number_of_apps IS NULL OR Number_of_apps <3
                                ) -- This subquery finds the national cuisines that appeared less than 3 times at least 1 year.
;


-- Find the amount of apps across 2 years of the remaining national cuisines.
CREATE TEMPORARY TABLE nat_cus_apps_per_2years
SELECT a.current_year first_year, b.current_year second_year, a.national_cuisine, a.Number_of_apps+b.Number_of_apps Number_of_apps
FROM nat_cus_min_3apps_per_year a
JOIN nat_cus_min_3apps_per_year b ON a.current_year = b.current_year-1 AND a.national_cuisine = b.national_cuisine
;

-- Keep only the cuisines that have the same amount of apps with other cuisines across two years.
SELECT DISTINCT a.first_year first_year, a.second_year second_year, 
				a.national_cuisine national_cuisine, a.Number_of_apps Number_of_apps
FROM nat_cus_apps_per_2years a
JOIN nat_cus_apps_per_2years b ON a.first_year=b.first_year AND a.national_cuisine != b.national_cuisine AND a.Number_of_apps = b.Number_of_apps 
ORDER BY first_year, Number_of_apps
;

DROP TABLE nat_cus_year_apps;
DROP TABLE nat_cus_min_3apps_per_year;
DROP TABLE nat_cus_apps_per_2years;

-- 3.11
-- Find all possible couples (judge,contestant) with their respective avarage grade and choose top 5. 
SELECT CONCAT(judge.name_of_cook,' ',judge.surname_of_cook) Judge_name,
		CONCAT(cont.name_of_cook,' ',cont.surname_of_cook) Contestant_name, 
		Avarage_grade
        FROM (
SELECT judge_id, contestant_id, AVG(grade) Avarage_grade
FROM evaluation
GROUP BY contestant_id, judge_id
ORDER BY Avarage_grade DESC
LIMIT 5
) contestant_judge_grade -- This subquery gets the job done. The outside query is to get the names instead of the ids.
JOIN cooks cont ON cont.cook_id=contestant_id
JOIN cooks judge ON judge.cook_id=judge_id
;


-- 3.12
WITH avg_level_per_episode AS (
	SELECT current_year, episode_number, AVG(level_of_diff) avg_level
	FROM(
		SELECT current_year, episode_number, level_of_diff 
		FROM cooks_recipes_per_episode
		JOIN recipe USING(rec_name)
	) a
	GROUP BY current_year, episode_number
) -- This subquery finds the avarage level of difficulty of each episode.
SELECT current_year, episode_number, avg_level
FROM avg_level_per_episode c
WHERE avg_level = (
	SELECT MAX(avg_level)
    FROM avg_level_per_episode d
    GROUP BY current_year
    HAVING d.current_year=c.current_year
) -- This subquery finds the max avarage level of difficulty any episode had for a given year (c.current_year)
;


-- 3.13
-- Δίνουμε βαρύτητα:
-- 1 στον Γ Μάγειρα
-- 2 στον Β Μάγειρα
-- 3 στον Α Μάγειρα
-- 4 στον Βοηθό Σεφ
-- 5 στον Σεφ
WITH level_of_eps AS (
	SELECT current_year, episode_number, SUM(level_of_cook) level_of_episode
	FROM(
		SELECT current_year, episode_number, level_of_cook
		FROM(
			SELECT current_year, episode_number,cook_id, cook_category
			FROM cooks_recipes_per_episode
			JOIN cooks USING (cook_id)
			UNION ALL
			SELECT DISTINCT current_year, episode_number, judge_id,cook_category
			FROM evaluation
			JOIN cooks ON cook_id=judge_id
		) cooks_categories -- This subquery finds the cook categories each episode contains (both judges and contestants)
		JOIN(
			SELECT 1 level_of_cook, 'C Cook' cook_category
			UNION
			SELECT 2 level_of_cook, 'B Cook' cook_category
			UNION
			SELECT 3 level_of_cook, 'A Cook' cook_category
			UNION
			SELECT 4 level_of_cook, "Chef's Assistant" cook_category
			UNION
			SELECT 5 level_of_cook, 'Chef' cook_category
		) category_to_level USING (cook_category) 
        -- this subquery maps each cook category to an integer representing the level of the cook.
	) levels_for_each_episode
	GROUP BY current_year, episode_number
) -- This subquery finds the level of each episode.
SELECT current_year, episode_number, level_of_episode
FROM level_of_eps
WHERE level_of_episode = (SELECT MIN(level_of_episode) FROM level_of_eps)
-- Total query might return more than 1 episode in case of a draw. 
;


-- 3.14
-- Αν μία θεματική ενότητα εμφανίζεται πάνω από 1 φορές στο ίδιο επεισόδιο, τότε θεωρούμε ότι εμφανίζεται πάνω από 1 φορά.
-- Αν δεν το θέλαμε αυτό θα μπορούσαμε να βάλουμε distinct στο subquery thematic_units_of_each_episode
WITH appearances AS (
	SELECT name_of_thematic_unit, COUNT(*) apps_num
	FROM(
		SELECT current_year, episode_number, name_of_thematic_unit
		FROM cooks_recipes_per_episode
		JOIN belongs_to_thematic_unit USING (rec_name)
	) thematic_units_of_each_episode
	GROUP BY name_of_thematic_unit
)-- this subquery finds the amount of appearances of each thematic unit.
SELECT name_of_thematic_unit, apps_num Number_of_Appearances
FROM appearances
WHERE apps_num = (SELECT MAX(apps_num) FROM appearances)
-- Total query might return more than 1 thematic unit in case of a draw. 
;



-- 3.15
SELECT name_of_food_group
FROM food_group
WHERE name_of_food_group NOT IN(
	SELECT name_of_food_group
	FROM cooks_recipes_per_episode
	JOIN recipe USING (rec_name)
	JOIN ingredients ON name_of_main_ingredient=name_of_ingredient
	JOIN food_group USING (name_of_food_group)
);




