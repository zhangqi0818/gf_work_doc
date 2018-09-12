select max(busi_date),min(busi_date),count(1) from ACCT_ACCOUNT_S;

select busi_date,count(1)
from ACCT_ACCOUNT_S
where busi_date>='2018-08-01'
group by busi_date 
order by busi_date desc;


