USE H_Accounting;
DELIMITER $$

drop procedure if exists H_Accounting.trio11_zzennour2018;
CREATE PROCEDURE H_Accounting.trio11_zzennour2018(varCalendarYear SMALLINT)
BEGIN
 
 	-- We receive as an argument the year for which we will generate the dashboard of financial metrics we implemented, for that we will need to store values from the balance sheet or P&L into variables 
    -- This approch will make it easy to implement equaltions 
    -- This value is stored as a 'YEAR' type in the variable `varCalendarYear`
    
    
	DECLARE currentLiability DOUBLE DEFAULT 0;
	DECLARE currentAsset DOUBLE DEFAULT 0;
    DECLARE totalExpense DOUBLE DEFAULT 0;
	DECLARE totalIncome DOUBLE DEFAULT 0;
    DECLARE totalAsset DOUBLE DEFAULT 0;
    DECLARE totalEquity DOUBLE DEFAULT 0;
	DECLARE costGoods DOUBLE DEFAULT 0;
    
    -- Querying COST OF GOODS AND SERVICES for each year and storing it into a variable 
     select  SUM(case when ss.statement_section_code ='COGS'  then jeli.debit end ) into costGoods 
    from statement_section AS ss
        INNER JOIN
    `account` AS a ON a.profit_loss_section_id = ss.statement_section_id
        INNER JOIN
    journal_entry_line_item AS jeli ON a.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    where YEAR(je.entry_date) = varCalendarYear  ;
 
     -- Querying the total expenses for each year and storing it into a variable  
   select  SUM(case when ss.statement_section_code IN ('RET' , 'GEXP','SEXP','OEXP','INCTAX','OTHTAX','COGS')  then jeli.debit end ) into totalExpense 
    from statement_section AS ss
        INNER JOIN
    `account` AS a ON a.profit_loss_section_id = ss.statement_section_id
        INNER JOIN
    journal_entry_line_item AS jeli ON a.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    where YEAR(je.entry_date) = varCalendarYear  ;
    
      -- Querying the total income for each year and storing it into a variable 
    select   SUM(case when ss.statement_section_code IN ('REV' , 'OI') and  jeli.credit !='' then jeli.credit end) into totalIncome
    from statement_section AS ss
        INNER JOIN
    `account` AS a ON a.profit_loss_section_id = ss.statement_section_id
        INNER JOIN
    journal_entry_line_item AS jeli ON a.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    where YEAR(je.entry_date) = varCalendarYear  ;
    
	-- Querying current assets for each year and storing it into a variable 
	select  round(sum(case when  ss.debit_is_positive = 0 then (jeli.credit) 
	when ss.debit_is_positive = 1 then (jeli.debit) end),0) into currentAsset
	FROM H_Accounting.journal_entry_line_item as jeli
	INNER JOIN  H_Accounting.journal_entry je 
	on jeli.journal_entry_id = je.journal_entry_id 
	inner join H_Accounting.account  as a
	on a.account_id = jeli.account_id
	inner join H_Accounting.statement_section ss
	on ss.statement_section_id = a.balance_sheet_section_id
	-- FILTERING ON ID = 61 corresponding to current assets
	where ss.statement_section_id = 61  
	and ss.is_balance_sheet_section = 1
	AND year(entry_date) =varCalendarYear;

	-- Querying current liabilities for each year and storing it into a variable 
    select round(sum(case when  ss.debit_is_positive = 0 then (jeli.credit) 
	when ss.debit_is_positive = 1 then (jeli.debit) end),0) into currentLiability
	FROM H_Accounting.journal_entry_line_item as jeli
	INNER JOIN  H_Accounting.journal_entry je 
	on jeli.journal_entry_id = je.journal_entry_id 
	inner join H_Accounting.account  as a
	on a.account_id = jeli.account_id
	inner join H_Accounting.statement_section ss
	on ss.statement_section_id = a.balance_sheet_section_id
	-- FILTERING ON ID = 64 corresponding to current liabilities
	where ss.statement_section_id = 64  
	and ss.is_balance_sheet_section = 1
	AND year(entry_date) =varCalendarYear;
    
    -- Querying total assets for each year and storing it into a variable 
	select  round(sum(case when  ss.debit_is_positive = 0 then (jeli.credit) 
	when ss.debit_is_positive = 1 then (jeli.debit) end),0) into totalAsset
	FROM H_Accounting.journal_entry_line_item as jeli
	INNER JOIN  H_Accounting.journal_entry je 
	on jeli.journal_entry_id = je.journal_entry_id 
	inner join H_Accounting.account  as a
	on a.account_id = jeli.account_id
	inner join H_Accounting.statement_section ss
	on ss.statement_section_id = a.balance_sheet_section_id
	-- FILTERING ON ID = 61 corresponding to current assets
	where ss.statement_section like '%asset%'
	and ss.is_balance_sheet_section = 1
	AND year(entry_date) =varCalendarYear;
    
    -- Querying total equity for each year and storing it into a variable 
    select  round(sum(case when  ss.debit_is_positive = 0 then (jeli.credit) 
	when ss.debit_is_positive = 1 then (jeli.debit) end),0) into totalEquity
	FROM H_Accounting.journal_entry_line_item as jeli
	INNER JOIN  H_Accounting.journal_entry je 
	on jeli.journal_entry_id = je.journal_entry_id 
	inner join H_Accounting.account  as a
	on a.account_id = jeli.account_id
	inner join H_Accounting.statement_section ss
	on ss.statement_section_id = a.balance_sheet_section_id
	-- FILTERING ON ID = 61 corresponding to current assets
	where ss.statement_section like '%equity%'
	and ss.is_balance_sheet_section = 1
	AND year(entry_date) =varCalendarYear;

