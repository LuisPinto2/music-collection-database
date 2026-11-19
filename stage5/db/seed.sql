SET NAMES utf8mb4;

-- --------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------- INSERT INTO Commands ---------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------- [ARTIST] ------------------------------------------------------------------------

INSERT INTO artist (isni, name, activity_start_year)
VALUES (1234567890123456, 'John Lennon', 1956);

INSERT INTO artist (isni, name, activity_start_year)
VALUES (2345678901234567, 'The Beatles', 1957);

INSERT INTO artist (isni, name, activity_start_year)
VALUES (3456789012345678, 'Freddie Mercury', 1985);

INSERT INTO artist (isni, name, activity_start_year)
VALUES (4567890123456789, 'Queen', 1970);

INSERT INTO artist (isni, name, activity_start_year)
VALUES (9876543210987654, 'Elvis Presley', 1954);

-- ---------------------------------------------- [SOLOIST] -----------------------------------------------------------------------

INSERT INTO soloist (isni)
VALUES (1234567890123456);

INSERT INTO soloist (isni)
VALUES (3456789012345678);

INSERT INTO soloist (isni)
VALUES (9876543210987654);

-- ---------------------------------------------- [GROUP_ARTIST] ------------------------------------------------------------------

INSERT INTO group_artist (isni)
VALUES (2345678901234567);

INSERT INTO group_artist (isni)
VALUES (4567890123456789);

-- ---------------------------------------------- [BELONGS] -----------------------------------------------------------------------

INSERT INTO belongs (soloist_isni, group_isni)
VALUES (1234567890123456, 2345678901234567);

INSERT INTO belongs (soloist_isni, group_isni)
VALUES (3456789012345678, 4567890123456789);

-- ----------------------------------------------- [USER] -------------------------------------------------------------------------

INSERT INTO `user` (username, email, password, birthdate)
VALUES ('joaopedro', 'joaopedro@gmail.com', '1234', '2008-02-12');

INSERT INTO `user` (username, email, password, birthdate)
VALUES ('josemiguel', 'josemiguel@hotmail.com', '17312aVxaAE', '1992-06-17');

-- -------------------------------------------- [FAVORITED] -----------------------------------------------------------------------

INSERT INTO favorited (username, isni)
VALUES ('joaopedro', 1234567890123456);

INSERT INTO favorited (username, isni)
VALUES ('josemiguel', 4567890123456789);

-- --------------------------------------------- [ALBUM] --------------------------------------------------------------------------

INSERT INTO album (mbid, title, release_year, type, isni)
VALUES ('12345678-1234-1234-1234-123456789012', 'Imagine', 1971, 'studio', 1234567890123456);

INSERT INTO album (mbid, title, release_year, type, isni)
VALUES ('11111111-1111-1111-1111-111111111111', 'Abbey Road', 1969, 'studio', 2345678901234567);

-- ------------------------------------------- [PHYSICAL_FORMAT] ------------------------------------------------------------------

INSERT INTO physical_format (designation, mbid)
VALUES ('vinyl', '12345678-1234-1234-1234-123456789012');

INSERT INTO physical_format (designation, mbid)
VALUES ('cassette', '12345678-1234-1234-1234-123456789012');

INSERT INTO physical_format (designation, mbid)
VALUES ('cd', '11111111-1111-1111-1111-111111111111');

-- ---------------------------------------------- [RELEASE] -----------------------------------------------------------------------

INSERT INTO `release` (ean_13, designation, mbid)
VALUES (1234567890123, 'vinyl', '12345678-1234-1234-1234-123456789012');

INSERT INTO `release` (ean_13, designation, mbid)
VALUES (1234567890124, 'vinyl', '12345678-1234-1234-1234-123456789012');

INSERT INTO `release` (ean_13, designation, mbid)
VALUES (1234567890125, 'cassette', '12345678-1234-1234-1234-123456789012');

INSERT INTO `release` (ean_13, designation, mbid)
VALUES (1111111111111, 'cd', '11111111-1111-1111-1111-111111111111');

-- ---------------------------------------------- [OWNS] --------------------------------------------------------------------------

INSERT INTO owns (username, ean_13)
VALUES ('joaopedro', 1234567890123);

INSERT INTO owns (username, ean_13)
VALUES ('joaopedro', 1234567890125);

INSERT INTO owns (username, ean_13)
VALUES ('josemiguel', 1111111111111);

-- ---------------------------------------------- [PLAYLIST] ----------------------------------------------------------------------

INSERT INTO playlist (playlist_id, name, type, username)
VALUES (1, '80s', 'custom', 'joaopedro');

INSERT INTO playlist (playlist_id, name, type, username)
VALUES (2, 'Nostalgia', 'custom', 'josemiguel');

-- ---------------------------------------------------- [REFERENCES_ITEM] ---------------------------------------------------------

INSERT INTO references_item (playlist_id, mbid)
VALUES (1, '12345678-1234-1234-1234-123456789012');

INSERT INTO references_item (playlist_id, mbid)
VALUES (1, '11111111-1111-1111-1111-111111111111');

INSERT INTO references_item (playlist_id, mbid)
VALUES (2, '11111111-1111-1111-1111-111111111111');