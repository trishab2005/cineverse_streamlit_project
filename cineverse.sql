DROP DATABASE IF EXISTS cineverse;
CREATE DATABASE cineverse;
USE cineverse;

-- =========================================
-- 1. TABLES
-- =========================================

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    user_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    city VARCHAR(50),
    joined_on DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE genres (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    genre_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE directors (
    director_id INT PRIMARY KEY AUTO_INCREMENT,
    director_name VARCHAR(100) NOT NULL,
    country VARCHAR(50)
);

CREATE TABLE actors (
    actor_id INT PRIMARY KEY AUTO_INCREMENT,
    actor_name VARCHAR(100) NOT NULL,
    country VARCHAR(50),
    birth_year INT
);

CREATE TABLE movies (
    movie_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(150) NOT NULL,
    director_id INT,
    release_year INT,
    duration_min INT,
    language VARCHAR(30),
    imdb_rating DECIMAL(3,1) DEFAULT 0,
    popularity INT DEFAULT 0,
    average_user_rating DECIMAL(3,2) DEFAULT 0,
    FOREIGN KEY (director_id) REFERENCES directors(director_id)
);

CREATE TABLE movie_genres (
    movie_id INT,
    genre_id INT,
    PRIMARY KEY(movie_id, genre_id),
    FOREIGN KEY(movie_id) REFERENCES movies(movie_id),
    FOREIGN KEY(genre_id) REFERENCES genres(genre_id)
);

CREATE TABLE movie_cast (
    movie_id INT,
    actor_id INT,
    character_name VARCHAR(100),
    PRIMARY KEY(movie_id, actor_id),
    FOREIGN KEY(movie_id) REFERENCES movies(movie_id),
    FOREIGN KEY(actor_id) REFERENCES actors(actor_id)
);

CREATE TABLE streaming_platforms (
    platform_id INT PRIMARY KEY AUTO_INCREMENT,
    platform_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE movie_platform (
    movie_id INT,
    platform_id INT,
    PRIMARY KEY(movie_id, platform_id),
    FOREIGN KEY(movie_id) REFERENCES movies(movie_id),
    FOREIGN KEY(platform_id) REFERENCES streaming_platforms(platform_id)
);

CREATE TABLE ratings (
    rating_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    movie_id INT,
    rating DECIMAL(2,1) CHECK(rating BETWEEN 1 AND 5),
    rated_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, movie_id),
    FOREIGN KEY(user_id) REFERENCES users(user_id),
    FOREIGN KEY(movie_id) REFERENCES movies(movie_id)
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    movie_id INT,
    review_text TEXT,
    sentiment VARCHAR(20),
    reviewed_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(user_id),
    FOREIGN KEY(movie_id) REFERENCES movies(movie_id)
);

CREATE TABLE favorites (
    favorite_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    movie_id INT,
    added_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, movie_id),
    FOREIGN KEY(user_id) REFERENCES users(user_id),
    FOREIGN KEY(movie_id) REFERENCES movies(movie_id)
);

-- =========================================
-- 2. INDEXES
-- =========================================

CREATE INDEX idx_movie_title ON movies(title);
CREATE INDEX idx_release_year ON movies(release_year);
CREATE INDEX idx_rating_movie ON ratings(movie_id);

-- =========================================
-- 3. SAMPLE DATA
-- =========================================

INSERT INTO users(user_name,email,city) VALUES
('Rahul','rahul@mail.com','Kolkata'),
('Priya','priya@mail.com','Delhi'),
('Amit','amit@mail.com','Mumbai'),
('Sneha','sneha@mail.com','Kolkata'),
('Trisha','trisha@mail.com','Pune'),
('Arjun','arjun@mail.com','Pune');

INSERT INTO genres(genre_name) VALUES
('Action'),('Drama'),('Sci-Fi'),('Comedy'),
('Thriller'),('Romance'),('Adventure'),('Animation');

INSERT INTO directors(director_name,country) VALUES
('Christopher Nolan','UK'),
('Denis Villeneuve','Canada'),
('Rajkumar Hirani','India'),
('James Cameron','Canada'),
('Bong Joon-ho','South Korea');

INSERT INTO actors(actor_name,country,birth_year) VALUES
('Leonardo DiCaprio','USA',1974),
('Cillian Murphy','Ireland',1976),
('Timothee Chalamet','USA',1995),
('Aamir Khan','India',1965),
('Matt Damon','USA',1970),
('Song Kang-ho','South Korea',1967),
('Sam Worthington','Australia',1976),
('Ranbir Kapoor','India',1982);

INSERT INTO streaming_platforms(platform_name) VALUES
('Netflix'),('Prime Video'),('Disney+'),('JioHotstar');

