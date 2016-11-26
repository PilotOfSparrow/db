SET TERM ^ ;

create or alter procedure TAKE_THE_NUMBER_BY_HISTORY (
	WHICH_BOX integer)
returns (
    DEPB_NUM integer,
    TIME_OF_ACCESS timestamp,
    HISTORY_PREVIOUSVALUE float,
    HISTORY_CURRENTVALUE float,
    "SIGN" varchar(1),
    DIFFERENCE float)
as
begin
  /* Procedure Text */
  for SELECT
        deposit_box.depb_num,
        box_history.time_of_access,
        box_history.history_previousvalue,
        box_history.history_currentvalue,
        CASE
            WHEN box_history.history_previousvalue > box_history.history_currentvalue THEN '-'
            WHEN box_history.history_previousvalue < box_history.history_currentvalue THEN '+'
            ELSE '='
        END,
            history_currentvalue - history_previousvalue AS difference
        FROM deposit_box, box_history
        WHERE deposit_box.depb_num = :which_box AND deposit_box.depb_id = box_history.depb_id
        ORDER BY box_history.time_of_access
        into :depb_num, :time_of_access, :history_previousvalue, :history_currentvalue, :sign, :difference
  do begin
  suspend;
  end
end^

SET TERM ; ^