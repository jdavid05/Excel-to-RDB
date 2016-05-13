---------------------------------------------------------------------------------------------
-- File    : cr_prUniversal																	-
-- Purpose : Populate 6 3NF tables with data from the UNIVERSAL table						-
-- Author  : Joseph Davidson																-
-- Date    : March 2016																		-
---------------------------------------------------------------------------------------------

-- Create or replace the procedure to process the universal table.
CREATE OR REPLACE PROCEDURE process_universal AS  	
	
    -- Create a variable to store the current sequence number.
    store_seq 		number;     -- Number to store the owner_sequence value.
	
    -- cur_OwnProp: The list of all unique properties and their most recent purchase and 
    --				assessment dates to be inserted into the PROPERTY3 and OWNER3 tables.
    CURSOR cur_OwnProp IS
        SELECT              a.*,
                            Lag(name, 1) 	OVER (ORDER BY name) 	name_prev
        FROM                (
            SELECT 	            prop_id, 
                                purchase_date, 
                                assessment, 
                                zone, 
                                property_type, 
                                assessment_date,
                                name,
                                address,
                                city,
                                province,
                                pcode,
                                phone,
                                max(purchase_date) 		OVER (partition by prop_id) maxdate,
                                max(assessment_date) 	OVER (partition by prop_id) maxprop
            FROM                verran.universal
                            ) a
    WHERE			        a.purchase_date 	= maxdate
    AND 			        a.assessment_date 	= maxprop
    ;

    -- cur_history: The list of all properties, owners, and assessments to populate the
    --              owner_history and assessment_history tables.
    CURSOR cur_PropertyHistory IS
        SELECT DISTINCT prop_id,
                        assessment,
                        assessment_date
        FROM            verran.universal
        ORDER BY        assessment_date DESC
        ;
		
    -- cur_OwnerHistory: The list of all owners that have owned a property and the dates
    --					 when they purchased the property.
    CURSOR cur_OwnerHistory IS
        SELECT DISTINCT prop_id,
                        name,
                        purchase_date
        FROM            verran.universal
        ORDER BY        purchase_date DESC
        ;
	
    -- cur_zones: The list of zones and their descriptions to populate the ZONE3 table.
    CURSOR cur_Zones IS
        SELECT DISTINCT zone,
                        zone_desc
        FROM            verran.universal
        ;

    -- cur_properties: The list of all property types and their descriptions to populate
    --                 the PROPERTY_TYPE3 table.
    CURSOR cur_Types IS
        SELECT DISTINCT property_type,
                        type_desc
        FROM            verran.universal
        ;

BEGIN
    -- For each property assessment in the universal table:
    FOR property IN cur_PropertyHistory LOOP
        -- Insert the property information into the ASSESSMENT_HISTORY3 table.
        INSERT INTO assessment_history3
            VALUES  (property.prop_id,
                    property.assessment,
                    property.assessment_date
                    );
        -- Print a statement validating the insertion.
        dbms_output.put_line('Added '||property.prop_id||' '||'from'||property.assessment_date||
        ' '||'to the assessment table');
    -- End the loop.
    END LOOP;

    -- Begin a loop of each zone in the UNIVERSAL table:
    FOR zones in cur_Zones LOOP
        -- Insert the zones ID and description into the ZONE3 table.
        INSERT INTO zone3
            VALUES (zones.zone,
                    zones.zone_desc
                    );
        -- Print the statement validating the insertion.
        dbms_output.put_line('Added'||zones.zone||' '||'to the zone table');
    -- End the loop.
    END LOOP;	

    -- Begin a loop to read information for each property in the UNIVERSAL table.
    FOR property in cur_Types LOOP
        -- Insert the property information into the PROPERTY_TYPE3 table.
        INSERT INTO property_type3
            VALUES (property.property_type,
                    property.type_desc
                    );
        -- Print a statement validating the insertion.
        dbms_output.put_line('Added'||property.property_type||' '||'to the property type table');
    -- End the loop.
    END LOOP;

    -- For each property owner who currently owns property:
    FOR CurrentOwner IN cur_OwnProp LOOP
    -- When the property owner is encountered more than once:
        CASE WHEN CurrentOwner.name = CurrentOwner.name_prev THEN
            -- Repeat their owner ID number and insert the property information into the OWNER3 table.
            INSERT INTO property3
                VALUES (CurrentOwner.prop_id,
                        store_seq,
                        CurrentOwner.purchase_date,
                        CurrentOwner.assessment,
                        CurrentOwner.zone,
                        CurrentOwner.property_type
                        );
            -- Print a statement validating the insertion.
            dbms_output.put_line('Added '||CurrentOwner.prop_id||' '||'to the property table.');
        -- When an owner is encountered for their first property in the table:
        ELSE
            -- Update the owner sequence value to the next value in the sequence.
            select owner_sequence.nextval into store_seq from dual;
            -- Insert the owner's information and unique ID number into the OWNER3 table.
            INSERT INTO owner3
                VALUES (store_seq,
                        CurrentOwner.name,
                        CurrentOwner.address,
                        CurrentOwner.city,
                        CurrentOwner.province,
                        CurrentOwner.pcode,
                        CurrentOwner.phone
                        );
            -- Print a statement validating the insertion.
            dbms_output.put_line('Added '||owner_sequence.currval||': '||CurrentOwner.name||
            ' '||'to the owner table.');
            -- Assign the the owner a unique ID number from the sequence and insert the property
            -- information into the PROPERTY3 table
            INSERT INTO property3
                VALUES (CurrentOwner.prop_id,
                        store_seq,
                        CurrentOwner.purchase_date,
                        CurrentOwner.assessment,
                        CurrentOwner.zone,
                        CurrentOwner.property_type
                        );
            -- Print a statement validating the insertion.
            dbms_output.put_line('Added '||CurrentOwner.prop_id||' '||'to the property table.');
        -- End the case.
        END CASE;
    -- End the loop.		
    END LOOP;
	
    -- Begin a loop returning each owner who purchased a property:
    FOR previous_owner IN cur_OwnerHistory LOOP
        -- Insert the owner's information into the OWNER_HISTORY3 table.
        INSERT INTO owner_history3
            VALUES  (previous_owner.prop_id,
                    previous_owner.name,
                    previous_owner.purchase_date
                    );
        -- Print a statement validating the insertion.
        dbms_output.put_line('Added '||previous_owner.name||' '||'to the owner_history table');
    -- End the loop.
    END LOOP;

-- End the procedure.
END;
/