SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------- DROP TABLE Commands -----------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS references_item;
DROP TABLE IF EXISTS owns;
DROP TABLE IF EXISTS `release`;
DROP TABLE IF EXISTS physical_format;
DROP TABLE IF EXISTS album;
DROP TABLE IF EXISTS playlist;
DROP TABLE IF EXISTS favorited;
DROP TABLE IF EXISTS belongs;
DROP TABLE IF EXISTS soloist;
DROP TABLE IF EXISTS group_artist;
DROP TABLE IF EXISTS `user`;
DROP TABLE IF EXISTS artist;

SET FOREIGN_KEY_CHECKS = 1;

-- --------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------- CREATE TABLE Commands ---------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE artist (
    isni                BIGINT,
    name                VARCHAR(40) NOT NULL,
    activity_start_year SMALLINT    NOT NULL,
    --
    CONSTRAINT pk_artist
        PRIMARY KEY (isni),
    --
    CONSTRAINT ck_artist_isni_len
        CHECK (isni >= 1000000000000000 AND isni <= 9999999999999999)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `user` (
    username   VARCHAR(30),
    email      VARCHAR(50) NOT NULL,
    password   VARCHAR(64) NOT NULL,
    birthdate  DATE        NOT NULL,
    --
    CONSTRAINT pk_app_user
        PRIMARY KEY (username),
    --
    CONSTRAINT un_app_user_email
        UNIQUE (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE group_artist (
    isni BIGINT,
    --
    CONSTRAINT pk_group_artist
        PRIMARY KEY (isni),
    --
    CONSTRAINT fk_group_artist_artist
        FOREIGN KEY (isni) REFERENCES artist(isni) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE soloist (
    isni BIGINT,
    --
    CONSTRAINT pk_soloist
        PRIMARY KEY (isni),
    --
    CONSTRAINT fk_soloist_artist
        FOREIGN KEY (isni) REFERENCES artist(isni) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE belongs (
    soloist_isni BIGINT,
    group_isni   BIGINT,
    --
    CONSTRAINT pk_belongs
        PRIMARY KEY (soloist_isni, group_isni),
    --
    CONSTRAINT fk_belongs_soloist
        FOREIGN KEY (soloist_isni) REFERENCES soloist(isni) ON DELETE CASCADE,
    --
    CONSTRAINT fk_belongs_group_artist
        FOREIGN KEY (group_isni) REFERENCES group_artist(isni) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE favorited (
    username VARCHAR(30),
    isni     BIGINT,
    --
    CONSTRAINT pk_favorited
        PRIMARY KEY (username, isni),
    --
    CONSTRAINT fk_favorited_app_user
        FOREIGN KEY (username) REFERENCES `user`(username) ON DELETE CASCADE,
    --
    CONSTRAINT fk_favorited_artist
        FOREIGN KEY (isni) REFERENCES artist(isni) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE playlist (
    playlist_id INT AUTO_INCREMENT,
    name        VARCHAR(50) NOT NULL,
    type        VARCHAR(20),
    username    VARCHAR(30) NOT NULL,
    --
    CONSTRAINT pk_playlist
        PRIMARY KEY (playlist_id),
    --
    CONSTRAINT fk_playlist_app_user
        FOREIGN KEY (username) REFERENCES `user`(username) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE album (
    mbid         VARCHAR(36),
    title        VARCHAR(100) NOT NULL,
    release_year SMALLINT     NOT NULL,
    type         VARCHAR(20)  NOT NULL,
    isni         BIGINT       NOT NULL,
    --
    CONSTRAINT pk_album
        PRIMARY KEY (mbid),
    --
    CONSTRAINT fk_album_artist
        FOREIGN KEY (isni) REFERENCES artist(isni),
    --
    CONSTRAINT ck_album_type
        CHECK (LOWER(type) IN ('studio', 'live', 'compilation', 'ep'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE physical_format (
    designation VARCHAR(20),
    mbid        VARCHAR(36),
    --
    CONSTRAINT pk_physical_format
        PRIMARY KEY (designation, mbid),
    --
    CONSTRAINT fk_physical_format_album
        FOREIGN KEY (mbid) REFERENCES album(mbid) ON DELETE CASCADE,
    --
    CONSTRAINT ck_physical_format_designation
        CHECK (LOWER(designation) IN ('cd', 'vinyl', 'cassette'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `release` (
    ean_13      BIGINT,
    designation VARCHAR(20) NOT NULL,
    mbid        VARCHAR(36) NOT NULL,
    --
    CONSTRAINT pk_release
        PRIMARY KEY (ean_13),
    --
    CONSTRAINT fk_release_physical_format
        FOREIGN KEY (designation, mbid) REFERENCES physical_format(designation, mbid),
    --
    CONSTRAINT ck_release_ean_13_len
        CHECK (ean_13 >= 1000000000000 AND ean_13 <= 9999999999999)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE owns (
    username VARCHAR(30),
    ean_13   BIGINT,
    --
    CONSTRAINT pk_owns
        PRIMARY KEY (username, ean_13),
    --
    CONSTRAINT fk_owns_app_user
        FOREIGN KEY (username) REFERENCES `user`(username) ON DELETE CASCADE,
    --
    CONSTRAINT fk_owns_release
        FOREIGN KEY (ean_13) REFERENCES `release`(ean_13) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE references_item (
    playlist_id INT,
    mbid        VARCHAR(36),
    --
    CONSTRAINT pk_references_item
        PRIMARY KEY (playlist_id, mbid),
    --
    CONSTRAINT fk_references_item_playlist
        FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id) ON DELETE CASCADE,
    --
    CONSTRAINT fk_references_item_album
        FOREIGN KEY (mbid) REFERENCES album(mbid) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;