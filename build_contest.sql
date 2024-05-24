SET sql_mode = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION';

SET SQL_SAFE_UPDATES = 0; 

DELIMITER // 
CREATE PROCEDURE build_contest(IN starting_year INT(11),IN ending_year INT(11))
BEGIN
DECLARE count_years INT(11);
DECLARE count_episodes INT(11);
DECLARE count_places INT(11);
DECLARE cook_id_to_enter INT(11);
DECLARE national_cuisine_to_enter VARCHAR (50);
DECLARE rec_name_to_enter VARCHAR(50); 

DELETE FROM winners;
DELETE FROM evaluation;
DELETE FROM judges;
DELETE FROM cooks_recipes_per_episode;
DELETE FROM episodes_per_year;

CREATE TABLE possible_num(
num INT(11),
PRIMARY KEY(num)
);

INSERT INTO possible_num(num) VALUE (1),(2),(3),(4),(5);

CREATE TABLE security_purposes_cooks( -- πινακας ασφαλειας που σε καθε επεισοδιο αποθηκευει το σε ποσα συνεχομενα επεισοδια εχει συμμετασχει καθε μαγειρας προκειμενου να αποτρεψει το ενδεχομενο ενας μαγειρας να μπει πανω απο 3 φορες συνεχομενα σε επεισοδια
	cook_id INT(11),
	triggering_number INT(11),
	PRIMARY KEY (cook_id)
);

CREATE TABLE security_purposes_national_cuisine( -- πινακας ασφαλειας που σε καθε επεισοδια αποθηκευει το σε ποσα συνεχομενα επεισοδια εχει μπει μια εθνικη κουζινα προκειμενου να αποτρεψει το ενδεχομενο να μπει πανω απο 3 φορες συνεχομενα σε επεισοδια
name_national VARCHAR(50),
triggering_number INT(11),
PRIMARY KEY(name_national)
);

CREATE TABLE available_cooks ( -- πινακας που κατεχει καθε στιγμη τους μαγειρες οι οποιοι σε ενα συγκεκριμενο επεισοδιο δεν εχουνε μπει ακομα *δεν διασφαλιζει οτι οσοι ειναι μεσα επιτρεπονται να μπουν ,αυτο γινεται με την βοηθεια του security_purposes_cooks
	cook_id INT(11),
	national_cuisine VARCHAR(50),
	PRIMARY KEY(cook_id,national_cuisine)
);

CREATE TABLE available_recipes( -- πινακας που περιεχει τις διαθεσιμες συνταγες *δεν χρειαζεται καποιο ειδος ασφαλειας καθως καθε συνταγη ανηκει σε μια εθνικη κουζινα και θα διασφαλιστει οτι μια εθνικη κουζινα δεν θα μπορει να μπει για πανω απο τρια συνεχομενα επεισοδια
	rec_name VARCHAR(50),
	national_cuisine VARCHAR(50), 
	PRIMARY KEY(rec_name)
);

CREATE TABLE available_national_cuisines(-- πινακας που κατεχει καθε στιγμη τις εθνικες κουζινες οι οποιες σε ενα συγκεκριμενο επεισοδιο δεν εχουνε μπει ακομα *δεν διασφαλιζει οτι οσες ειναι μεσα επιτρεπονται να μπουν ,αυτο γινεται με την βοηθεια του security_purposes_national_cuisines
national_cuisine VARCHAR(50),
PRIMARY KEY (national_cuisine)
);

INSERT INTO security_purposes_cooks(cook_id,triggering_number) -- εκκινηση του πινακα ασφαλειας για μαγειρες.Μπαινουν ολοι οι μαγειρες με triggering number = 0
SELECT  DISTINCT cook_id,0 FROM cooks ;

INSERT INTO security_purposes_national_cuisine(name_national,triggering_number) -- εκκινηση του πινακα ασφαλειας για εθνικες κουζινες.Μπαινουν ολοι οι μαγειρες με triggering number = 0
SELECT DISTINCT type_of_national_cuisine_that_belongs_to,0 FROM cooks_belongs_to_national_cuisine;

SET count_years = starting_year ;


