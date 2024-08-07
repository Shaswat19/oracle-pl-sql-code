--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
-- LOAD to ODS_USER.STG_OSMR_AVE_MRC (CRM)
-- will run after load/update of OSMR details [OSMR staging for average MRC]
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
TRUNCATE TABLE ODS_USER.STG_OSMR_AVE_MRC_TMP;
INSERT INTO ODS_USER.STG_OSMR_AVE_MRC_TMP
select * from ODS_USER.STG_OSMR_AVE_MRC;

TRUNCATE TABLE ODS_USER.STG_OSMR_AVE_MRC;
INSERT INTO ODS_USER.STG_OSMR_AVE_MRC
select a.order_no order_no,
       service_order_no so_no,
       a.product,
       service_order_serv_type so_serv_type,
       pmrc.mrc/prod_cnt ave_mrc,
       pmrc.nrc/prod_cnt ave_nrc,
       sysdate load_date
from ODS_USER.STG_OSMR_DTLS a,
     (select order_no,count(*) prod_cnt
      from ODS_USER.STG_OSMR_DTLS
      where source_system = 'CRM'
        and bill_system_bundle_id is not null
        and order_product_type <>  'Bundle'
      group by order_no) pcnt,
     (select order_no,sum(mrc) mrc, sum(nrc) nrc
      from ODS_USER.STG_OSMR_DTLS
      where source_system = 'CRM'
        and bill_system_bundle_id is not null
      group by order_no) pmrc
where source_system = 'CRM'
  and a.order_no = pcnt.order_no
  and pcnt.order_no = pmrc.order_no
  and order_product_type <>  'Bundle'
  and bill_system_bundle_id is not null;
commit;