INSERT INTO movies(title,director_id,release_year,duration_min,language,imdb_rating,popularity) VALUES
('Inception',1,2010,148,'English',8.8,98),
('Interstellar',1,2014,169,'English',8.7,100),
('Oppenheimer',1,2023,180,'English',8.6,95),
('Dune',2,2021,155,'English',8.0,90),
('Dune Part Two',2,2024,166,'English',8.8,99),
('3 Idiots',3,2009,171,'Hindi',8.4,97),
('PK',3,2014,153,'Hindi',8.1,91),
('Avatar',4,2009,162,'English',7.9,96),
('Parasite',5,2019,132,'Korean',8.5,94),
('Animal',3,2023,204,'Hindi',6.2,88);

INSERT INTO movie_genres VALUES
(1,3),(1,5),(2,3),(2,2),(3,2),(3,5),
(4,3),(4,7),(5,3),(5,7),(6,2),(6,4),
(7,4),(7,6),(8,3),(8,7),(9,2),(9,5),(10,1),(10,2);

INSERT INTO movie_cast VALUES
(1,1,'Cobb'),
(2,2,'Cooper'),
(3,2,'J. Robert Oppenheimer'),
(4,3,'Paul Atreides'),
(5,3,'Paul Atreides'),
(6,4,'Rancho'),
(7,4,'PK'),
(8,7,'Jake Sully'),
(9,6,'Kim Ki-taek'),
(10,8,'Ranvijay');

INSERT INTO movie_platform VALUES
(1,1),(1,2),(2,2),(3,2),(4,1),(5,1),
(6,4),(7,1),(8,3),(9,1),(10,4);

INSERT INTO ratings(user_id,movie_id,rating) VALUES
(1,1,5),(1,2,5),(1,6,4.5),
(2,1,4.5),(2,5,5),(2,9,4.5),
(3,3,5),(3,4,4),(3,8,4),
(4,6,5),(4,7,4),(4,9,5),
(5,2,4.5),(5,5,5),(5,10,3);

INSERT INTO reviews(user_id,movie_id,review_text,sentiment) VALUES
(1,1,'Mind bending masterpiece','Positive'),
(2,5,'Visually stunning science fiction','Positive'),
(3,8,'Amazing world building','Positive'),
(4,6,'Funny and emotional','Positive'),
(5,10,'Intense but divisive','Neutral');

INSERT INTO favorites(user_id,movie_id) VALUES
(1,2),(1,1),(2,5),(2,9),(3,3),(4,6),(5,5);

-- =========================================
-- 4. VIEWS
-- =========================================

CREATE VIEW movie_catalog AS
SELECT
    m.movie_id,
    m.title,
    d.director_name,
    m.release_year,
    m.duration_min,
    m.language,
    m.imdb_rating,
    m.popularity,
    ROUND(m.average_user_rating,2) AS average_user_rating,
    GROUP_CONCAT(DISTINCT g.genre_name ORDER BY g.genre_name SEPARATOR ', ') AS genres
FROM movies m
LEFT JOIN directors d ON m.director_id=d.director_id
LEFT JOIN movie_genres mg ON m.movie_id=mg.movie_id
LEFT JOIN genres g ON mg.genre_id=g.genre_id
GROUP BY m.movie_id;

CREATE VIEW user_rating_summary AS
SELECT
    u.user_id,
    u.user_name,
    COUNT(r.rating_id) AS ratings_given,
    ROUND(AVG(r.rating),2) AS avg_rating_given
FROM users u
LEFT JOIN ratings r ON u.user_id=r.user_id
GROUP BY u.user_id,u.user_name;

-- =========================================
-- 5. FUNCTION
-- =========================================

DELIMITER //

CREATE FUNCTION MovieScore(
    p_imdb DECIMAL(3,1),
    p_user DECIMAL(3,2),
    p_popularity INT
)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    RETURN ROUND((p_imdb*0.5)+(p_user*0.3)+(p_popularity/100*5*0.2),2);
END //

-- =========================================
-- 6. PROCEDURE
-- =========================================

CREATE PROCEDURE GetMoviesByGenre(IN p_genre VARCHAR(50))
BEGIN
    SELECT
        m.movie_id,
        m.title,
        d.director_name,
        m.release_year,
        m.imdb_rating,
        GROUP_CONCAT(g.genre_name SEPARATOR ', ') AS genres
    FROM movies m
    JOIN directors d ON m.director_id=d.director_id
    JOIN movie_genres mg ON m.movie_id=mg.movie_id
    JOIN genres g ON mg.genre_id=g.genre_id
    WHERE m.movie_id IN(
        SELECT mg2.movie_id
        FROM movie_genres mg2
        JOIN genres g2 ON mg2.genre_id=g2.genre_id
        WHERE g2.genre_name=p_genre
    )
    GROUP BY m.movie_id
    ORDER BY m.imdb_rating DESC;
END //

-- =========================================
-- 7. TRIGGERS
-- =========================================

