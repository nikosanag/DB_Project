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
DELETE FROM cooks_recipes_per_episode;
DELETE FROM episodes_per_year;

CREATE TABLE judges (
current_year INT(11) ,
episode_number INT(11) ,
cook_id INT(11),
PRIMARY KEY (current_year,episode_number,cook_id),
CONSTRAINT f_key_judges_cooks FOREIGN KEY (cook_id) REFERENCES cooks(cook_id), 
CONSTRAINT f_key_judges_episodes_per_year FOREIGN KEY (current_year,episode_number) REFERENCES episodes_per_year(current_year,episode_number)
);

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
                                                    (cook_id IN (SELECT cook_id FROM security_purposes_cooks WHERE triggering_number<3)) 
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
											INSERT INTO judges(current_year,episode_number,cook_id) SELECT DISTINCT count_years,count_episodes,cook_id FROM available_cooks JOIN cooks USING(cook_id) WHERE (cook_category='Chef' AND cook_id IN (SELECT cook_id FROM security_purposes_cooks WHERE triggering_number<3)) ORDER BY RAND() LIMIT 3;
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
                                            SELECT count_years,count_episodes, cook_id
                                            FROM(
                                            SELECT cook_id,SUM(grade) total_grade
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
                                            LIMIT 1) tempora
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
DROP TABLE judges;
END;
//
DELIMITER ;

