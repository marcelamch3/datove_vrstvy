CREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L1.L1_product_purchase` AS
SELECT
CAST(pp.id_package as INT64) as product_purchase_id,  ---PK
CAST(pp.id_contract AS INT64) AS contract_id,  ---FK
CAST(pp.id_package_template AS INT64) AS product_id, --FK
DATE(DATETIME(TIMESTAMP(pp.date_insert), "Europe/Prague")) AS create_date,
DATE(DATETIME(TIMESTAMP(pp.start_date), "Europe/Prague")) AS product_valid_from,
DATE(DATETIME(TIMESTAMP(pp.end_date), "Europe/Prague")) AS product_valid_to,
SAFE_CAST(pp.fee AS FLOAT64) AS price_wo_vat,
DATE(DATETIME(TIMESTAMP(pp.date_update), "Europe/Prague")) AS date_update,
SAFE_CAST(pp.package_status AS INT64) AS product_status,   --FK
pp.measure_unit AS measure_unit,
SAFE_CAST(pp.id_branch AS INT64) AS branch_id, --FK
DATE(DATETIME(TIMESTAMP(pp.load_date), "Europe/Prague")) AS load_date,

p.name AS product_name,
p.type AS product_type,
p.category AS product_category,
s.status_name AS status_name

FROM `tokyo-comfort-455613-e1.L0_crm.package_puchase` AS pp
LEFT JOIN `tokyo-comfort-455613-e1.L0_google_sheet.product` AS p
 ON SAFE_CAST(pp.id_package_template AS INT64) = SAFE_CAST(p.id_product AS INT64)
LEFT JOIN `tokyo-comfort-455613-e1.L0_google_sheet.status` AS s
 ON SAFE_CAST(pp.package_status AS INT64) = SAFE_CAST(s.id_status AS INT64)
 where pp.id_package is not null
 QUALIFY ROW_NuMBER() OVER(PARTITION BY pp.id_package) = 1

CREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L1.L1_branch` AS
select
SAFE_CAST(id_branch AS INT64) AS branch_id, ---PK
branch_name AS branch_name,
DATE(DATETIME(TIMESTAMP(date_update), "Europe/Prague")) AS product_status_update_date
FROM `tokyo-comfort-455613-e1.L0_google_sheet.branch`
WHERE id_branch != "NULL"

CREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L1.L1_contract` AS
SELECT
CAST(id_contract AS INT64) AS contract_id, -- PK
CAST(id_branch AS INT64) AS branch_id, ---FK
DATE(DATETIME(TIMESTAMP(date_contract_valid_from), "Europe/Prague")) AS contract_valid_from,
DATE(DATETIME(TIMESTAMP(date_contract_valid_to), "Europe/Prague")) AS contract_valid_to,
DATE(DATETIME(TIMESTAMP(date_registered), "Europe/Prague")) AS registred_date,
DATE(DATETIME(TIMESTAMP(date_signed), "Europe/Prague")) AS signed_date,
DATE(DATETIME(TIMESTAMP(activation_process_date), "Europe/Prague")) AS activation_process_date,
DATE(DATETIME(TIMESTAMP(prolongation_date), "Europe/Prague")) AS prolongation_date,
registration_end_reason AS registration_end_reason,
CAST(flag_prolongation AS BOOL) AS flag_prolongation, ---ověřeno dříve distinct, že jsou jen true or false
CAST(flag_send_inv_email AS BOOL) AS flag_send_inv_email,  ---ověřeno dříve distinct, že jsou jen true or false
contract_status AS contract_status,
DATE(DATETIME(TIMESTAMP(load_date), "Europe/Prague")) AS load_date,
FROM `tokyo-comfort-455613-e1.L0_crm.contract`
where
id_contract IS NOT NULL
and id_branch IS NOT NULL
QUALIFY ROW_NuMBER() OVER(PARTITION BY id_contract) = 1
;


CREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L1.L1_invoice` AS
SELECT
  CAST(id_invoice AS INT64) AS invoice_id, -- PK
  CAST(id_invoice_old AS INT64) AS invoice_previous_id,
  CAST(invoice_id_contract AS INT64) AS contract_id, -- FK

  DATE(DATETIME(TIMESTAMP(date), "Europe/Prague")) AS date_issue,
  DATE(DATETIME(TIMESTAMP(scadent), "Europe/Prague")) AS due_date,
  DATE(DATETIME(TIMESTAMP(date_paid), "Europe/Prague")) AS paid_date,
  DATE(DATETIME(TIMESTAMP(start_date), "Europe/Prague")) AS start_date,
  DATE(DATETIME(TIMESTAMP(end_date), "Europe/Prague")) AS end_date,

  SAFE_CAST(value AS FLOAT64) AS amount_w_vat,
  CAST(number AS INT64) AS invoice_number,
  CAST(flag_paid_currier AS BOOL) AS flag_paid_currier, --- oveřeno pomoví DISTINCT, že obsahuje jen true or false
  SAFE_CAST(payed AS FLOAT64) AS amount_payed,
  SAFE_CAST(value_storno AS FLOAT64) AS return_w_vat,
  DATE(DATETIME(TIMESTAMP(date_insert), "Europe/Prague")) AS date_insert,
  SAFE_CAST(status AS INT64) AS status_int, --- ze status sloupec int status int a flag_invoice_issued jako popis "issued" pod 100 a "not issued" osotatní
  CASE
    WHEN SAFE_CAST(status AS INT64) < 100 THEN 'issued'
    ELSE 'not issued'
  END AS flag_invoice_issued,
  DATE(DATETIME(TIMESTAMP(date_update), "Europe/Prague")) AS date_update,
  CAST(id_branch AS INT64) AS branch_id, -- FK  --- ověřeno dríve, že žádná hodnota není Null


  SAFE_CAST(invoice_type AS INT64) AS invoice_type_id,
  CASE
    WHEN SAFE_CAST(invoice_type AS INT64) = 1 THEN 'invoice'
    WHEN SAFE_CAST(invoice_type AS INT64) = 2 THEN 'return'
    WHEN SAFE_CAST(invoice_type AS INT64) = 3 THEN 'credit_note'
    WHEN SAFE_CAST(invoice_type AS INT64) = 4 THEN 'other'
    ELSE 'unknown'
  END AS invoice_type

