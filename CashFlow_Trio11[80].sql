USE H_Accounting;

DELIMITER $$

DROP PROCEDURE IF EXISTS H_Accounting.Trio11_CF;

CREATE PROCEDURE H_Accounting.Trio11_CF(varCalendarYear SMALLINT)
BEGIN
  
	-- We receive as an argument the year for which we will generate the Balance Sheet
    -- This value is stored as a 'YEAR' type in the variable `varCalendarYear`
  
	-- Defining variables for different sections of Balance Sheet. 
    -- We are declaring 2 variables for each section to calculate the % change as compared to previous year.
  
	DECLARE varcurrAssets1 DOUBLE DEFAULT 0; -- from the previous year
	DECLARE varcurrAssets DOUBLE DEFAULT 0; -- from the current year
	DECLARE varcurrLiabilities1 DOUBLE DEFAULT 0;
	DECLARE varcurrLiabilities DOUBLE DEFAULT 0;
	DECLARE varfixLiabilities1 DOUBLE DEFAULT 0;
	DECLARE varfixLiabilities DOUBLE DEFAULT 0;
    DECLARE varTaxes1 DOUBLE DEFAULT 0;
	DECLARE varTaxes DOUBLE DEFAULT 0;
    DECLARE varCash1 DOUBLE DEFAULT 0;
    DECLARE varCash DOUBLE DEFAULT 0;
    DECLARE gain_loss_exchange DOUBLE DEFAULT 0;
    DECLARE gain_loss_exchange1 DOUBLE DEFAULT 0;
    DECLARE varTotalExpenses1 DOUBLE DEFAULT 0;   
    DECLARE varTotalIncome1 DOUBLE DEFAULT 0;

    -- Calculating Total Income
	SELECT 
    IFNULL(SUM(jeli.credit), 0)
      INTO varTotalIncome1 FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
WHERE
    ss.statement_section_code in ( 'REV', 'OI')
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear-1
	;
    
        -- Calculating Total expenses and taxes 
SELECT 
    IFNULL(SUM(jeli.debit), 0)
INTO varTotalExpenses1 FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
WHERE
    ss.statement_section_code IN ( 'OEXP', 'COGS', 'SEXP')
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear-1
	;
	--  Calculating the value of each of the variables and inserting it into the variables declared above.
    -- Calculating Cash Balance from the previous year
     SELECT 
      IFNULL(SUM(case when debit_is_positive =0 then jeli.debit end ), 0) - IFNULL(SUM(case when debit_is_positive =1 then jeli.credit end), 0) 
      into varCash1
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
    inner join H_Accounting.journal_type AS jt on jt.journal_type_id= je.journal_type_id
    WHERE je.cancelled = 0 and jt.journal_type ='CASH'
	AND YEAR(je.entry_date) = varCalendarYear-1;
    
    -- Calculating All accounts receivable = current assets


	SELECT 
    IFNULL(SUM(jeli.debit), 0) -IFNULL(SUM(jeli.credit), 0) INTO varcurrAssets1
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section_code = 'CA'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear-1
	;
    
    
    SELECT 
    IFNULL(SUM(jeli.debit), 0) -IFNULL(SUM(jeli.credit), 0) INTO varcurrAssets
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
         ss.statement_section_code = 'CA'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear
	;
    
    -- Calculating Fixed Liabilities for equipment 
     SELECT 
    IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0) INTO varfixLiabilities
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section_code ='FL' 
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear -1 
	;
     SELECT 
    IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0) INTO varfixLiabilities1
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section_code ='FL' 
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear -1 
	;
    	
	-- Calculating current Liabilities for all accounts payable

     SELECT 
    IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0) INTO varcurrLiabilities1
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section_code ='CL' 
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear -1 
	;
    
    SELECT 
    IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0) INTO varcurrLiabilities
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
      ss.statement_section_code ='CL' 
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear
	;
    
    -- Calculating Income Taxes
   
   SELECT 
    IFNULL(SUM(jeli.debit), 0)
INTO varTaxes1 FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
WHERE
   ac.account LIKE '%tax%'
     AND je.cancelled = 0
       AND YEAR(je.entry_date) = varCalendarYear -1
	;
    
    SELECT 
    IFNULL(SUM(jeli.debit), 0)
