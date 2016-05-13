DROP   SEQUENCE owner_sequence;

-- Create the sequence to increment owner ID numbers.
CREATE SEQUENCE owner_sequence
	START WITH	1
	INCREMENT BY	1
	MINVALUE	1
	MAXVALUE	999
	CACHE		2
	NOCYCLE;
/