FROM `tokyo-comfort-455613-e1.L0_accounting_system.invoice`
WHERE id_invoice IS NOT NULL 
QUALIFY ROW_NuMBER() OVER(PARTITION BY id_invoice) = 1

create or replace view `tokyo-comfort-455613-e1.L1.L1_invoice_load` as 
select
  SAFE_CAST(id_load AS INT64) AS load_id, ----PK
  SAFE_CAST(id_contract AS INT64) AS contract_id, ---FK
  SAFE_CAST(id_package AS INT64) AS package_id, ----FK
  SAFE_CAST(id_package_template AS FLOAT64) AS package_template_id, ---FK
  SAFE_CAST(notlei AS FLOAT64) AS notlei,
  currency AS currency,
  SAFE_CAST(tva AS INT64) AS tva,
  SAFE_CAST(value AS FLOAT64) AS value,
  SAFE_CAST(payed AS FLOAT64) AS payed,
  um AS unit_of_measure,
  case 
    when um IN ('mesia','m?síce','m?si?1ce','měsice','mesiace','měsíce','mesice') then  'month'
    when um = "kus" then "item"
    when um = "den" then 'day'
    when um = "min" then 'minute'
    when um = '0' then null 
    else um end AS unit,
  DATE(DATETIME(TIMESTAMP(start_date), "Europe/Prague")) AS start_date,
  DATE(DATETIME(TIMESTAMP(end_date), "Europe/Prague")) AS end_date,
  DATE(DATETIME(TIMESTAMP(date_insert), "Europe/Prague")) AS date_insert,
  DATE(DATETIME(TIMESTAMP(date_update), "Europe/Prague")) AS date_update,
  SAFE_CAST(id_invoice AS INT64) AS invoice_id,
  DATE(DATETIME(TIMESTAMP(date_load), "Europe/Prague")) AS load_date

from `tokyo-comfort-455613-e1.L0_accounting_system.invoice_load`
where id_load is not NULL and id_contract is not NULL and id_package is not NULL and id_package_template is not NULL
QUALIFY ROW_NuMBER() OVER(PARTITION BY id_load) = 1


CREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L1.L1_product` AS
select
CAST(id_product as INT64) as product_id,
LOWER(name) AS name,
LOWER(type) AS type,
LOWER(category) AS category,
CAST(is_vat_applicable AS BOOL) AS is_vat_applicable,
DATE(DATETIME(TIMESTAMP(date_update), "Europe/Prague")) AS date_update
FROM `tokyo-comfort-455613-e1.L0_google_sheet.product`
where id_product is not NULL
QUALIFY ROW_NuMBER() OVER(PARTITION BY id_product) = 1

create or replace view `tokyo-comfort-455613-e1.L1.L1_status` as 
select
cast(id_status as INT) AS product_status_id
,LOWER(status_name) AS product_status_name
,DATE(TIMESTAMP(date_update), "Europe/Prague") AS product_status_update_date
from `tokyo-comfort-455613-e1.L0_google_sheet.status`
where
id_status IS NOT NULL
and status_name IS NOT NULL
QUALIFY ROW_NuMBER() OVER(PARTITION BY id_status) = 1
;
