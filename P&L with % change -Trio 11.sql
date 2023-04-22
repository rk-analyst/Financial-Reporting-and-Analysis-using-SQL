USE H_Accounting;

DELIMITER $$
-- DROP PROCEDURE IF EXISTS H_Accounting.P_L_Trio11;

CREATE PROCEDURE H_Accounting.P_L_Trio11(varCalendarYear SMALLINT)
BEGIN
  
	-- We receive as an argument the year for which we will generate the Profit and Loss statement
    -- This value is stored as a 'YEAR' type in the variable `varCalendarYear`
  
	-- Defining variables for different sections of Balance Sheet. 
	-- We are declaring 2 variables for each section to calculate the % change as compared to previous year.


  	DECLARE varTotalRevenues1 DOUBLE DEFAULT 0;
	DECLARE varTotalRevenues2 DOUBLE DEFAULT 0;
    DECLARE varCostofGoodsSold1 DOUBLE DEFAULT 0;
	DECLARE varCostofGoodsSold2 DOUBLE DEFAULT 0;
    DECLARE varSellingExpenses1 DOUBLE DEFAULT 0;
	DECLARE varSellingExpenses2 DOUBLE DEFAULT 0;
    DECLARE varOtherExpenses1 DOUBLE DEFAULT 0;
    DECLARE varOtherExpenses2 DOUBLE DEFAULT 0;    
    DECLARE varAdminExpenses1 DOUBLE DEFAULT 0;
	DECLARE varAdminExpenses2 DOUBLE DEFAULT 0;
    DECLARE varTaxes1 DOUBLE DEFAULT 0;
	DECLARE varTaxes2 DOUBLE DEFAULT 0;
    DECLARE varOtherIncome1 DOUBLE DEFAULT 0;
	DECLARE varOtherIncome2 DOUBLE DEFAULT 0;
    DECLARE varNetProfit1 DOUBLE DEFAULT 0;
	DECLARE varNetProfit2 DOUBLE DEFAULT 0;

	--  Calculating the value of each of the variables and inserting it into the variables declared above.
    
    -- Calculating Total Revenues
	SELECT 
    IFNULL(SUM(jeli.credit), 0)
INTO varTotalRevenues1 FROM
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
  
  SELECT 
    IFNULL(SUM(jeli.credit), 0)
INTO varTotalRevenues2 FROM
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
        AND YEAR(je.entry_date) = varCalendarYear-1
	;
  
     -- Calculating Other Income
SELECT 
    IFNULL(SUM(jeli.credit), 0)
INTO varOtherIncome1 FROM
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
	
    SELECT 
    IFNULL(SUM(jeli.credit), 0)
INTO varOtherIncome2 FROM
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
        AND YEAR(je.entry_date) = varCalendarYear-1
	;
    
       -- Calculating Cost of Goods Sold
    
SELECT 
    IFNULL(SUM(jeli.debit), 0)
INTO varCostofGoodsSold1 FROM
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
    
    SELECT 
    IFNULL(SUM(jeli.debit), 0)
INTO varCostofGoodsSold2 FROM
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
        AND YEAR(je.entry_date) = varCalendarYear-1
	;

    
    -- Calculating Selling Expenses
    
SELECT 
    IFNULL(SUM(jeli.debit), 0)
INTO varSellingExpenses1 FROM
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
    
    SELECT 
    IFNULL(SUM(jeli.debit), 0)
INTO varSellingExpenses2 FROM
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
        AND YEAR(je.entry_date) = varCalendarYear-1
	;
    
       -- Calculating Other Expenses
    
SELECT 
    IFNULL(SUM(jeli.debit), 0)
INTO varOtherExpenses1 FROM
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
   
   SELECT 
    IFNULL(SUM(jeli.debit), 0)
INTO varOtherExpenses2 FROM
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
        AND YEAR(je.entry_date) = varCalendarYear-2
	;
   
      -- Calculating Admin Expenses
   
SELECT 
    IFNULL(SUM(jeli.debit), 0)
INTO varAdminExpenses1 FROM
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
    
     SELECT 
    IFNULL(SUM(jeli.debit), 0)
INTO varAdminExpenses2 FROM
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
       AND YEAR(je.entry_date) = varCalendarYear-1
	;
     
     -- Calculating Taxes
    
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
    ss.statement_section_code IN ('INCTAX' , 'OTHTAX')
     AND je.cancelled = 0
       AND YEAR(je.entry_date) = varCalendarYear
	;
    
    SELECT 
    IFNULL(SUM(jeli.debit), 0)
