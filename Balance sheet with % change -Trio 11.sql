USE H_Accounting;

DELIMITER $$

-- DROP PROCEDURE IF EXISTS H_Accounting.BS_Trio11;

CREATE PROCEDURE H_Accounting.BS_Trio11(varCalendarYear SMALLINT)
BEGIN
  
	-- We receive as an argument the year for which we will generate the Balance Sheet
    -- This value is stored as a 'YEAR' type in the variable `varCalendarYear`
  
	-- Defining variables for different sections of Balance Sheet. 
    -- We are declaring 2 variables for each section to calculate the % change as compared to previous year.
  
	DECLARE varCurrentAssets1 DOUBLE DEFAULT 0;
	DECLARE varCurrentAssets2 DOUBLE DEFAULT 0;
	DECLARE varFixedAssets1 DOUBLE DEFAULT 0;
	DECLARE varFixedAssets2 DOUBLE DEFAULT 0;
	DECLARE varDeferredAssets1 DOUBLE DEFAULT 0;
	DECLARE varDeferredAssets2 DOUBLE DEFAULT 0;
	DECLARE varCurrentLiabilities1 DOUBLE DEFAULT 0;
	DECLARE varCurrentLiabilities2 DOUBLE DEFAULT 0;
	DECLARE varLongTermLiabilities1 DOUBLE DEFAULT 0;
	DECLARE varLongTermLiabilities2 DOUBLE DEFAULT 0;
	DECLARE varDeferredLiabilities1 DOUBLE DEFAULT 0;
	DECLARE varDeferredLiabilities2 DOUBLE DEFAULT 0;
    DECLARE varEquity1 DOUBLE DEFAULT 0;
	DECLARE varEquity2 DOUBLE DEFAULT 0;



	--  Calculating the value of each of the variables and inserting it into the variables declared above.
    
    -- Calculating Current Assets


	SELECT 
    IFNULL(SUM(jeli.debit), 0) -IFNULL(SUM(jeli.credit), 0) INTO varCurrentAssets1
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
    
    
    SELECT 
    IFNULL(SUM(jeli.debit), 0) -IFNULL(SUM(jeli.credit), 0) INTO varCurrentAssets2
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
    
    
        -- Calculating Fixed Assets

    
	SELECT 
    IFNULL(SUM(jeli.debit), 0)-IFNULL(SUM(jeli.credit), 0) INTO varFixedAssets1
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section_code = 'FA'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear
	;
    
    SELECT 
    IFNULL(SUM(jeli.debit), 0)-IFNULL(SUM(jeli.credit), 0) INTO varFixedAssets2
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section_code = 'FA'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear-1
	;
	
	    -- Calculating Deferred Assets


    SELECT 
    IFNULL(SUM(jeli.debit), 0) - IFNULL(SUM(jeli.credit), 0) INTO varDeferredAssets1
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section_code = 'DA'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear
	;
    
    SELECT 
    IFNULL(SUM(jeli.debit), 0) - IFNULL(SUM(jeli.credit), 0) INTO varDeferredAssets2
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section_code = 'DA'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear-1
	;
    
	-- Calculating Current Liabilities

     SELECT 
    IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0) INTO varCurrentLiabilities1
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section_code = 'CL'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear
	;
    
    SELECT 
    IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0) INTO varCurrentLiabilities2
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section_code = 'CL'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear-1
	;
    
      -- Calculating Long Term Liabilities

    SELECT 
    IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0) INTO varLongTermLiabilities1
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section_code = 'LLL'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear
	;
   
    SELECT
    IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0) INTO varLongTermLiabilities2
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section_code = 'LLL'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear-1
	;
        
        -- Calculating Deferred Liabilities

    SELECT 
    IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0)  INTO varDeferredLiabilities1
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section_code = 'DL'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear
	;
    
    
        SELECT 
    IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0)  INTO varDeferredLiabilities2
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section_code = 'DL'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear-1
	;
    
	-- Calculating Equity

	SELECT 
    IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0) INTO varEquity1
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section_code = 'EQ'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear
	;
    
    
	SELECT 
    IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0) INTO varEquity2
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section_code = 'EQ'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear-1
	;
    
       -- Dropping a temp table if it already exists

	DROP TABLE IF EXISTS H_Accounting.zzennour2018_tmp;
  
	-- Creating the table with required columns
	CREATE TABLE H_Accounting.zzennour2018_tmp (
    balance_sheet_line_number INT,
    label VARCHAR(50),
    amount VARCHAR(50),
    Percentage_change VARCHAR(50)
);
  
  
    -- Inserting header for report

  INSERT INTO H_Accounting.zzennour2018_tmp 
		   (balance_sheet_line_number, label, amount, Percentage_change)
	VALUES (1, 'BALANCE SHEET', "In '000s of USD", '');
  
	-- Inserting an empty line to create some space between the header and the line items
	INSERT INTO H_Accounting.zzennour2018_tmp
				(balance_sheet_line_number, label, amount, Percentage_change)
		VALUES 	(2, '', '','');
    
	-- Finally, inserting all the variables declared above with their values and additional sub-sections
	INSERT INTO H_Accounting.zzennour2018_tmp
			(balance_sheet_line_number, label, amount, Percentage_change)
	VALUES 	(3, 'Current Assets', format(varCurrentAssets1 / 1000, 2),''),
    (4, 'Fixed Assets', format(varFixedAssets1 / 1000, 2),''),
    (5, 'Deferred Assets', format(varDeferredAssets1 / 1000, 2),''),
    (6, 'Total Assets', format((varCurrentAssets1 + varFixedAssets1 + varDeferredAssets1) / 1000, 2),
    format(((varCurrentAssets1 + varFixedAssets1 + varDeferredAssets1)-(varCurrentAssets2 + varFixedAssets2 + varDeferredAssets2))/
    (varCurrentAssets2 + varFixedAssets2 + varDeferredAssets2),2)),
    (7, '', '',''),
    (8, 'Current Liabilities', format(varCurrentLiabilities1 / 1000, 2),
    ''),
    (9, 'Long Term Liabilities', format(varLongTermLiabilities1 / 1000, 2),
    ''),
    (10, 'Deferred Liabilities', format(varDeferredLiabilities1 / 1000, 2),''),
	(11, 'Total Liabilities', format((varCurrentLiabilities1 + varLongTermLiabilities1 + varDeferredLiabilities1) / 1000, 2),
	format(((varCurrentLiabilities1 + varLongTermLiabilities1 + varDeferredLiabilities1)-(varCurrentLiabilities2 + varLongTermLiabilities2 + varDeferredLiabilities2))/
    (varCurrentLiabilities2 + varLongTermLiabilities2 + varDeferredLiabilities2),2)),
	(12, '', '',''),
	(13, 'Equity', format(varEquity1 / 1000, 2),format((varEquity1-varEquity2)/varEquity2,2)),
	(14, '', '',''),
	(15, 'Total Liabilities and Equity', 
	format((varCurrentLiabilities1 + varLongTermLiabilities1 + varDeferredLiabilities1 + varEquity1) / 1000, 2),
	format(((varCurrentLiabilities1 + varLongTermLiabilities1 + varDeferredLiabilities1 + varEquity1)-
	(varCurrentLiabilities2 + varLongTermLiabilities2 + varDeferredLiabilities2 + varEquity2))/
	(varCurrentLiabilities2 + varLongTermLiabilities2 + varDeferredLiabilities2 + varEquity2),2)) 
    ;
    
     
END $$
DELIMITER ;
# THE LINE ABOVES CHANGES BACK OUR DELIMETER TO OUR USUAL ;

CALL H_Accounting.BS_Trio11(2015);

SELECT 
    *
FROM
    H_Accounting.zzennour2018_tmp;