CALL build_contest(2020,2024);

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1053x1502", image_of_episode_desc = "Involve option yard affect leg one."
WHERE current_year = 2020 AND episode_number = 1;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1332x1337", image_of_episode_desc = "Case suffer be tend."
WHERE current_year = 2020 AND episode_number = 2;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1880x1976", image_of_episode_desc = "Friend main contain art owner challenge a step."
WHERE current_year = 2020 AND episode_number = 3;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1489x1594", image_of_episode_desc = "Support than who end in for degree lead."
WHERE current_year = 2020 AND episode_number = 4;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1085x1736", image_of_episode_desc = "While become so then run."
WHERE current_year = 2020 AND episode_number = 5;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1227x1500", image_of_episode_desc = "Believe ball manager."
WHERE current_year = 2020 AND episode_number = 6;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1779x1448", image_of_episode_desc = "Item carry art."
WHERE current_year = 2020 AND episode_number = 7;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1216x1760", image_of_episode_desc = "Order increase wide event candidate news market."
WHERE current_year = 2020 AND episode_number = 8;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1226x1938", image_of_episode_desc = "Hit remain rest."
WHERE current_year = 2020 AND episode_number = 9;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1037x1579", image_of_episode_desc = "Tend use alone space."
WHERE current_year = 2020 AND episode_number = 10;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1636x1362", image_of_episode_desc = "Evidence enter number provide audience four."
WHERE current_year = 2021 AND episode_number = 1;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1146x1923", image_of_episode_desc = "Wind on require agree decade however."
WHERE current_year = 2021 AND episode_number = 2;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1343x1272", image_of_episode_desc = "Here parent song."
WHERE current_year = 2021 AND episode_number = 3;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1800x1018", image_of_episode_desc = "Area girl age artist."
WHERE current_year = 2021 AND episode_number = 4;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1751x1827", image_of_episode_desc = "Old many move return represent."
WHERE current_year = 2021 AND episode_number = 5;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1951x1306", image_of_episode_desc = "Standard major environment color maybe power lay."
WHERE current_year = 2021 AND episode_number = 6;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1859x1151", image_of_episode_desc = "Everything agent employee war."
WHERE current_year = 2021 AND episode_number = 7;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1722x1813", image_of_episode_desc = "Meeting effect friend job consider star charge."
WHERE current_year = 2021 AND episode_number = 8;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1195x1421", image_of_episode_desc = "Share friend specific certainly."
WHERE current_year = 2021 AND episode_number = 9;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1450x1894", image_of_episode_desc = "Should wife management we."
WHERE current_year = 2021 AND episode_number = 10;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1357x1883", image_of_episode_desc = "Central tough employee be half step official."
WHERE current_year = 2022 AND episode_number = 1;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1154x1964", image_of_episode_desc = "Cup enough mention purpose career itself per standard."
WHERE current_year = 2022 AND episode_number = 2;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1774x1340", image_of_episode_desc = "Trouble official race rock."
WHERE current_year = 2022 AND episode_number = 3;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1130x1034", image_of_episode_desc = "Food early scene check single food create."
WHERE current_year = 2022 AND episode_number = 4;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1908x1884", image_of_episode_desc = "Create follow camera heavy state."
WHERE current_year = 2022 AND episode_number = 5;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1365x1250", image_of_episode_desc = "After finish on he man look debate."
WHERE current_year = 2022 AND episode_number = 6;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1640x1497", image_of_episode_desc = "Cup fine policy half high sell these."
WHERE current_year = 2022 AND episode_number = 7;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1046x1432", image_of_episode_desc = "Nice throughout rise condition gas could town clear."
WHERE current_year = 2022 AND episode_number = 8;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1136x1784", image_of_episode_desc = "Minute down line."
WHERE current_year = 2022 AND episode_number = 9;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1072x1102", image_of_episode_desc = "Player benefit identify term gun."
WHERE current_year = 2022 AND episode_number = 10;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1473x1592", image_of_episode_desc = "Drop fear fact suggest hard."
WHERE current_year = 2023 AND episode_number = 1;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1557x1401", image_of_episode_desc = "Economy area play act build project."
WHERE current_year = 2023 AND episode_number = 2;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1825x1639", image_of_episode_desc = "City worry understand happy."
WHERE current_year = 2023 AND episode_number = 3;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1998x1134", image_of_episode_desc = "Born arm body despite admit."
WHERE current_year = 2023 AND episode_number = 4;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1312x1106", image_of_episode_desc = "Do home reach civil effort nothing."
WHERE current_year = 2023 AND episode_number = 5;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1932x1870", image_of_episode_desc = "Rock water place federal class."
WHERE current_year = 2023 AND episode_number = 6;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1464x1639", image_of_episode_desc = "People popular guess commercial study series rule."
WHERE current_year = 2023 AND episode_number = 7;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1872x1855", image_of_episode_desc = "Support sing peace how book challenge."
WHERE current_year = 2023 AND episode_number = 8;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1302x1622", image_of_episode_desc = "Great involve at guy happen skill tell."
WHERE current_year = 2023 AND episode_number = 9;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1120x1900", image_of_episode_desc = "Person change treatment ability."
WHERE current_year = 2023 AND episode_number = 10;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1339x1022", image_of_episode_desc = "Whether task last attack time pretty address."
WHERE current_year = 2024 AND episode_number = 1;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1620x1500", image_of_episode_desc = "Sell door police court market."
WHERE current_year = 2024 AND episode_number = 2;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1978x1503", image_of_episode_desc = "Between office people."
WHERE current_year = 2024 AND episode_number = 3;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1695x1760", image_of_episode_desc = "Seem nature six realize then detail old but."
WHERE current_year = 2024 AND episode_number = 4;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1926x1302", image_of_episode_desc = "Surface speak theory trade environmental."
WHERE current_year = 2024 AND episode_number = 5;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1818x1619", image_of_episode_desc = "Certainly exist dark consider probably."
WHERE current_year = 2024 AND episode_number = 6;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1852x1528", image_of_episode_desc = "Whether another toward development."
WHERE current_year = 2024 AND episode_number = 7;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1531x1500", image_of_episode_desc = "Huge crime after between plan spring occur lose."
WHERE current_year = 2024 AND episode_number = 8;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1043x1369", image_of_episode_desc = "Statement theory actually."
WHERE current_year = 2024 AND episode_number = 9;

UPDATE episodes_per_year
SET image_of_episode = "https://dummyimage.com/1383x1377", image_of_episode_desc = "Responsibility listen for day."
WHERE current_year = 2024 AND episode_number = 10;
