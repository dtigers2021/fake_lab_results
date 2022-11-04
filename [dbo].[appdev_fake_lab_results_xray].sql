CREATE PROCEDURE [dbo].[appdev_fake_lab_results_xray]
@practice_id VARCHAR(4),
@r_enc_nbr VARCHAR (12),
@r_test_status VARCHAR (40),
@result_status_msg VARCHAR (100) OUTPUT
AS

SET @result_status_msg = NULL

DECLARE
@enterprise_id			VARCHAR(5),
@person_id				UNIQUEIDENTIFIER,
@enc_id					UNIQUEIDENTIFIER,
@provider_id			UNIQUEIDENTIFIER,
@location_id			UNIQUEIDENTIFIER,
@enc_nbr				VARCHAR(12),
@enc_timestamp			DATETIME,
@r_order_num			UNIQUEIDENTIFIER,
@r_lab_id				VARCHAR (25),
@r_lab_vendor_desc		VARCHAR (75),
@r_lab_test_ng			VARCHAR (200),
@r_test_status_letter	CHAR (1), 
@r_msg_control_id		UNIQUEIDENTIFIER,
@r_order_test_id		UNIQUEIDENTIFIER,
@r_ord_phys_code		UNIQUEIDENTIFIER,
@r_unique_obr_num		UNIQUEIDENTIFIER,
@r_queue_id				UNIQUEIDENTIFIER



Select  @r_test_status_letter = 
			CASE @r_test_status WHEN 'Final'  THEN 'F'
								WHEN 'Partial' THEN 'P'
								WHEN 'InProcessUnspecified' THEN 'I'
								ELSE ''
			END

Select	@enterprise_id = pe.enterprise_id, 
		@practice_id = pe.practice_id, 
		@person_id = pe.person_id, 
		@enc_id = pe.enc_id,
		@location_id = pe.location_id,
		@provider_id = pe.rendering_provider_id,
		@r_order_num = NEWID()
		--@r_lab_test_ng = ln.test_desc
from patient_encounter pe
where pe.practice_id=@practice_id and pe.enc_nbr=@r_enc_nbr
			
IF NOT EXISTS (Select 1 from patient_encounter pe where pe.practice_id=@practice_id and pe.enc_nbr=@r_enc_nbr)
Begin
	SET @result_status_msg='The encounter number and practice must be set before an order can be resulted.'
END
ELSE IF @r_test_status_letter =''
Begin
	SET @result_status_msg='This result status does not exist.'
END
ELSE
BEGIN

--Select * from external_system
Select @r_lab_id=6453
Select @r_lab_vendor_desc = 'OnePacs'
Select @r_lab_test_ng

SELECT @enc_timestamp = enc_timestamp    
FROM patient_encounter    
WHERE enc_id = @enc_id  

Select @r_msg_control_id	=	NEWID()
Select @r_order_test_id		=	NEWID()
Select @r_unique_obr_num	=	NEWID()
Select @r_queue_id			=	NEWID()

----------------------------------------------------------------------------------------
--0.5) Generates a Ufo_num for the order that is being created
----------------------------------------------------------------------------------------
DECLARE
@po_result_code VARCHAR(100)=0, 
@po_result_msg VARCHAR(255)=NULL,
@po_counter_nbr BIGINT,
@r_ufo_num VARCHAR(128)
EXEC ng_get_system_counter_nbr 
@po_result_code OUTPUT, 
@po_result_msg	OUTPUT,
'Lab Order', 
@po_counter_nbr OUTPUT 
SELECT @r_ufo_num = RTRIM(db_id) + RTRIM(CAST(@po_counter_nbr AS CHAR))    
FROM sys_info 
--SELECT @r_ufo_num+'^'+'LAB'

