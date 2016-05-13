-- File   : cr_database.sql
-- Purpose: Create 6 tables:
--            - Owner3
--            - Property3
--            - Owner_History3
--            - Assessment_History3
--            - ZONE3
--            - Property_type3
-- Author: Joseph Davidson
-- Date  : March 2016

-- Create the OWNER3 table with fields to store the owner's:
CREATE TABLE 	
    owner3              (
                        owner_id        varchar2(5)	NOT NULL,   -- Unique ID number.
                        name            varchar2(30),           -- Name.
                        address         varchar2(30),           -- Address.
                        city            varchar2(20),           -- City.
                        province        varchar2(2),            -- Province.
                        postal_code     varchar2(7),            -- Postal code.
                        phone           varchar2(15),           -- Phone number.
                        -- Create the primary key using the owner_id.
                        CONSTRAINT owner_pk 
                            PRIMARY KEY (owner_id)
                        );
-- Create the ASSESSMENT_HISTORY3 table with fields to store the property's:										
CREATE TABLE 	
    assessment_history3 (
                        property_id     varchar2(7) NOT NULL,	-- Unique ID number.
                        assessment      number      NOT NULL,	-- Assessed value.
                        assessment_date DATE,                   -- Assessment date.
                        --Create the composite key using the PROPERTY_ID and ASSESSMENT_DATE fields.
                        CONSTRAINT assessment_pk 
                            PRIMARY KEY (property_id, assessment_date)
                        );
-- Create the ZONE3 table with fields to store the zone's:										
CREATE TABLE 	
    ZONE3               (
                        zone_code       varchar2(2) NOT NULL,	-- Unique code.
                        description     varchar2(50),           -- Description.
                        -- Create the primary key using the ZONE_CODE field.
                        CONSTRAINT zone_pk 
                            PRIMARY KEY (zone_code)
                        );								  
-- Create the PROPERTY_TYPE3 table with fields to store the property type's:
CREATE TABLE 	
    property_type3      (
                        property_type   varchar2(15) NOT NULL,  -- Unique type code.
                        description     varchar2(50),           -- Description.
                        -- Create the primary key using the PROPERTY_TYPE field.
                        CONSTRAINT type_pk 
                            PRIMARY KEY (property_type)
                        );

-- Create the PROPERTY3 table with fields to store the property's:
CREATE TABLE 	
    property3           (
                        property_id     VARCHAR2(7)	NOT NULL, 	-- Unique ID number.
                        owner_id        NUMBER,	                -- Owner's unique ID number.
                        purchase_date 	DATE,                   -- Purchase date.
                        assessment      NUMBER,                 -- Most recent assessed value.
                        zone_code 		VARCHAR2(5),            -- Zone code.
                        property_type   VARCHAR2(15),           -- Type code.
                        -- Create the primary key using the PROPERTY_ID field.
                        CONSTRAINT property_pk 
                            PRIMARY KEY (property_id),
                        -- Create the foreign key linking the PROPERTY3 table to the OWNER3 table using the OWNER_ID field.
                        CONSTRAINT PropOwner_fk 
                            FOREIGN KEY (owner_id)
                                REFERENCES owner3 (owner_id),
                        -- Create the foreign key linking the PROPERTY3 table to the ZONE3 table using the ZONE_CODE field.
                        CONSTRAINT zone_fk
                            FOREIGN KEY (zone_code)
                                REFERENCES zone3 (zone_code),
                        -- Create the foreign key linking the PROPERTY3 table to the PROPERTY_TYPE3 table using the PROPERTY_TYPE field.
                        CONSTRAINT propertyType_fk
                            FOREIGN KEY (property_type)
                                REFERENCES property_type3 (property_type)
                        );
-- Create the OWNER_HISTORY3 table with fields to store the owner's:
CREATE TABLE 	
    owner_history3      (
                        property_id     varchar2(7)  NOT NULL,	-- Property's id(s).
                        name 			varchar2(30),           -- Name.
                        purchase_date 	DATE         NOT NULL,	-- Date of property purchase(s).
                        -- Create the primary key using the PROPERTY_ID and PURCHASE_DATE fields.
                        CONSTRAINT ownerHistory_pk 
                            PRIMARY KEY (property_id, purchase_date),
                        -- Create a foreign key linking the OWNER_HISTORY3 table to the PROPERTY3 table using the PROPERTY_ID field.
                        CONSTRAINT property_fk
                            FOREIGN KEY (property_id)
                            REFERENCES property3 (property_id)
                        );

/