INSERT INTO available_recipes(rec_name,national_cuisine) -- φορτωση ολων των συνταγων στο πινακα αυτον  
SELECT DISTINCT rec_name,national_cuisine FROM recipe ;
			
            WHILE (count_years <= ending_year) DO
				BEGIN
						SET count_episodes = 1;
                        WHILE (count_episodes <= 10) DO
									BEGIN    
											
											SET count_places = 1;
											
                                            INSERT INTO episodes_per_year(current_year,episode_number) VALUE (count_years,count_episodes); 
                                            
                                            INSERT INTO available_cooks(cook_id,national_cuisine) -- σε καθε αρχη επεισοδιου μπαινουν ξανα ολοι οι μαγειρες σε αυτον τον πινακα 
                                            SELECT  cook_id,type_of_national_cuisine_that_belongs_to FROM cooks_belongs_to_national_cuisine; 
                                            
                                          
                                            
                                            INSERT INTO available_national_cuisines(national_cuisine) -- σε καθε αρχη επεισοδιου μπαινουν ξανα ολες οι εθνικες κουζινες που εχουν τλχστ εναν μαγειρα μεσα στον πινακα
                                            SELECT  DISTINCT type_of_national_cuisine_that_belongs_to FROM cooks_belongs_to_national_cuisine;
                                            
                                            WHILE (count_places<=10) DO 
													BEGIN
                                                    
                                                    SET national_cuisine_to_enter = -- επιλεγεται τυχαια εθνικη κουζινα που δεν εχει μπει στα προηγουμενα 3 επεισοδια και που επισης διαθετει ενα μαγειρα εκπροσωπο της που επισης δεν εχει συμμετασχει στα προηγουμενα τρια επεισοδια.
                                                    (
                                                    SELECT national_cuisine FROM available_national_cuisines 
                                                    WHERE 
                                                    national_cuisine IN (SELECT name_national FROM security_purposes_national_cuisine WHERE triggering_number<3)
                                                    AND 
                                                    national_cuisine IN (SELECT national_cuisine FROM available_cooks WHERE cook_id IN (SELECT cook_id FROM security_purposes_cooks WHERE triggering_number<3)) 
													ORDER BY RAND()
                                                    LIMIT 1 
                                                    );
                                                    
                                                    UPDATE security_purposes_national_cuisine SET triggering_number = triggering_number+1 -- ανανεωνει το triggering number της εθνικης κουζινας που επελεξε και το αυξανει κατα 1 
                                                    WHERE name_national = national_cuisine_to_enter ;
                                                    
                                                    DELETE FROM available_national_cuisines WHERE national_cuisine = national_cuisine_to_enter; -- το διαγραφει απο το available_national_cuisines για να μην ξαναεπιλεχθει στο ιδιο επεισοδια
                                                    
											        SET cook_id_to_enter = -- επιλεγει τυχαια εναν μαγειρα εκπροσωπο της εθνικης κουζινας που δεν εχει συμμετασχει στα προηγουμενα 3 επεισοδια
                                                    (
                                                    SELECT cook_id FROM available_cooks 
                                                    WHERE 
                                                    (cook_id IN (SELECT cook_id FROM security_purposes_national_cuisine WHERE triggering_number<3)) 
													AND ((cook_id,national_cuisine_to_enter) IN (SELECT cook_id,national_cuisine FROM available_cooks))
                                                    ORDER BY RAND()
                                                    LIMIT 1
                                                    );
                                                    
                                                    UPDATE security_purposes_cooks SET triggering_number = triggering_number + 1 WHERE cook_id = cook_id_to_enter; -- προσθετει κατα 1 το triggering number του μαγειρα που επιλεχθηκε
                                                    
                                                    DELETE FROM available_cooks WHERE cook_id = cook_id_to_enter; -- διαγραφει τον μαγειρα για να μην ξαναεπιλεχθει στο ιδιο επεισοδιο 
                                                    
                                                    SET rec_name_to_enter = -- επιλεγει τυχαια μια συνταγη που να ανηκει στην εθνικη κουζινα που επιλεχθηκε και που αρα μπορει να μαγειρεψει ο μαγειρας που επιλεχθηκε
                                                    (
                                                    SELECT rec_name FROM available_recipes 
                                                    WHERE national_cuisine = national_cuisine_to_enter 
                                                    ORDER BY RAND()
                                                    LIMIT 1
                                                    );
                                                    
                                                    /*INSERT INTO cooks_recipes_per_episode_(current_year,episode_number,national_cuisine,rec_name,cook_id) 
                                                    VALUE (count_years,count_episodes,national_cuisine_to_enter,rec_name_to_enter,cook_id_to_enter);
                                                    */
                                                    INSERT INTO cooks_recipes_per_episode(current_year,episode_number,rec_name,cook_id) -- μπαινουν τα επιλεχθεντα στον κεντρικο πινακα της βασης που δειχνει τους διαγωνιζομενους  και τις συνταγες σε καθε επεισοδια σε καθε χρονια 
                                                    VALUE (count_years,count_episodes,rec_name_to_enter,cook_id_to_enter); 
                                                    
                                                    SET count_places = count_places + 1; 
                                                    END;
                                                    END WHILE; 
                                                    
                                            
                                            -- επιλεγει judges μαγειρες που δεν συμμετειχαν στο τρεχων επεισοδιο και δεν εχουν συμμετασχει στα προηγουμενα 3 επεισοδια συνεχομενα 
											INSERT INTO judges(current_year,episode_number,cook_id) SELECT DISTINCT count_years,count_episodes,cook_id FROM available_cooks WHERE (cook_id IN (SELECT cook_id FROM security_purposes_cooks WHERE triggering_number<3)) ORDER BY RAND() LIMIT 3;
                                            -- ανανεωνει το triggering number του μαγειρα που επιλεχθηκε
                                            UPDATE security_purposes_cooks SET triggering_number = triggering_number + 1 WHERE cook_id IN (SELECT cook_id FROM judges WHERE current_year = count_years AND episode_number = count_episodes); 
                                            -- διαγραφεται απο τον available_cooks για να μεινουν μονο οι μαγειρες που δεν επιλεχθηκαν καθολου στο παρον επεισοδιο με κανενα τροπο
                                            DELETE FROM available_cooks WHERE cook_id IN (SELECT cook_id FROM judges WHERE current_year = count_years AND episode_number = count_episodes);
                                            
                                            INSERT INTO evaluation(current_year,episode_number,contestant_id,judge_id,grade)
                                            SELECT count_years,count_episodes, crpe.cook_id, j.cook_id,
                                            (SELECT num FROM possible_num ORDER BY RAND() LIMIT 1) 
                                            FROM cooks_recipes_per_episode crpe							
                                            JOIN
                                            judges j ON crpe.current_year = j.current_year AND j.episode_number = crpe.episode_number
                                            WHERE 
                                            crpe.current_year = count_years
                                            AND crpe.episode_number = count_episodes;
                                            
											INSERT INTO winners
                                            SELECT count_years,count_episodes,cook_id,SUM(grade) total_grade, cook_category
                                            FROM (
                                            SELECT contestant_id AS cook_id,grade
                                            FROM evaluation
                                            WHERE current_year= count_years AND episode_number = count_episodes) temp
                                            JOIN cooks USING (cook_id)
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
												) tempo USING (cook_category)
                                            GROUP BY cook_id
                                            ORDER BY total_grade DESC,level_of_cook DESC,RAND()
                                            LIMIT 1
                                            ;
                                            
                                            -- οσοι εχουν μεινει στο available_cooks παει να πει οτι δεν συμμετειχαν οποτε το triggering number τους μπορει να γινει ξανα 0 
                                            -- οσες εθνικες κουζινες μειναν στο available_national_cuisines παει να πει οτι δεν μπηκαν στο επεισοδιο οποτε το triggering number γινεται 0
											UPDATE security_purposes_cooks SET triggering_number = 0 WHERE (cook_id IN (SELECT cook_id FROM available_cooks)); 
                                            UPDATE security_purposes_national_cuisine SET triggering_number = 0 WHERE (name_national IN (SELECT national_cuisine FROM available_national_cuisines));
                                            -- διαγραφονται οι δυο προαναφερθοντες πινακες στο τελος τους επεισοδιου για να εκκινησει σωστα η διαδικασια για το επομενο επεισοδιο
                                            DELETE FROM available_cooks;
                                            DELETE FROM available_national_cuisines;
                                            
											SET count_episodes = count_episodes + 1;
                                    END;
                                    END WHILE;
                        
						SET count_years = count_years+1;
				END;
				END WHILE;



DROP TABLE possible_num;
DROP TABLE  security_purposes_cooks;
DROP TABLE security_purposes_national_cuisine;
DROP TABLE available_national_cuisines;
DROP TABLE available_recipes;
DROP TABLE available_cooks;
END;
//
DELIMITER ;

CALL build_contest(2020,2024);