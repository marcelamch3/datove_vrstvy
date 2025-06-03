rn_w_vatCREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L2.L2_branch` AS
select
branch_id, ---PK
branch_name,

FROM `tokyo-comfort-455613-e1.L1.L1_branch`
WHERE branch_name IS NOT NULL AND branch_name != "unknown"

CREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L2.L2_invoice` AS
SELECT
  invoice_id, -- PK
  invoice_previous_id,
  contract_id, -- FK
  
  ROW_NUMBER() OVER (
  PARTITION BY contract_id
  ORDER BY date_issue
  ) AS invoice_order,

  date_issue,
  due_date,
  paid_date,
  start_date,
  end_date,

  IF(amount_w_vat <= 0, 0, amount_w_vat) AS amount_w_vat,
  IF(amount_w_vat <= 0, 0, amount_w_vat / 1.20) AS amount_wo_vat,
  return_w_vat,
  amount_payed,
  date_insert,
  status_int, --- ze status sloupec int status int a flag_invoice_issued jako popis "issued" pod 100 a "not issued" osotatní
  flag_invoice_issued,
  date_update,
  invoice_type_id,
  invoice_type,
FROM `tokyo-comfort-455613-e1.L1.L1_invoice`
where invoice_type = "invoice"
and flag_invoice_issued ="issued"
;

CREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L2.L2_product` AS
select
product_id,
name,
type,
category,
FROM `tokyo-comfort-455613-e1.L1.L1_product`
where category in ("product", "rent")


CREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L2.L2_product_purchase` AS
SELECT
product_purchase_id,  ---PK
contract_id,  ---FK
product_id, --FK
create_date,
product_valid_from,
product_valid_to,
IF(product_valid_to < DATE '2035-12-31', FALSE, TRUE) AS flag_unlimited_product,
IF(price_wo_vat <= 0, 0, price_wo_vat) AS price_wo_vat,
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
contract_status,
load_date,
FROM `tokyo-comfort-455613-e1.L1.L1_contract`
where registred_date is not null;
