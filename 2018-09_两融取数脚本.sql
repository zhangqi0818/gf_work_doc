-- 按照与有效户同期的3个月测算，计算四类客户的期末的客户数、两融余额、净资产指标。只统计当前有信用账户，且账户状态正常的客户。
select SUM(CASE WHEN T_ASSET.crd_asset=0 AND T_ASSET.crd_liab=0 AND T_EXCH.cust_mts_total_exch_amt=0 THEN 1 ELSE 0 END) AS 客户数_不活跃户
    ,SUM(CASE WHEN T_ASSET.crd_asset>0 AND T_ASSET.crd_liab=0 AND T_EXCH.cust_mts_total_exch_amt=0 THEN 1 ELSE 0 END) AS 客户数_一级活跃户
    ,SUM(CASE WHEN T_ASSET.crd_asset>0 AND T_ASSET.crd_liab=0 AND T_EXCH.cust_mts_total_exch_amt>0 THEN 1 ELSE 0 END) AS 客户数_二级活跃户
    ,SUM(CASE WHEN T_ASSET.crd_asset>0 AND T_ASSET.crd_liab>0 AND T_EXCH.cust_mts_total_exch_amt>0 THEN 1 ELSE 0 END) AS 客户数_三级活跃户
    
    ,SUM(CASE WHEN T_ASSET.crd_asset>0 AND T_ASSET.crd_liab>0 AND T_EXCH.cust_mts_total_exch_amt=0 THEN 1 ELSE 0 END) AS 客户数_有资产及负债无交易
    
    ,SUM(CASE WHEN T_ASSET.crd_asset=0 AND T_ASSET.crd_liab=0 AND T_EXCH.cust_mts_total_exch_amt=0 THEN T_ASSET_CURR.crd_liab ELSE 0 END) AS 融资融券余额_不活跃户
    ,SUM(CASE WHEN T_ASSET.crd_asset>0 AND T_ASSET.crd_liab=0 AND T_EXCH.cust_mts_total_exch_amt=0 THEN T_ASSET_CURR.crd_liab ELSE 0 END) AS 融资融券余额_一级活跃户
    ,SUM(CASE WHEN T_ASSET.crd_asset>0 AND T_ASSET.crd_liab=0 AND T_EXCH.cust_mts_total_exch_amt>0 THEN T_ASSET_CURR.crd_liab ELSE 0 END) AS 融资融券余额_二级活跃户
    ,SUM(CASE WHEN T_ASSET.crd_asset>0 AND T_ASSET.crd_liab>0 AND T_EXCH.cust_mts_total_exch_amt>0 THEN T_ASSET_CURR.crd_liab ELSE 0 END) AS 融资融券余额_三级活跃户
    
    ,SUM(CASE WHEN T_ASSET.crd_asset>0 AND T_ASSET.crd_liab>0 AND T_EXCH.cust_mts_total_exch_amt=0 THEN T_ASSET_CURR.crd_liab ELSE 0 END) AS 融资融券余额_有资产及负债无交易
    
    ,SUM(CASE WHEN T_ASSET.crd_asset=0 AND T_ASSET.crd_liab=0 AND T_EXCH.cust_mts_total_exch_amt=0 THEN T_ASSET_CURR.crd_asset ELSE 0 END) AS 信用净资产_不活跃户
    ,SUM(CASE WHEN T_ASSET.crd_asset>0 AND T_ASSET.crd_liab=0 AND T_EXCH.cust_mts_total_exch_amt=0 THEN T_ASSET_CURR.crd_asset ELSE 0 END) AS 信用净资产_一级活跃户
    ,SUM(CASE WHEN T_ASSET.crd_asset>0 AND T_ASSET.crd_liab=0 AND T_EXCH.cust_mts_total_exch_amt>0 THEN T_ASSET_CURR.crd_asset ELSE 0 END) AS 信用净资产_二级活跃户
    ,SUM(CASE WHEN T_ASSET.crd_asset>0 AND T_ASSET.crd_liab>0 AND T_EXCH.cust_mts_total_exch_amt>0 THEN T_ASSET_CURR.crd_asset ELSE 0 END) AS 信用净资产_三级活跃户
    
    ,SUM(CASE WHEN T_ASSET.crd_asset>0 AND T_ASSET.crd_liab>0 AND T_EXCH.cust_mts_total_exch_amt=0 THEN T_ASSET_CURR.crd_asset ELSE 0 END) AS 信用净资产_有资产及负债无交易
from PDATA.CUST_BRK_BASE_INFO_S T_CUST
left join (
    select cust_pty_no, sum(crd_asset) as crd_asset, sum(crd_liab) as crd_liab
    from PDATA.INDEX_CUST_ASSET_DAY_S
    where busi_date >= '2018-06-11'
    group by cust_pty_no
) T_ASSET ON T_CUST.CUST_PTY_NO=T_ASSET.CUST_PTY_NO
LEFT JOIN (
    select cust_pty_no, sum(cust_mts_total_exch_amt) as cust_mts_total_exch_amt
    from PDATA.INDEX_AGG_CUST_TRADE_DAY_S
    where busi_date >= '2018-06-11'
    group by cust_pty_no
) T_EXCH ON T_CUST.CUST_PTY_NO=T_EXCH.CUST_PTY_NO
LEFT JOIN PDATA.INDEX_CUST_ASSET_DAY_S T_ASSET_CURR ON T_CUST.CUST_PTY_NO=T_ASSET_CURR.CUST_PTY_NO AND T_CUST.BUSI_DATE=T_ASSET_CURR.BUSI_DATE
WHERE T_CUST.BUSI_DATE='2018-09-11'
AND T_CUST.CUST_STATUS_NAME='正常'
AND trim(mts_cptl_acct_no)<>''
and credit_end_date='2099-12-31'