INTO varTaxes2 FROM
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
       AND YEAR(je.entry_date) = varCalendarYear-1
	;
    
    -- Calculating Net Proft
    
	SELECT (varTotalRevenues1 + varOtherIncome1) - (varCostofGoodsSold1 + varSellingExpenses1 + varOtherExpenses1 + varAdminExpenses1 + varTaxes1) 
    INTO varNetProfit1;
    
    
	SELECT (varTotalRevenues2 + varOtherIncome2) - (varCostofGoodsSold2 + varSellingExpenses2 + varOtherExpenses2 + varAdminExpenses2 + varTaxes2) 
    INTO varNetProfit2;

 

    -- Dropping a temp table if it already exists
	DROP TABLE IF EXISTS  H_Accounting.zzennour2018_tmp;
  
	-- Creating the table with required columns
	CREATE TABLE  H_Accounting.zzennour2018_tmp (
    profit_loss_line_number INT,
    label VARCHAR(50),
    amount VARCHAR(50),
    Percentage_change VARCHAR(50)
);
  
  -- Inserting header for report
  INSERT INTO  H_Accounting.zzennour2018_tmp 
		   (profit_loss_line_number, label, amount, Percentage_change)
	VALUES (1, 'PROFIT AND LOSS STATEMENT', "In '000s of USD", '');
  
	-- Inserting an empty line to create some space between the header and the line items
	INSERT INTO  H_Accounting.zzennour2018_tmp
		   (profit_loss_line_number, label, amount, Percentage_change)
		VALUES 	(2, '', '', '');
    
	-- Finally, inserting all the variables declared above with their values and additional sub-sections
	INSERT INTO  H_Accounting.zzennour2018_tmp
		   (profit_loss_line_number, label, amount, Percentage_change)
	VALUES 	(3, 'A. Total Revenues', format(varTotalRevenues1 / 1000, 2),format(if(varTotalRevenues2=0, 100.00, (varTotalRevenues1-varTotalRevenues2)/varTotalRevenues2),2) ),
    (4, 'B. Total Cost of Goods Sold ', format(varCostofGoodsSold1 / 1000, 2), ''),
     (5, 'C. Gross Profit (A-B) ', format((varTotalRevenues1-varCostofGoodsSold1) / 1000, 2), 
     format(
		if (varTotalRevenues2-varCostofGoodsSold2=0, 100.00, 
			 ((varTotalRevenues1-varCostofGoodsSold1)-(varTotalRevenues2-varCostofGoodsSold2))/
			 (varTotalRevenues2-varCostofGoodsSold2)
		 ), 
     2)),
     (6, ' Expenses: ', '', ''),
     (7, ' Selling Expenses ', format(varSellingExpenses1 / 1000, 2), ''),
     (8, ' General Expenses ', format(varAdminExpenses1 / 1000, 2), ''),
     (9, ' Other Expenses ', format(varOtherExpenses1 / 1000, 2), ''),
     (10, 'D. Total Expenses ', format((varSellingExpenses1+varAdminExpenses1+varOtherExpenses1) / 1000, 2),
     format(
		 if(varSellingExpenses2+varAdminExpenses2+varOtherExpenses2=0, 100.00, (
			(varSellingExpenses1+varAdminExpenses1+varOtherExpenses1)-(varSellingExpenses2+varAdminExpenses2+varOtherExpenses2)
		 )
		/(varSellingExpenses2+varAdminExpenses2+varOtherExpenses2))
	 , 2)),
     (11, 'E. Other Income ', format(varOtherIncome1 / 1000, 2), ''),
     (12, 'F. Profit Before Tax (C -D + E) ', 
     format(((varTotalRevenues1-varCostofGoodsSold1)- (varSellingExpenses1+varAdminExpenses1+varOtherExpenses1) + varOtherIncome1) / 1000, 2), ''),
     (13, 'G. Taxes paid ', format(varTaxes1 / 1000, 2), ''),
     (14, 'H. Net Profit/ Loss after Tax (F-G)  ', 
     format(((varTotalRevenues1-varCostofGoodsSold1)- (varSellingExpenses1+varAdminExpenses1+varOtherExpenses1) + (varOtherIncome1) -(varTaxes1)) / 1000, 2),
     format(
     
		if (varTotalRevenues2-varCostofGoodsSold2- varSellingExpenses2+varAdminExpenses2+varOtherExpenses2 + varOtherIncome2 -varTaxes2=0, 100.00, 
			(
				((varTotalRevenues1-varCostofGoodsSold1)- (varSellingExpenses1+varAdminExpenses1+varOtherExpenses1) + (varOtherIncome1) -(varTaxes1)) -
				((varTotalRevenues2-varCostofGoodsSold2)- (varSellingExpenses2+varAdminExpenses2+varOtherExpenses2) + (varOtherIncome2) -(varTaxes2))
			) /
			
			(
				(varTotalRevenues2-varCostofGoodsSold2)- (varSellingExpenses2+varAdminExpenses2+varOtherExpenses2) + (varOtherIncome2) -(varTaxes2)
			)),
		2)
	 )
     ;
     
END $$
DELIMITER ;
# THE LINE ABOVES CHANGES BACK OUR DELIMETER TO OUR USUAL ;

CALL H_Accounting.P_L_Trio11 (2015);

SELECT 
    *
FROM
    H_Accounting.zzennour2018_tmp;