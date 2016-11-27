SET TERM ^ ;

create or alter procedure SORTING_PROC
returns (
    CL_ID integer,
    ITEM varchar(128),
    DEB_ID integer)
as
declare variable TMP_CLIENT_ID integer;
declare variable TMP_ITEM varchar(128);
declare variable TMP_DEB_ID integer;
declare variable TMP_NEXT_DEB_ID integer;
declare variable TMP_CURRENT_CL_ID integer;
begin
  /* Procedure Text */
  for 
    SELECT FIRST 4 cntr.client_id
    FROM contract AS cntr, deposit_box
    JOIN contract ON contract.depb_id = deposit_box.depb_id
    WHERE cntr.depb_id = deposit_box.depb_id
        AND EXISTS (SELECT FIRST 1 contract.client_id
                    FROM contract
                    WHERE contract.client_id = cntr.client_id
                    GROUP BY contract.client_id
                    HAVING count(contract.depb_id) > 2)
    GROUP BY cntr.client_id
    into :tmp_client_id
    
  do begin
  
    for
        SELECT contract.client_id, item.item_type, item.depb_id
        FROM contract
        JOIN item ON contract.depb_id = item.depb_id
        WHERE contract.client_id = :tmp_client_id
        ORDER BY item.item_type
        into :CL_ID, :Item, :DEB_ID

    do
        begin
        if (tmp_current_cl_id is null) then
            tmp_current_cl_id = :cl_id;

        if (:cl_id <> :tmp_current_cl_id) then
            begin
                tmp_current_cl_id = :cl_id;
                tmp_next_deb_id = NULL;
            end

            if (:Item = :tmp_item) then
            begin
    
               if (:deb_id <> :tmp_deb_id) then
               begin
                    tmp_next_deb_id = :deb_id;
                    deb_id = :tmp_deb_id;
               end
            end
            else
              begin
                 tmp_item = :Item;

                 if (tmp_next_deb_id is null) then
                    tmp_deb_id = :deb_id;
                 else
                    begin
                        tmp_deb_id = :tmp_next_deb_id;
                        deb_id = :tmp_deb_id;
                    end
              end

    
            begin
                suspend;
            end
      
         end

      end
end^

SET TERM ; ^

/* Following GRANT statements are generated automatically */

GRANT SELECT ON CONTRACT TO PROCEDURE NEW_PROCEDURE;
GRANT SELECT ON DEPOSIT_BOX TO PROCEDURE NEW_PROCEDURE;
GRANT SELECT ON ITEM TO PROCEDURE NEW_PROCEDURE;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE NEW_PROCEDURE TO SYSDBA;