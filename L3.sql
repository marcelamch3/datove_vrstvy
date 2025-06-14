--L3_branch
CREATE OR REPLACE VIEW tokyo-comfort-455613-e1.L3.L3_branch AS
select
branch_id, ---PK
branch_name,
FROM tokyo-comfort-455613-e1.L2.L2_branch;

--L3_invoice
CREATE OR REPLACE VIEW tokyo-comfort-455613-e1.L3.L3_invoice AS
SELECT
  L2_invoice.invoice_id
 ,L2_invoice.contract_id
 ,L2_product_purchase.product_id
 ,L2_invoice.paid_date
 ,L2_invoice.amount_w_vat
 ,L2_invoice.return_w_vat
 amount_w_vat - return_w_vat as total_paid 
FROM `tokyo-comfort-455613-e1.L2.L2_invoice`
LEFT JOIN tokyo-comfort-455613-e1.L2.L2_product_purchase L2_product_purchase ON L2_product_purchase.contract_id = L2_invoice.contract_id
WHERE L2_product_purchase.product_id IS NOT NULL;

--L3_product
CREATE OR REPLACE VIEW tokyo-comfort-455613-e1.L3.L3_product AS
SELECT
L2_product_purchase.product_purchese_id 
 ,L2_product.product_id
 ,L2_product_purchase.product_valid_from
 ,L2_product_purchase.product_valid_to
 ,L2_product_purchase.unit
 ,L2_product_purchase.flag_unlimited_product
 ,L2_product.product_name
 ,L2_product.product_type
FROM `tokyo-comfort-455613-e1.L2.L2_product_purchase`
LEFT JOIN `sacred-booking-455420-p5.L2.L2_product` L2_product --ZDE NAHRADIT TABULKU ZA TVOJÍ!!!!
  ON L2_product_purchase.product_id = L2_product.product_id
;


--L3_contract
CREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L3.L3_fact_contract` AS
SELECT
contract_id , -- PK
branch_id , ---FK
contract_valid_from,
contract_valid_to,
CASE 
  WHEN DATE_DIFF(c.contract_valid_to, c.contract_valid_from, DAY) < 183 THEN 'less than half year'
  WHEN DATE_DIFF(c.contract_valid_to, c.contract_valid_from, DAY) < 548 THEN '1 year'
  WHEN DATE_DIFF(c.contract_valid_to, c.contract_valid_from, DAY) < 913 THEN '2 years'
  ELSE 'more than 2 years'
END AS contract_duration,
EXTRACT(YEAR FROM contract_valid_from) AS contract_start_year
FROM tokyo-comfort-455613-e1.L2.L2_contract;
