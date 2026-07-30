ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.YYYY';

----------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- DROP TABLE Commands -----------------------------------------------------------------

DROP TABLE references_item;
DROP TABLE owns;
DROP TABLE physical_format;
DROP TABLE release;
DROP TABLE album;
DROP TABLE playlist;
DROP TABLE favorited;
DROP TABLE belongs;
DROP TABLE soloist;
DROP TABLE group_artist;
DROP TABLE app_user;
DROP TABLE artist;

----------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- CREATE TABLE Commands ----------------------------------------------------------------

CREATE TABLE artist (
    isni                NUMBER(16),
    name                VARCHAR2(40) CONSTRAINT nn_artist_name                NOT NULL,
    activity_start_year NUMBER(4)  CONSTRAINT nn_artist_activity_start_year NOT NULL,
    --
    CONSTRAINT pk_artist
        PRIMARY KEY (isni),
    --
    CONSTRAINT ck_artist_isni_len                                             -- IC-07
        CHECK (isni >= 1000000000000000 AND isni <= 9999999999999999)
);

CREATE TABLE app_user (
    username   VARCHAR2(30),
    email      VARCHAR2(50) CONSTRAINT nn_app_user_email     NOT NULL,
    password   VARCHAR2(64) CONSTRAINT nn_app_user_password  NOT NULL,
    birthdate  DATE         CONSTRAINT nn_app_user_birthdate NOT NULL,
    --
    CONSTRAINT pk_app_user
        PRIMARY KEY (username),
    --
    CONSTRAINT un_app_user_email
        UNIQUE (email)
);

CREATE TABLE group_artist (
    isni NUMBER(16),
    --
    CONSTRAINT pk_group_artist
        PRIMARY KEY (isni),
    --
    CONSTRAINT fk_group_artist_artist
        FOREIGN KEY (isni) REFERENCES artist(isni) ON DELETE CASCADE
);

CREATE TABLE soloist (
    isni NUMBER(16),
    --
    CONSTRAINT pk_soloist
        PRIMARY KEY (isni),
    --
    CONSTRAINT fk_soloist_artist
        FOREIGN KEY (isni) REFERENCES artist(isni) ON DELETE CASCADE
);

CREATE TABLE belongs (
    soloist_isni NUMBER(16),
    group_isni   NUMBER(16),
    --
    CONSTRAINT pk_belongs
        PRIMARY KEY (soloist_isni, group_isni),
    --
    CONSTRAINT fk_belongs_soloist
        FOREIGN KEY (soloist_isni) REFERENCES soloist(isni) ON DELETE CASCADE,
    --
    CONSTRAINT fk_belongs_group_artist
        FOREIGN KEY (group_isni) REFERENCES group_artist(isni) ON DELETE CASCADE
);

CREATE TABLE favorited (
    username NUMBER(16), -- Ajustar o tipo para VARCHAR2(30) se o FK for para app_user(username)
    isni     NUMBER(16),
    --
    CONSTRAINT pk_favorited
        PRIMARY KEY (username, isni),
    --
    CONSTRAINT fk_favorited_app_user
        FOREIGN KEY (username) REFERENCES app_user(username) ON DELETE CASCADE,
    --
    CONSTRAINT fk_favorited_artist
        FOREIGN KEY (isni) REFERENCES artist(isni) ON DELETE CASCADE
);

CREATE TABLE playlist (
    playlist_id NUMBER(10),
    name        VARCHAR2(50) CONSTRAINT nn_playlist_name NOT NULL,
    type        VARCHAR2(20),
    username    VARCHAR2(30) CONSTRAINT nn_playlist_username NOT NULL,
    --
    CONSTRAINT pk_playlist
        PRIMARY KEY (playlist_id),
    --
    CONSTRAINT fk_playlist_app_user
        FOREIGN KEY (username) REFERENCES app_user(username) ON DELETE CASCADE
);