CREATE TRIGGER rating_after_insert
AFTER INSERT ON ratings
FOR EACH ROW
BEGIN
    UPDATE movies
    SET average_user_rating=(
        SELECT ROUND(AVG(rating),2)
        FROM ratings
        WHERE movie_id=NEW.movie_id
    )
    WHERE movie_id=NEW.movie_id;
END //

CREATE TRIGGER rating_after_update
AFTER UPDATE ON ratings
FOR EACH ROW
BEGIN
    UPDATE movies
    SET average_user_rating=(
        SELECT ROUND(AVG(rating),2)
        FROM ratings
        WHERE movie_id=NEW.movie_id
    )
    WHERE movie_id=NEW.movie_id;
END //

CREATE TRIGGER rating_after_delete
AFTER DELETE ON ratings
FOR EACH ROW
BEGIN
    UPDATE movies
    SET average_user_rating=(
        SELECT IFNULL(ROUND(AVG(rating),2),0)
        FROM ratings
        WHERE movie_id=OLD.movie_id
    )
    WHERE movie_id=OLD.movie_id;
END //

DELIMITER ;

-- Refresh initial averages
UPDATE movies m
SET average_user_rating=(
    SELECT IFNULL(ROUND(AVG(r.rating),2),0)
    FROM ratings r
    WHERE r.movie_id=m.movie_id
);

-- =========================================
-- 8. QUERY LAB
-- =========================================

-- Basic SELECT
SELECT * FROM movie_catalog;

-- WHERE + ORDER BY
SELECT title,imdb_rating FROM movies
WHERE imdb_rating>=8
ORDER BY imdb_rating DESC;

-- LIKE
SELECT * FROM movies WHERE title LIKE '%Dune%';

-- BETWEEN
SELECT * FROM movies WHERE release_year BETWEEN 2010 AND 2024;

-- IN
SELECT * FROM movies WHERE language IN ('Hindi','Korean');

-- Aggregate
SELECT COUNT(*) total_movies,AVG(imdb_rating) avg_imdb,MAX(popularity) highest_popularity FROM movies;

-- GROUP BY + HAVING
SELECT language,COUNT(*) total_movies,AVG(imdb_rating) avg_rating
FROM movies
GROUP BY language
HAVING COUNT(*)>=2;

-- INNER JOIN
SELECT m.title,d.director_name
FROM movies m JOIN directors d ON m.director_id=d.director_id;

-- LEFT JOIN
SELECT u.user_name,COUNT(r.rating_id) ratings
FROM users u LEFT JOIN ratings r ON u.user_id=r.user_id
GROUP BY u.user_id,u.user_name;

-- Self-like analytical relationship using same table through comparisons
SELECT a.title AS movie_a,b.title AS movie_b,a.release_year
FROM movies a JOIN movies b
ON a.release_year=b.release_year AND a.movie_id<b.movie_id;

-- Subquery
SELECT title,imdb_rating
FROM movies
WHERE imdb_rating>(SELECT AVG(imdb_rating) FROM movies);

-- Correlated subquery
SELECT m.title
FROM movies m
WHERE m.imdb_rating>(
    SELECT AVG(m2.imdb_rating)
    FROM movies m2
    WHERE m2.language=m.language
);

-- EXISTS
SELECT title
FROM movies m
WHERE EXISTS(
    SELECT 1 FROM ratings r
    WHERE r.movie_id=m.movie_id
);

-- UNION
SELECT title,'IMDB Top' source FROM movies WHERE imdb_rating>=8.5
UNION
SELECT title,'Popular' source FROM movies WHERE popularity>=95;

-- CASE
SELECT title,imdb_rating,
CASE
 WHEN imdb_rating>=8.5 THEN 'Excellent'
 WHEN imdb_rating>=8 THEN 'Very Good'
 WHEN imdb_rating>=7 THEN 'Good'
 ELSE 'Average'
END quality
FROM movies;

-- CTE
WITH genre_stats AS(
    SELECT g.genre_name,AVG(m.imdb_rating) avg_rating
    FROM genres g
    JOIN movie_genres mg ON g.genre_id=mg.genre_id
    JOIN movies m ON mg.movie_id=m.movie_id
    GROUP BY g.genre_name
)
SELECT * FROM genre_stats ORDER BY avg_rating DESC;

-- Window Function
SELECT
    title,
    imdb_rating,
    RANK() OVER(ORDER BY imdb_rating DESC) AS imdb_rank
FROM movies;

-- Window partition
SELECT
    language,
    title,
    imdb_rating,
    RANK() OVER(PARTITION BY language ORDER BY imdb_rating DESC) AS language_rank
FROM movies;

-- Stored Function
SELECT title,MovieScore(imdb_rating,average_user_rating,popularity) AS smart_score
FROM movies
ORDER BY smart_score DESC;

CALL GetMoviesByGenre('Sci-Fi');
