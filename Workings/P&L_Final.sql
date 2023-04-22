USE H_Accounting;

DELIMITER $$
DROP PROCEDURE IF EXISTS H_Accounting.sp15;

CREATE PROCEDURE H_Accounting.sp15(varCalendarYear SMALLINT)
BEGIN
  
	-- We receive as an argument the year for which we will generate the Profit and Loss statement
    -- This value is stored as a 'YEAR' type in the variable `varCalendarYear`
  
	-- Defining variables for different sections of P&L
	DECLARE varTotalRevenues DOUBLE DEFAULT 0;
    DECLARE varCostofGoodsSold DOUBLE DEFAULT 0;
    DECLARE varSellingExpenses DOUBLE DEFAULT 0;
    DECLARE varOtherExpenses DOUBLE DEFAULT 0;
    DECLARE varAdminExpenses DOUBLE DEFAULT 0;
    DECLARE varTaxes DOUBLE DEFAULT 0;
    DECLARE varOtherIncome DOUBLE DEFAULT 0;
    DECLARE varNetProfit DOUBLE DEFAULT 0;
  
	--  Calculating the value of each of the variables and inserting it into the variables declared above.
    
    -- Calculating Total Revenues
	SELECT 
    IFNULL(SUM(jeli.credit), 0)
INTO varTotalRevenues FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
WHERE
    ss.statement_section_code = 'REV'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear
	;
  
  
     -- Calculating Other Income
SELECT 
    IFNULL(SUM(jeli.credit), 0)
INTO varOtherIncome FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
WHERE
    ss.statement_section_code = 'OI'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear
	;
	
    
       -- Calculating Cost of Goods Sold
    
SELECT 
    IFNULL(SUM(jeli.debit), 0)
INTO varCostofGoodsSold FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
WHERE
    ss.statement_section_code IN ('COGS' , 'RET')
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear
	;
    
    -- Calculating Selling Expenses
    
SELECT 
    IFNULL(SUM(jeli.debit), 0)
INTO varSellingExpenses FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
WHERE
    ss.statement_section_code = 'SEXP'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear
	;
    
       -- Calculating Other Expenses
    
SELECT 
    IFNULL(SUM(jeli.debit), 0)
INTO varOtherExpenses FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
WHERE
    ss.statement_section_code = 'OEXP'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear
	;
   
      -- Calculating Admin Expenses
   
SELECT 
    IFNULL(SUM(jeli.debit), 0)
INTO varAdminExpenses FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
WHERE
    ss.statement_section_code = 'GEXP'
     AND je.cancelled = 0
       AND YEAR(je.entry_date) = varCalendarYear
	;
    
       -- Calculating Taxes
    
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
    ss.statement_section_code IN ('INCTAX' , 'OTHTAX')
     AND je.cancelled = 0
       AND YEAR(je.entry_date) = varCalendarYear
	;
    
    -- Calculating Net Proft
    
	SELECT (varTotalRevenues + varOtherIncome) - (varCostofGoodsSold + varSellingExpenses + varOtherExpenses + varAdminExpenses + varTaxes) 
    INTO varNetProfit;
    
    

 
    -- Dropping a temp table if it already exists
	DROP TABLE IF EXISTS H_Accounting.rkapoor_tmp;
  
	-- Creating the table with required columns
	CREATE TABLE H_Accounting.rkapoor_tmp (
    profit_loss_line_number INT,
    label VARCHAR(50),
    amount VARCHAR(50)
);
  
  -- Inserting header for report
  INSERT INTO H_Accounting.rkapoor_tmp 
		   (profit_loss_line_number, label, amount)
	VALUES (1, 'PROFIT AND LOSS STATEMENT', "In '000s of USD");
  
	-- Inserting an empty line to create some space between the header and the line items
	INSERT INTO H_Accounting.rkapoor_tmp
				(profit_loss_line_number, label, amount)
		VALUES 	(2, '', '');
    
	-- Finally, inserting all the variables declared above with their values and additional sub-sections
	INSERT INTO H_Accounting.rkapoor_tmp
			(profit_loss_line_number, label, amount)
	VALUES 	(3, 'A. Total Revenues', format(varTotalRevenues / 1000, 2)),
    (4, 'B. Total Cost of Goods Sold ', format(varCostofGoodsSold / 1000, 2)),
     (5, 'C. Gross Profit (A-B) ', format((varTotalRevenues-varCostofGoodsSold) / 1000, 2)),
     (6, ' Expenses: ', ''),
     (7, ' Selling Expenses ', format(varSellingExpenses / 1000, 2)),
     (8, ' General Expenses ', format(varAdminExpenses / 1000, 2)),
     (9, ' Other Expenses ', format(varOtherExpenses / 1000, 2)),
     (10, 'D. Total Expenses ', format((varSellingExpenses+varAdminExpenses+varOtherExpenses) / 1000, 2)),
     (11, 'E. Other Income ', format(varOtherIncome / 1000, 2)),
     (12, 'F. Profit Before Tax (C -D + E) ', 
     format(((varTotalRevenues-varCostofGoodsSold)- (varSellingExpenses+varAdminExpenses+varOtherExpenses) + varOtherIncome) / 1000, 2)),
     (13, 'G. Taxes paid ', format(varTaxes / 1000, 2)),
     (14, 'H. Net Profit/ Loss after Tax (F-G)  ', 
     format(((varTotalRevenues-varCostofGoodsSold)- (varSellingExpenses+varAdminExpenses+varOtherExpenses) + (varOtherIncome) -(varTaxes)) / 1000, 2))
     ;
     
END $$
DELIMITER ;
# THE LINE ABOVES CHANGES BACK OUR DELIMETER TO OUR USUAL ;

CALL H_Accounting.sp15 (2016);

SELECT 
    *
FROM
    H_Accounting.rkapoor_tmp;