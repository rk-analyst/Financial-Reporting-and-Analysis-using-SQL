

-- Creating a view for average revenue per account (ARPA) is a profitability measure that assesses a company’s revenue per customer account 
create or replace view H_Accounting.zzennour2018_view as ( select year(entry_date) as year_entry, a.account , format(avg (case when ss.statement_section_code IN ('REV' , 'OI') and  jeli.credit !='' then jeli.credit end), 0) as arpa
    from statement_section AS ss
        INNER JOIN
    `account` AS a ON a.profit_loss_section_id = ss.statement_section_id
        INNER JOIN
    journal_entry_line_item AS jeli ON a.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
   group by year_entry, a.account) ;
   
   -- We noted that 20 of 220 rows are not null so we filtered on the non null values only 
   select * from H_Accounting.zzennour2018_view
   where arpa is not null; 
   
   -- Interpretation : This metric is extremely valuable in providing an overview of a company’s profitability per account basis. In addition, it reveals which company’s services generate the most and the least revenue. For instance, here the least profitable account for the startup is GAIN ON CURRENCY EXCHANGE in 2017 and the highest one is PACIFIC U, INC in two respective years 2015 and 2016 