-- Generating our financial "dashboard" for the year in the procedure 
select 
	-- Revenue in thousands of table's currency 
    format(totalIncome/1000,0) as revenue_in_000$ ,
	-- Calculating Net profit ratio is an important profitability ratio that shows the relationship between net sales and net profit 
	CASE WHEN totalIncome = 0 OR totalIncome is null then 'N/A' else concat(format(100*(totalIncome-totalExpense)/totalIncome,0), ' %') end AS profit_ratio,
    -- Calculating Gross margin is used to determine the proportion of sales still available after goods and services have been sold to pay for selling and administrative costs and generate a profit
    CASE WHEN totalIncome = 0 OR totalIncome is null then 'N/A' else  concat(format(100*(totalIncome-costGoods)/totalIncome,0), ' %') end AS gross_margin, 
	-- Calculating asset turnover measures the value of a company's sales or revenues relative to the value of its assets
	CASE WHEN totalAsset = 0 OR totalAsset is null then 'N/A' else round(totalIncome/totalAsset,2) end AS asset_turnover, 
	-- Calculating Return on asset measures a company's ability to earn a return on its equity investments. The ratio can rise due to higher net income being generated from a larger asset base funded with debt.
	CASE WHEN totalEquity = 0 OR totalEquity is null then 'N/A' else round(totalIncome/totalEquity,2) end AS return_asset, 
    --  Calculating Efficiency ratio which measures of how successful a company is at turning expenses from product development, sales, and marketing into revenue
	CASE WHEN totalIncome = 0 OR totalIncome is null then 'N/A' else concat(format(100*totalExpense/totalIncome,0), ' %')  end AS efficiency_ratio, 
      -- Calculating Monthly burn rate which is a measure of negative cash flow or cash spent per month in thousands of table's currency 
    round((totalIncome-totalExpense)/(1000*12)) AS monthly_burn_rate_in_000$,
    -- Calculating current_ratio which is liquidity ratio that measures a company's ability to pay short-term obligations or those due within one year
	CASE WHEN currentLiability = 0 OR currentLiability is null then 'N/A' else round(currentAsset/currentLiability,2) end AS current_ratio;
    
END $$
DELIMITER ;
# THE LINE ABOVES CHANGES BACK OUR DELIMETER TO OUR USUAL ;

CALL H_Accounting.trio11_zzennour2018 (2015);