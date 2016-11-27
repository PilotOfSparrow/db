CREATE SEQUENCE create_id;
SET GENERATOR create_id TO 100010;
CREATE TRIGGER auto_create_id FOR item BEFORE INSERT
AS
	BEGIN
		NEW.item_id = GEN_ID(create_id, 1);
	END