----------------------------------------------------------------------------------------
--1) Lab Nor Table
----------------------------------------------------------------------------------------
INSERT INTO lab_nor (enterprise_id,practice_id,enc_id,order_num,person_id,ordering_provider,test_location,test_status,ngn_status,test_desc,delete_ind,order_control,order_priority,time_entered,spec_action_code,billing_type,ufo_num,lab_id,enc_timestamp,created_by,create_timestamp,modified_by,modify_timestamp,generated_by,enc_timestamp_tz,create_timestamp_tz,modify_timestamp_tz,order_type,recur_mode,ng_order_ind,documents_ind,signoff_comments_ind,ordered_elsewhere_ind,intrf_msg,completed_ind)
Select @enterprise_id,@practice_id,@enc_id,@r_order_num,@person_id,@provider_id,@location_id,@r_test_status,'Assigned','RIGHT ANKLE','N','NW','R','2019-02-05 12:00:00.000','N','T',@r_ufo_num,'6453',@enc_timestamp,'2087',GETDATE(),'2087',GETDATE(),'Interface','780','780','780','R','N','N','N','N','N',NULL,'N'
--Select * from lab_nor where person_id='C452B259-796D-44C2-8249-0967573124E9' and order_num='9799D5E4-1925-4119-B984-C9E3EB286F8B'
--UPDATE ln set test_status=@r_test_status,ngn_status='Assigned',completed_ind='Y',generated_by='Lab Checkout',modified_by='-101',modify_timestamp=GETDATE(),enc_timestamp_tz=0,create_timestamp_tz=0,modify_timestamp_tz=0,intrf_msg='',signoff_comments_ind='Y'
--from lab_nor ln
--where ln.ufo_num=@r_ufo_num

----------------------------------------------------------------------------------------
--2) Lab Results OBR Table
----------------------------------------------------------------------------------------
INSERT INTO lab_results_obr_p (enterprise_id,practice_id,person_id,msg_control_id,seg_id,seq_num,unique_obr_num,req_accession,ngn_order_num,prod_accession,obs_batt_id,coll_date_time,spec_rcv_date_time,ord_phys_code,requestor_field_1,producer_field_1,date_time_reported,order_result_stat,test_desc,delete_ind,create_timestamp,created_by,modified_by,modify_timestamp,location_id,coll_date_time_tz,spec_rcv_date_time_tz,date_time_reported_tz,create_timestamp_tz,modify_timestamp_tz,microbiology_ind,obr_comment,pid_comment,loinc_code,ng_test_desc,confidential_ind,placer_ord_num_ie,filler_ord_num_ie,req_accession_msg,req_accession_namespc_id,prod_accession_msg,prod_accession_namespc_id,order_test_id)
Select @enterprise_id,@practice_id,@person_id,@r_msg_control_id,'OBR','1',@r_unique_obr_num,NULL,@r_order_num,'339969354502014','00000-0^Test',CONVERT(char(10),GETDATE(), 23)+ ' ' + CONVERT(char(5),GETDATE(), 108)+':00.000',CONVERT(varchar,GETDATE(), 23)+' '+'00:00:00.000',@provider_id,@r_ufo_num,@r_ufo_num,CONVERT(char(10),GETDATE(), 23)+ ' ' + CONVERT(char(5),GETDATE(), 108)+':00.000',@r_test_status_letter,'Fake X-Ray','N',GETDATE(),'-101','-101',GETDATE(),@location_id,0,0,0,0,0,'N','Performed At: NextCare Automation System 111222 Mirth Corp, Anywhere, TN, 272150000 Testing, Pathologist, MD, Phone: 5558675309','THIS IS A TEST RESULT','00000-0','Fake X-RAY','N',@r_ufo_num+'^LAB',NULL,@r_ufo_num,'LAB',NULL,NULL,@r_order_test_id