INTO varTaxes FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
WHERE
   ac.account LIKE '%tax%'
     AND je.cancelled = 0
       AND YEAR(je.entry_date) = varCalendarYear 
	;
    -- Calculating Cash Balance from the CURRENT YEAR
     SELECT 
      IFNULL(SUM(case when debit_is_positive =0 then jeli.debit end ), 0) - IFNULL(SUM(case when debit_is_positive =1 then jeli.credit end), 0) 
      into varCash
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
    inner join H_Accounting.journal_type AS jt on jt.journal_type_id= je.journal_type_id
    WHERE je.cancelled = 0 and jt.journal_type ='CASH'
	AND YEAR(je.entry_date) = varCalendarYear;
    
    -- CALCULATING GAIN OR LOSS ON CURRENCY EXCHANGE 
     SELECT 
	IFNULL(SUM(case when debit_is_positive =1 then jeli.credit end ), 0) - IFNULL(SUM(case when debit_is_positive =0 then jeli.debit end), 0) 
    into gain_loss_exchange1
    -- , 
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    inner join H_Accounting.journal_type AS jt on jt.journal_type_id= je.journal_type_id
    WHERE je.cancelled = 0 
    and ac.account_id in (585, 589) 
    AND YEAR(je.entry_date) = varCalendarYear-1;
	
    SELECT 
	IFNULL(SUM(case when debit_is_positive =1 then jeli.credit end ), 0) - IFNULL(SUM(case when debit_is_positive =0 then jeli.debit end), 0) 
    into gain_loss_exchange
    -- , 
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    inner join H_Accounting.journal_type AS jt on jt.journal_type_id= je.journal_type_id
    WHERE je.cancelled = 0 
    and ac.account_id in (585, 589) 
    AND YEAR(je.entry_date) = varCalendarYear;

       -- Dropping a temp table if it already exists

	DROP TABLE IF EXISTS H_Accounting.zzennour2018_tmp;
  
	-- Creating the table with required columns
	CREATE TABLE H_Accounting.zzennour2018_tmp (
    cash_flow_label VARCHAR(50),
    amount_in_000$ VARCHAR(50)
);
  

    
	-- Finally, inserting all the variables declared above with their values and additional sub-sections
	INSERT INTO H_Accounting.zzennour2018_tmp
			(cash_flow_label, amount_in_000$)
	VALUES
	-- 
    ('Cash Balance from previous year', format(varCash1/1000, 2)),
    ('Cash flow from Operations', ''),
    ('Net Earnings', format((varTotalIncome1-varTotalExpenses1)/1000,2)),
    ('Depreciation',''),
    ('Increase in Amonuts Receivable', format((varcurrAssets1-varcurrAssets) / 1000, 2)),
    ('Increase in Amounts Payable', format((varcurrLiabilities1 - varcurrLiabilities) / 1000, 2)),
    ('Increase in Inventory', ''),
    ('Net Cash From Operations', format((varcurrAssets-varcurrAssets1+varcurrLiabilities1- varcurrLiabilities+varCash1)/ 1000, 2)),
    ('Cash Flow From Investing', ''),
    ('Purchase of equipment', format(varfixLiabilities1 -varfixLiabilities / 1000, 2)),
	('Cash Flow from financing', ''),
	('Notes Payable', ''),
	('Gain or Loss due to currency exchange', format((gain_loss_exchange1-gain_loss_exchange)/ 1000, 2)),
    ('Income Taxes', format((varTaxes1-varTaxes)/1000,2)),
	-- ('Cash Flow for the current year double check', format(varCash/1000, 2)),
    ('Cash Balance for the current year', format((varTotalIncome1-varTotalExpenses1+varTaxes1-varTaxes-varcurrAssets1+varcurrAssets+varcurrLiabilities1- varcurrLiabilities+gain_loss_exchange1-gain_loss_exchange) / 1000, 2))
    ;
    
     
END $$
DELIMITER ;
# THE LINE ABOVES CHANGES BACK OUR DELIMETER TO OUR USUAL ;
CALL H_Accounting.Trio11_CF(2016);

 SELECT    * FROM H_Accounting.zzennour2018_tmp;