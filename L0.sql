CREATE OR REPLACE VIEW `tokyo-comfort-455613-e1.L1.L1_branch` AS
select
SAFE_CAST(id_branch AS INT64) AS branch_id, ---PK
branch_name AS branch_name,
DATE(DATETIME(TIMESTAMP(date_update), "Europe/Prague")) AS product_status_update_date
FROM `tokyo-comfort-455613-e1.L0_google_sheet.branch`
WHERE id_branch != "NULL"