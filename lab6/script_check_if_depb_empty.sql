CREATE EXCEPTION error_depb_non_empty 'Error. This deposit box does not empty!';
CREATE TRIGGER control_depb_emptiness FOR contract BEFORE DELETE 
AS
BEGIN
    AS
begin
  /* Trigger text */
  if(OLD.DEPB_VALUE > 0.0) then
        exception error_depb_non_empty;
END