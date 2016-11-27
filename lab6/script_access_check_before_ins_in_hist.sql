CREATE EXCEPTION 
	error_more_than_one_client 
		'Error! More then one client in access group!';
CREATE EXCEPTION 
	error_not_enough_clients 
		'Error! Not enough clients in group!';
CREATE EXCEPTION 
	error_two_clients_req 
		'Error! Two clients required!';
CREATE EXCEPTION 
	error_client_and_group_req 
		'Error! Client and group required!';
CREATE EXCEPTION 
	error_list_of_clients_req 
		'Error! List of clients required!';
CREATE EXCEPTION 
	error_specific_client_req 
		'Error! Access only with specific client!';
CREATE EXCEPTION 
	error_min_amount_req 
		'Error! Not enough clients for access!';

SET TERM ^ ;

create or alter procedure CLIENTS_IN_GROUP_OF_ACCESS (TMP_GROUP_ID INTEGER)
returns (CLIENT_ID INTEGER)
as
begin

	FOR SELECT group_member.client_id 
	FROM group_member, tmp_group, tmp_group_member 
	WHERE  TMP_GROUP.TMP_GROUP_ID = :TMP_GROUP_ID
		AND TMP_GROUP_MEMBER.TMP_GROUP_ID = TMP_GROUP.TMP_GROUP_ID
		AND TMP_GROUP_MEMBER.GM_ID = GROUP_MEMBER.GM_ID
	into :client_id
	
	do begin
		suspend;
	end

end^

SET TERM ; ^

commit;

SET TERM ^ ;



CREATE OR ALTER TRIGGER ACCESS_CHECK FOR BOX_HISTORY
ACTIVE BEFORE INSERT POSITION 0
AS
begin
  /* Trigger text */
  /* if only_client client have an access, than > 1 client in access group generate error */
    IF ((SELECT accesstype_id FROM contract WHERE NEW.contract_id = contract.contract_id) = 1) THEN
        IF ((SELECT COUNT(*) FROM CLIENTS_IN_GROUP_OF_ACCESS(NEW.access_group_id)) > 1) THEN
            EXCEPTION error_more_than_one_client;
    /* if group_only, we need > 2 clients */
    IF ((SELECT accesstype_id FROM contract WHERE NEW.contract_id = contract.contract_id) = 2) THEN
        IF ((SELECT COUNT(*) FROM CLIENTS_IN_GROUP_OF_ACCESS(NEW.access_group_id)) < 2) THEN
            EXCEPTION error_not_enough_clients;

    /* if client_and_other_client, we need 2 clients */
    IF ((SELECT accesstype_id FROM contract WHERE NEW.contract_id = contract.contract_id) = 3) THEN
        IF ((SELECT COUNT(*) FROM CLIENTS_IN_GROUP_OF_ACCESS(NEW.access_group_id)) <> 2) THEN
            EXCEPTION error_two_clients_req;

    /* if client_and_other_group  */
    IF ((SELECT accesstype_id FROM contract WHERE NEW.contract_id = contract.contract_id) = 4) THEN
        IF ((SELECT COUNT(*) FROM CLIENTS_IN_GROUP_OF_ACCESS(NEW.access_group_id)) < 2) THEN
            EXCEPTION error_client_and_group_req;
    /* if list_of_clients  */
    IF ((SELECT accesstype_id FROM contract WHERE NEW.contract_id = contract.contract_id) = 5) THEN
        IF ((SELECT COUNT(*) FROM CLIENTS_IN_GROUP_OF_ACCESS(NEW.access_group_id)) < 1) THEN
            EXCEPTION error_list_of_clients_req;
    /* if with_specific_client_only  */
    IF ((SELECT accesstype_id FROM contract WHERE NEW.contract_id = contract.contract_id) = 6) THEN
        IF ((SELECT COUNT(*) FROM CLIENTS_IN_GROUP_OF_ACCESS(NEW.access_group_id)) <> 2) THEN
            EXCEPTION error_specific_client_req;
    /*   */
    IF ((SELECT accesstype_id FROM contract WHERE NEW.contract_id = contract.contract_id) = 7) THEN
        IF ((SELECT COUNT(*) FROM CLIENTS_IN_GROUP_OF_ACCESS(NEW.access_group_id)) < (SELECT access_type.access_min_num FROM access_type)) THEN
            EXCEPTION error_min_amount_req;
end
^

SET TERM ; ^
