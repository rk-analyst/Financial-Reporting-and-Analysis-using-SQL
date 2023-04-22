USE H_Accounting;

DELIMITER $$

DROP PROCEDURE IF EXISTS H_Accounting.sp21;

CREATE PROCEDURE H_Accounting.sp21(varCalendarYear SMALLINT)
BEGIN
  
	-- We receive as an argument the year for which we will generate the Balance Sheet
    -- This value is stored as a 'YEAR' type in the variable `varCalendarYear`
  
	-- Defining variables for different sections of Balance Sheet
  
	DECLARE varCurrentAssets DOUBLE DEFAULT 0;
	DECLARE varFixedAssets DOUBLE DEFAULT 0;
	DECLARE varDeferredAssets DOUBLE DEFAULT 0;
	DECLARE varCurrentLiabilities DOUBLE DEFAULT 0;
	DECLARE varLongTermLiabilities DOUBLE DEFAULT 0;
	DECLARE varDeferredLiabilities DOUBLE DEFAULT 0;
	DECLARE varEquity DOUBLE DEFAULT 0;


	--  Calculating the value of each of the variables and inserting it into the variables declared above.
    
    -- Calculating Current Assets


	SELECT 
    IFNULL(SUM(jeli.debit), 0) -IFNULL(SUM(jeli.credit), 0) INTO varCurrentAssets
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
    
    
        -- Calculating Fixed Assets

    
	SELECT 
    IFNULL(SUM(jeli.debit), 0)-IFNULL(SUM(jeli.credit), 0) INTO varFixedAssets
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
    
	
	    -- Calculating Deferred Assets


    SELECT 
    IFNULL(SUM(jeli.debit), 0) - IFNULL(SUM(jeli.credit), 0) INTO varDeferredAssets
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
    
	-- Calculating Current Liabilities

     SELECT 
    IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0) INTO varCurrentLiabilities
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
    
      -- Calculating Long Term Liabilities

    SELECT 
    IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0) INTO varLongTermLiabilities
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
    
        
        -- Calculating Deferred Liabilities

    SELECT 
    IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0)  INTO varDeferredLiabilities
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
    
	-- Calculating Equity

	SELECT 
    IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0) INTO varEquity
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
    
       -- Dropping a temp table if it already exists

	DROP TABLE IF EXISTS H_Accounting.rkapoor_tmp;
  
	-- Creating the table with required columns
	CREATE TABLE H_Accounting.rkapoor_tmp (
    balance_sheet_line_number INT,
    label VARCHAR(50),
    amount VARCHAR(50)
);
  
  
    -- Inserting header for report

  INSERT INTO H_Accounting.rkapoor_tmp 
		   (balance_sheet_line_number, label, amount)
	VALUES (1, 'BALANCE SHEET', "In '000s of USD");
  
	-- Inserting an empty line to create some space between the header and the line items
	INSERT INTO H_Accounting.rkapoor_tmp
				(balance_sheet_line_number, label, amount)
		VALUES 	(2, '', '');
    
	-- Finally, inserting all the variables declared above with their values and additional sub-sections
	INSERT INTO H_Accounting.rkapoor_tmp
			(balance_sheet_line_number, label, amount)
	VALUES 	(3, 'Current Assets', format(varCurrentAssets / 1000, 2)),
    (4, 'Fixed Assets', format(varFixedAssets / 1000, 2)),
    (5, 'Deferred Assets', format(varDeferredAssets / 1000, 2)),
    (5, 'Total Assets', format((varCurrentAssets + varFixedAssets + varDeferredAssets) / 1000, 2)),
    (6, '', ''),
    (7, 'Current Liabilities', format(varCurrentLiabilities / 1000, 2)),
    (8, 'Long Term Liabilities', format(varLongTermLiabilities / 1000, 2)),
    (9, 'Deferred Liabilities', format(varDeferredLiabilities / 1000, 2)),
    (10, 'Total Liabilities', format((varCurrentLiabilities + varLongTermLiabilities + varDeferredLiabilities) / 1000, 2)),
    (11, '', ''),
	(12, 'Equity', format(varEquity / 1000, 2)),
	(13, '', ''),
	(14, 'Total Liabilities and Equity', format((varCurrentLiabilities + varLongTermLiabilities + varDeferredLiabilities + varEquity) / 1000, 2))
    ;
     
END $$
DELIMITER ;
# THE LINE ABOVES CHANGES BACK OUR DELIMETER TO OUR USUAL ;

CALL H_Accounting.sp21 (2018);

SELECT 
    *
FROM
    H_Accounting.rkapoor_tmp;