----------------------------------------------------------------------------------------
--3) Lab Results OBR2 Table
----------------------------------------------------------------------------------------
INSERT INTO lab_results_obr2_p (enterprise_id,practice_id,person_id,unique_obr_num,create_timestamp,created_by,modified_by,modify_timestamp)
Select @enterprise_id,@practice_id,@person_id,@r_unique_obr_num,GETDATE(),'-101','-101',GETDATE()
--Select * from lab_results_obr2_p where unique_obr_num='392ACA55-9D0B-4404-A3EC-9961E8637CE5'
--from lab_results_obr_p where person_id='C452B259-796D-44C2-8249-0967573124E9' and order_test_id='44BC74AC-5E61-43BF-BE39-BCA2735C3EA0'

----------------------------------------------------------------------------------------
--4) Lab Results OBX Table
----------------------------------------------------------------------------------------
INSERT INTO lab_results_obx (enterprise_id,practice_id,person_id,seg_id,unique_obr_num,obx_seq_num,value_type,obs_id,observ_value,units,ref_range,abnorm_flags,nature_abnorm_chk1,observ_result_stat,last_change_dt,obs_date_time,prod_id_code1,prod_id_code1_txt,signed_off_ind,result_desc,delete_ind,comment_ind,result_seq_num,created_by,create_timestamp,modified_by,modify_timestamp,last_change_dt_tz,obs_date_time_tz,create_timestamp_tz,modify_timestamp_tz,result_comment,units_batt_id)
/*
Select * from [ngtraining].dbo.lab_results_obx 
where result_desc not like 'RAD Report' 
and unique_obr_num='6E0620A7-C01A-4AFC-A933-1F7C41CDD352'
order by obx_seq_num
*/
Values	(@enterprise_id,@practice_id,@person_id,'OBX',@r_unique_obr_num,'1','TX','RAD REPORT^RAD REPORT^','Left Ankle, 2 view :',NULL,NULL,NULL,'N',@r_test_status_letter,NULL,GETDATE(),'Appdev','Appdev^Fake_result_generator','N','RAD REPORT','N','N','65536','-101',GETDATE(),'-101',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
			,(@enterprise_id,@practice_id,@person_id,'OBX',@r_unique_obr_num,'2','TX','RAD REPORT^RAD REPORT^','Comparison: Normal right ankle',NULL,NULL,NULL,'N',@r_test_status_letter,NULL,GETDATE(),'Appdev','Appdev^Fake_result_generator','N','RAD REPORT','N','N','65536','-101',GETDATE(),'-101',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
				,(@enterprise_id,@practice_id,@person_id,'OBX',@r_unique_obr_num,'3','TX','RAD REPORT^RAD REPORT^','Moderate lateral soft tissue swelling.',NULL,NULL,NULL,'N',@r_test_status_letter,NULL,GETDATE(),'Appdev','Appdev^Fake_result_generator','N','RAD REPORT','N','N','65536','-101',GETDATE(),'-101',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
					,(@enterprise_id,@practice_id,@person_id,'OBX',@r_unique_obr_num,'4','TX','RAD REPORT^RAD REPORT^','No acute fracture.',NULL,NULL,NULL,'N',@r_test_status_letter,NULL,GETDATE(),'Appdev','Appdev^Fake_result_generator','N','RAD REPORT','N','Y','65536','-101',GETDATE(),'-101',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
						,(@enterprise_id,@practice_id,@person_id,'OBX',@r_unique_obr_num,'5','TX','RAD REPORT^RAD REPORT^','There is no subluxation or dislocation.',NULL,NULL,NULL,'N',@r_test_status_letter,NULL,GETDATE(),'Appdev','Appdev^Fake_result_generator','N','RAD REPORT','N','Y','65536','-101',GETDATE(),'-101',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
							,(@enterprise_id,@practice_id,@person_id,'OBX',@r_unique_obr_num,'6','TX','RAD REPORT^RAD REPORT^','Soft tissues demonstrate no radio-opaque foreign body.',NULL,NULL,NULL,'N',@r_test_status_letter,NULL,GETDATE(),'Appdev','Appdev^Fake_result_generator','N','RAD REPORT','N','N','65536','-101',GETDATE(),'-101',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
								,(@enterprise_id,@practice_id,@person_id,'OBX',@r_unique_obr_num,'7','TX','RAD REPORT^RAD REPORT^','No blastic / lytic destructive lesion or osteomyelitis.',NULL,NULL,NULL,'N',@r_test_status_letter,NULL,GETDATE(),'Appdev','Appdev^Fake_result_generator','N','RAD REPORT','N','Y','65536','-101',GETDATE(),'-101',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
									,(@enterprise_id,@practice_id,@person_id,'OBX',@r_unique_obr_num,'8','TX','RAD REPORT^RAD REPORT^','Bone density appropriate for patient age.',NULL,NULL,NULL,'N',@r_test_status_letter,NULL,GETDATE(),'Appdev','Appdev^Fake_result_generator','N','RAD REPORT','N','Y','65536','-101',GETDATE(),'-101',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
										,(@enterprise_id,@practice_id,@person_id,'OBX',@r_unique_obr_num,'9','TX','RAD REPORT^RAD REPORT^','CONCLUSION :',NULL,NULL,NULL,'N',@r_test_status_letter,NULL,GETDATE(),'Appdev','Appdev^Fake_result_generator','N','RAD REPORT','N','N','65536','-101',GETDATE(),'-101',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
											,(@enterprise_id,@practice_id,@person_id,'OBX',@r_unique_obr_num,'10','TX','RAD REPORT^RAD REPORT^','No acute traumatic bony findings evident radiographically.',NULL,NULL,NULL,'N',@r_test_status_letter,NULL,GETDATE(),'Appdev','Appdev^Fake_result_generator','N','RAD REPORT','N','Y','65536','-101',GETDATE(),'-101',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
												,(@enterprise_id,@practice_id,@person_id,'OBX',@r_unique_obr_num,'11','TX','RAD REPORT^RAD REPORT^','Electronically signed by: Blake M. Berman, M.D. on 02/17/2016 11:27:23',NULL,NULL,NULL,'N',@r_test_status_letter,NULL,GETDATE(),'Appdev','Appdev^Fake_result_generator','N','RAD REPORT','N','Y','65536','-101',GETDATE(),'-101',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
----------------------------------------------------------------------------------------
--5) Lab Results Patient Table
----------------------------------------------------------------------------------------
INSERT INTO lab_results_patient (enterprise_id,practice_id,person_id,order_num,msg_control_id,last_name,first_name,date_of_birth,sex,created_by,create_timestamp,modified_by,modify_timestamp)
Select @enterprise_id,@practice_id,@person_id,@r_order_num,@r_msg_control_id,last_name,first_name,date_of_birth,sex,'-101',GETDATE(),'-101',GETDATE() 
from person p where p.person_id=@person_id

SET @result_status_msg='The order has been given a result.'
--RETURN @result_status_msg

----------------------------------------------------------------------------------------
--5) Lab Result Task
----------------------------------------------------------------------------------------
INSERT INTO user_todo_list (enterprise_id,practice_id,user_id,task_id,task_priority,task_completed,task_due_date,task_subj,task_desc,task_assgn,task_owner,task_deleted,pat_acct_id,pat_enc_id,pat_item_id,pat_item_type,old_pat_item_id,read_flag,created_by,create_timestamp,modified_by,modify_timestamp)
Select @enterprise_id,@practice_id,0,NEWID(),'1','0',GETDATE()+1,CASE @r_lab_vendor_desc WHEN 'OnePacs' THEN 'OnePacs Radiology Report' WHEN 'CPL' THEN 'CPL Lab Result' WHEN 'Sonora Quest' THEN 'Quest Lab Results' ELSE @r_lab_vendor_desc+' Lab Results' END,'OnePacs Result','A',NULL,NULL,@person_id,@enc_id,'','L','','N','-101',GETDATE(),'-101',GETDATE()
END