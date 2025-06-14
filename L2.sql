--L2_branch
CREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L2.L2_branch` AS
select
branch_id, ---PK
branch_name,
FROM tokyo-comfort-455613-e1.L1.L1_branch 
WHERE branch_name IS NOT NULL AND branch_name != "unknown"

--L2_invoice
  --zde jsi se vůbec neodkazovala na sloupce a zapomněla jsi na INNER JOIN
CREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L2.L2_invoice` AS
SELECT
 SELECT
 invoice.invoice_id
 ,invoice.contract_id
 ,invoice.date_issue
 ,invoice.due_date
 ,invoice.paid_date
 ,invoice.start_date
 ,invoice.end_date
 ,invoice.amount_w_vat
 ,invoice.return_w_vat
 ,CASE
   WHEN invoice.amount_w_vat <= 0 THEN 0
   WHEN invoice.amount_w_vat >0 THEN amount_w_vat / 1.2
  END AS amount_wo_vat_usd  
 ,invoice.date_insert as insert_date
 ,invoice.update_date
 ,ROW_NUMBER() OVER (PARTITION BY invoice.contract_id order by invoice.date_issue asc) AS invoice_order

FROM tokyo-comfort-455613-e1.L1.L1_invoice invoice
INNER JOIN tokyo-comfort-455613-e1.L1.L1_contract contract
   ON invoice.contract_id = contract.contract_id
WHERE invoice.invoice_type = 'invoice'
 AND flag_invoice_issued
;


--L2_product
CREATE OR REPLACE VIEW tokyo-comfort-455613-e1.L2.L2_product AS
select
product_id,
name,
type,
category,
FROM tokyo-comfort-455613-e1.L1.L1_product
where category in ("product", "rent")

--L2_product_purchase
CREATE OR REPLACE VIEW tokyo-comfort-455613-e1.L2.L2_product_purchase AS
SELECT
product_purchase_id,  ---PK
contract_id,  ---FK
product_id, --FK
create_date,
product_valid_from,
product_valid_to,
IF(product_valid_to < DATE '2035-12-31', FALSE, TRUE) AS flag_unlimited_product,
IF(price_wo_vat <= 0, 0, price_wo_vat * 1.20) AS price_w_vat,
date_update,
product_status,   --FK
measure_unit,
branch_id, --FK
product_name,
product_type,
product_category,
status_name
FROM `tokyo-comfort-455613-e1.L1.L1_product_purchase`
where product_category in ("product", "rent")
  AND status_name NOT IN ("Canceled", "Canceled registration", "Disconnected")
  AND status_name IS NOT NULL;

--L2_contract
CREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L2.L2_contract` AS
SELECT
contract_id , -- PK
branch_id , ---FK
contract_valid_from,
contract_valid_to,
registred_date,
signed_date,
activation_process_date,
prolongation_date,
registration_end_reason,
flag_prolongation, ---ověřeno dříve distinct, že jsou jen true or false
flag_send_inv_email,  ---ověřeno dříve distinct, že jsou jen true or false
contract_status
FROM tokyo-comfort-455613-e1.L1.L1_contract
where registred_date is not null;
