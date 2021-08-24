CREATE SEQUENCE sample_seq
    START WITH 100000
    INCREMENT BY 1;

CREATE SEQUENCE substance_seq
    START WITH 100000
    INCREMENT BY 1;

CREATE SEQUENCE person_seq
    START WITH 100000
    INCREMENT BY 1;

CREATE SEQUENCE address_seq
    START WITH 100000
    INCREMENT BY 1;

CREATE SEQUENCE tue_seq
    START WITH 100000
    INCREMENT BY 1;

CREATE SEQUENCE control_seq
    START WITH 100000
    INCREMENT BY 1;

CREATE TABLE address
(
    id          int DEFAULT address_seq.nextval PRIMARY KEY,
    country     varchar(127),
    postal_code varchar(31), -- can contain alphanumeric
    city        varchar(127),
    street      varchar(127),
    house       varchar(31)  -- house "number" e.g. 3192B/9


);

CREATE TABLE person
(
    id           int DEFAULT person_seq.nextval PRIMARY KEY,
    sex          int, -- 0 == female, 1 == male;
    name_first   varchar(31) NOT NULL,
    name_last    varchar(31) NOT NULL,
    email        varchar(63),
    address      int,
    birth_date   date,

    phone_number int,

    CONSTRAINT phone_number_max_digits
        CHECK (phone_number <= 999999999999),

    CONSTRAINT phone_number_min_digits
        CHECK (phone_number >= 100000000),

    CONSTRAINT person#address_fk
        FOREIGN KEY (address) REFERENCES address (id)
);

CREATE TABLE athlete
(
    id              int PRIMARY KEY,
    address_current int,
    -- some athletes must give info about their current whereabouts

    CONSTRAINT athlete#person_fk
        FOREIGN KEY (id) REFERENCES person (id) ON DELETE CASCADE,

    CONSTRAINT athlete#address_current_fk
        FOREIGN KEY (address_current) REFERENCES address (id)

);

CREATE TABLE laboratory
(
    id                        int PRIMARY KEY,
    name                      varchar(127),
    accreditation_valid_until date,
    address                   int,

    CONSTRAINT laboratory#address_fk
        FOREIGN KEY (address) REFERENCES address (id)
);

CREATE TABLE laboratory_employee
(
    id            int PRIMARY KEY,
    position      varchar(127),
    laboratory_id int NOT NULL,

    CONSTRAINT laboratory_employee#laboratory_fk
        FOREIGN KEY (laboratory_id) REFERENCES laboratory (id),

    CONSTRAINT laboratory_employee#person_fk
        FOREIGN KEY (id) REFERENCES person (id) ON DELETE CASCADE

);

CREATE TABLE doping_control_officer
(
    id             int PRIMARY KEY,
    licence_number int UNIQUE,

    CONSTRAINT dco#person_fk
        FOREIGN KEY (id) REFERENCES person (id) ON DELETE CASCADE

);

CREATE TABLE sport
(
    name varchar(127) PRIMARY KEY

);

CREATE TABLE rel_athlete_sport
(
    athlete_id int,
    sport_name varchar(127),
    PRIMARY KEY (athlete_id, sport_name),


    CONSTRAINT athlete_sport#athlete_fk
        FOREIGN KEY (athlete_id) REFERENCES athlete (id) ON DELETE CASCADE,

    CONSTRAINT athlete_sport#sport_fk
        FOREIGN KEY (sport_name) REFERENCES sport (name) ON DELETE CASCADE

);

CREATE TABLE therapeutic_use_exemption
(
    id                       int DEFAULT tue_seq.nextval PRIMARY KEY,

    athlete_id               int NOT NULL,

    valid_in_competition     int, -- 0 == false, 1 == true
    valid_out_of_competition int, -- 0 == false, 1 == true

    commentary               clob,

    CONSTRAINT tue#athlete_fk
        FOREIGN KEY (athlete_id) REFERENCES athlete (id) ON DELETE CASCADE,


    CONSTRAINT tue_valid_in_competition_values
        CHECK (valid_in_competition = 0 OR valid_in_competition = 1),

    CONSTRAINT tue_valid_out_of_competition_values
        CHECK (valid_out_of_competition = 0 OR valid_out_of_competition = 1)

    -- referencing the substance must be done M:N -> separate table

);

CREATE TABLE substance_category
(
    name varchar(127) PRIMARY KEY
);

CREATE TABLE substance
(
    id       int PRIMARY KEY,
    category varchar(127) NOT NULL,
    name     varchar(127),

    CONSTRAINT substance#category_fk
        FOREIGN KEY (category) REFERENCES substance_category (name)

);


