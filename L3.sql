CREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L3.L3_branch` AS
select
branch_id, ---PK
branch_name,
FROM `tokyo-comfort-455613-e1.L2.L2_branch`
WHERE branch_name IS NOT NULL AND branch_name != "unknown"

CREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L3.L3_invoice` AS
SELECT
  invoice_id, -- PK
  contract_id, -- FK
  paid_date,
  amount_w_vat,
  return_w_vat,
  amount_w_vat - return_w_vat as total_paid 
FROM `tokyo-comfort-455613-e1.L2.L2_invoice`

CREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L3.L3_product_purchase` AS
SELECT
product_purchase_id,  ---PK
contract_id,  ---FK
product_id, --FK
product_valid_from,
product_valid_to,
flag_unlimited_product,
measure_unit,
product_name,
product_type,
FROM `tokyo-comfort-455613-e1.L2.L2_product_purchase`
where product_name is not null


CREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L3.L3_fact_contract` AS
SELECT
c.contract_id , -- PK
c.branch_id , ---FK
c.contract_valid_from,
c.contract_valid_to,
CASE 
  WHEN DATE_DIFF(c.contract_valid_to, c.contract_valid_from, DAY) < 183 THEN 'less than half year'
  WHEN DATE_DIFF(c.contract_valid_to, c.contract_valid_from, DAY) < 548 THEN '1 year'
  WHEN DATE_DIFF(c.contract_valid_to, c.contract_valid_from, DAY) < 913 THEN '2 years'
  ELSE 'more than 2 years'
END AS contract_duration,
EXTRACT(YEAR FROM contract_valid_from) AS contract_start_year,
c.registration_end_reason,
c.flag_prolongation, 
c.contract_status,

SUM(i.total_paid) AS total_paid,
SUM(i.amount_w_vat) AS amount_w_vat,
SUM(i.return_w_vat) AS return_w_vat,
COUNT(i.invoice_id) AS invoice_count

FROM `tokyo-comfort-455613-e1.L2.L2_contract` c
LEFT JOIN `tokyo-comfort-455613-e1.L3.L3_invoice` i
  ON c.contract_id = i.contract_id
where registred_date is not NULL and contract_valid_from is not NULL and contract_valid_to is not NULL

GROUP BY
  c.contract_id,
  c.branch_id,
  c.contract_valid_from,
  c.contract_valid_to,
  contract_duration,
  contract_start_year,
  c.registration_end_reason,
  c.flag_prolongation,
  c.contract_status;