CREATE TABLE album (
    mbid         VARCHAR2(36),
    title        VARCHAR2(100) CONSTRAINT nn_album_title        NOT NULL,
    release_year NUMBER(4)    CONSTRAINT nn_album_release_year NOT NULL,
    type         VARCHAR2(20)  CONSTRAINT nn_album_type         NOT NULL,
    isni         NUMBER(16)   CONSTRAINT nn_album_isni         NOT NULL,
    --
    CONSTRAINT pk_album
        PRIMARY KEY (mbid),
    --
    CONSTRAINT fk_album_artist
        FOREIGN KEY (isni) REFERENCES artist(isni),
    --
    CONSTRAINT ck_album_type
        CHECK (LOWER(type) IN ('studio', 'live', 'compilation', 'ep'))
);

CREATE TABLE physical_format (
    designation VARCHAR2(20),
    mbid        VARCHAR2(36),
    --
    CONSTRAINT pk_physical_format
        PRIMARY KEY (designation, mbid),
    --
    CONSTRAINT fk_physical_format_album
        FOREIGN KEY (mbid) REFERENCES album(mbid) ON DELETE CASCADE,
    --
    CONSTRAINT ck_physical_format_designation
        CHECK (LOWER(designation) IN ('cd', 'vinyl', 'cassette'))
);

CREATE TABLE release (
    ean_13      NUMBER(13),
    designation VARCHAR2(20) CONSTRAINT nn_release_designation NOT NULL,
    mbid        VARCHAR2(36) CONSTRAINT nn_release_mbid        NOT NULL,
    --
    CONSTRAINT pk_release
        PRIMARY KEY (ean_13),
    --
    CONSTRAINT fk_release_physical_format
        FOREIGN KEY (designation, mbid) REFERENCES physical_format(designation, mbid),
    --
    CONSTRAINT ck_release_ean_13_len
        CHECK (ean_13 >= 1000000000000 AND ean_13 <= 9999999999999)
);

CREATE TABLE owns (
    username VARCHAR2(30),
    ean_13   NUMBER(13),
    --
    CONSTRAINT pk_owns
        PRIMARY KEY (username, ean_13),
    --
    CONSTRAINT fk_owns_app_user
        FOREIGN KEY (username) REFERENCES app_user(username) ON DELETE CASCADE,
    --
    CONSTRAINT fk_owns_release
        FOREIGN KEY (ean_13) REFERENCES release(ean_13) ON DELETE CASCADE
);

CREATE TABLE references_item (
    playlist_id NUMBER(10),
    mbid        VARCHAR2(36),
    --
    CONSTRAINT pk_references_item
        PRIMARY KEY (playlist_id, mbid),
    --
    CONSTRAINT fk_references_item_playlist
        FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id) ON DELETE CASCADE,
    --
    CONSTRAINT fk_references_item_album
        FOREIGN KEY (mbid) REFERENCES album(mbid) ON DELETE CASCADE
);

    ----------------------------------------------------------------------------------------------------------------------------------
    -- Integrity Constraints Not Supported by Standard Declarative SQL:
        -- IC-03: The tracks of an album must start from sequence number 1 onwards.
        -- IC-04: The ISRC code of a song must contain exactly 12 characters.
        -- IC-05: The duration of a song must be positive.
        -- IC-06: If an album is performed by an artist, that artist must perform all songs on that album.
        -- IC-08: The release year of an album performed by an artist must be greater than or equal to the activity start year of that artist.
        -- IC-09: The release year of an album must be greater than or equal to the activity start year of all artists performing the songs included in that album's tracks.
        -- IC-15: The birthdate of a user must be 13 or more years prior to the current date, requiring verification upon user account creation in the system. (Implemented non-dynamically)
        -- IC-16: The year of the addition date of an album release to a user's collection must be greater than or equal to the album's release year.
        -- IC-17: The addition date of an album release to a user's collection must be greater than or equal to the date the user turned 13 years old.
        -- IC-18: The priority with which a user wishes an album release must be 'high', 'medium', or 'low'.
    ----------------------------------------------------------------------------------------------------------------------------------