CREATE TABLE substance_ban
(
    id                       int PRIMARY KEY,
    substance_id             int, -- @discuss: add a substance category
    valid_from               date,
    valid_in_competition     int, -- 0 == false, 1 == true
    valid_out_of_competition int, -- 0 == false, 1 == true

    commentary               clob,

    CONSTRAINT substance_ban#substance_fk
        FOREIGN KEY (substance_id) REFERENCES substance (id) ON DELETE CASCADE,


    CONSTRAINT ban_valid_in_competition_values
        CHECK (valid_in_competition = 0 OR valid_in_competition = 1),

    CONSTRAINT ban_valid_out_of_competition_values
        CHECK (valid_out_of_competition = 0 OR valid_out_of_competition = 1)


);

CREATE TABLE rel_tue_substance
(
    tue_id       int,
    substance_id int,
    PRIMARY KEY (tue_id, substance_id),


    CONSTRAINT tue_substance#tue_fk
        FOREIGN KEY (tue_id) REFERENCES therapeutic_use_exemption (id) ON DELETE CASCADE,

    CONSTRAINT tue_substance#substance_fk
        FOREIGN KEY (substance_id) REFERENCES substance (id) ON DELETE CASCADE

);

CREATE TABLE doping_control
(
    id               int DEFAULT control_seq.nextval PRIMARY KEY,
    athlete_presence int, -- 0 == was not present, 1 == was present
    start_time       date,
    end_time         date,
    in_competition   int, -- 0 == out of competition, 1 == in competition
    samples_required varchar(127),
    delay            int, --number of days
    reason_of_delay  varchar(255),
    dco_id           int NOT NULL,
    athlete_id       int NOT NULL,

    CONSTRAINT dop_control#dco_fk
        FOREIGN KEY (dco_id) REFERENCES doping_control_officer (id) ON DELETE CASCADE,

    CONSTRAINT dop_control#athlete_fk
        FOREIGN KEY (athlete_id) REFERENCES athlete (id) ON DELETE CASCADE,

    CONSTRAINT control_athlete_presence_values
        CHECK (athlete_presence = 0 OR athlete_presence = 1),

    CONSTRAINT control_in_competition_values
        CHECK (in_competition = 0 OR in_competition = 1)

);

CREATE TABLE sample
(
    id            int DEFAULT sample_seq.nextval PRIMARY KEY,
    use           int, -- 0 == main sample, 1 == control sample
    evaluation    int, -- 0 == negative, 1 == positive
    type          int, -- 0 == urine sample, 1 == blood sample
    volume        int, -- [milliliters]
    control_id    int NOT NULL,
    laboratory_id int,

    CONSTRAINT sample#laboratory_fk
        FOREIGN KEY (laboratory_id) REFERENCES laboratory (id),

    CONSTRAINT sample#control_fk
        FOREIGN KEY (control_id) REFERENCES doping_control (id) ON DELETE CASCADE,

    CONSTRAINT sample_use_values
        CHECK (use = 0 OR use = 1),

    CONSTRAINT sample_evaluation_values
        CHECK (evaluation = 0 OR evaluation = 1),

    CONSTRAINT sample_type_values
        CHECK (type = 0 OR type = 1),

    CONSTRAINT sample_volume_positive
        CHECK (volume > 0)

);


CREATE TABLE rel_ban_sport
(
    sport_name       varchar(127),
    substance_ban_id int,

    PRIMARY KEY (sport_name, substance_ban_id),


    CONSTRAINT ban_sport#substance_fk
        FOREIGN KEY (substance_ban_id) REFERENCES substance_ban (id) ON DELETE CASCADE,

    CONSTRAINT ban_sport#sport_fk
        FOREIGN KEY (sport_name) REFERENCES sport (name) ON DELETE CASCADE
);

CREATE TABLE rel_substance_sample
(
    sample_id    int,
    substance_id int,
    PRIMARY KEY (sample_id, substance_id),

    CONSTRAINT substance_sample#sample_fk
        FOREIGN KEY (sample_id) REFERENCES sample (id) ON DELETE CASCADE,

    CONSTRAINT substance_sample#substance_fk
        FOREIGN KEY (substance_id) REFERENCES substance (id) ON DELETE CASCADE
);

CREATE TABLE rel_tue_sport
(
    tue_id     int,
    sport_name varchar(127),
    PRIMARY KEY (tue_id, sport_name),


    CONSTRAINT tue_sport#tue_fk
        FOREIGN KEY (tue_id) REFERENCES therapeutic_use_exemption (id) ON DELETE CASCADE,

    CONSTRAINT tue_sport#sport_fk
        FOREIGN KEY (sport_name) REFERENCES sport (name) ON DELETE CASCADE
);


