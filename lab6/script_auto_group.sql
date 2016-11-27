CREATE SEQUENCE group_id;
SET GENERATOR group_id TO 100011;

CREATE SEQUENCE gm_id;
SET GENERATOR gm_id TO 100011;

SET TERM ^ ;



CREATE OR ALTER TRIGGER AUTO_GROUP_AND_ACCTYPE FOR CONTRACT
ACTIVE BEFORE INSERT POSITION 0
AS
declare variable gr_id integer;
begin
  /* Trigger text */
  gr_id = GEN_ID(group_id, 1);
  NEW.accesstype_id = 1;
  INSERT INTO groups (group_id) VALUES (:gr_id);
  INSERT INTO group_member (gm_id, group_id, client_id) VALUES (GEN_ID(gm_id,  1), :gr_id, NEW.client_id);
  NEW.group_id = :gr_id;
end
^

SET TERM ; ^