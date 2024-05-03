-- CS 121 24wi: Password Management (A6 and Final Project)

-- (Provided) This function generates a specified number of characters for using as a
-- salt in passwords.
DROP FUNCTION IF EXISTS make_salt;

DELIMITER !
CREATE FUNCTION make_salt(num_chars INT)
RETURNS VARCHAR(20) NOT DETERMINISTIC NO SQL
BEGIN
    DECLARE salt VARCHAR(20) DEFAULT '';

    -- Don't want to generate more than 20 characters of salt.
    SET num_chars = LEAST(20, num_chars);

    -- Generate the salt!  Characters used are ASCII code 32 (space)
    -- through 126 ('z').
    WHILE num_chars > 0 DO
        SET salt = CONCAT(salt, CHAR(32 + FLOOR(RAND() * 95)));
        SET num_chars = num_chars - 1;
    END WHILE;

    RETURN salt;
END !
DELIMITER ;


DROP PROCEDURE IF EXISTS sp_add_user;

DELIMITER !
CREATE PROCEDURE sp_add_user(new_username VARCHAR(20), password VARCHAR(20), new_age INT)
BEGIN
    DECLARE salt VARCHAR(8);
    DECLARE password_hash CHAR(64);

    SET salt = make_salt(8);
    SET password_hash = SHA2(CONCAT(password, salt), 256);

    INSERT INTO users (username, salt, password_hash, age)
        VALUES(new_username, salt, password_hash, new_age);
END !
DELIMITER ;



DROP FUNCTION IF EXISTS authenticate;

DELIMITER !
CREATE FUNCTION authenticate(username VARCHAR(20), password VARCHAR(20))
RETURNS TINYINT DETERMINISTIC
BEGIN
    -- Variables to hold the user's salt and hashed password from the database
    DECLARE db_salt CHAR(28);
    DECLARE db_password_hash CHAR(64);
    DECLARE actual_pass CHAR(64);

    -- Select the salt and password hash from the database for the given username
    SELECT salt, password_hash INTO db_salt, db_password_hash
    FROM users u
    WHERE u.username = username;

    -- If no user is found, return 0
    IF db_salt IS NULL THEN
        RETURN 0;
    END IF;

    SET actual_pass = SHA2(CONCAT(password, db_salt), 256);

    IF actual_pass = db_password_hash THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;

END !
DELIMITER ;





DROP PROCEDURE IF EXISTS sp_change_password;

DELIMITER !
CREATE PROCEDURE sp_change_password(username VARCHAR(20), new_password VARCHAR(20))
BEGIN

    DECLARE new_salt VARCHAR(8);
    DECLARE new_password_hash CHAR(64);
    SET new_salt = make_salt(8);

    SET new_password_hash = SHA2(CONCAT(new_password, new_salt), 256);
    UPDATE user_info
    SET salt = new_salt,
        password_hash = new_password_hash
    WHERE username = username;
END !
DELIMITER ;


