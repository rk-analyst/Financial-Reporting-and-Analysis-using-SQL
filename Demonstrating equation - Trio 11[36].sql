DELIMITER $$

 DROP PROCEDURE IF EXISTS H_Accounting.Trio11_Demo;

CREATE PROCEDURE H_Accounting.Trio11_Demo(varCalendarYear SMALLINT)
BEGIN
 
 	-- We receive as an argument the year for which we will generate equation E+L-A made of three variables : the total liabilites, equities and assets 
    -- This value is stored as a 'YEAR' type in the variable `varCalendarYear`
  
    
    DECLARE totalAssets DOUBLE DEFAULT 0;
	DECLARE totalLiabilities DOUBLE DEFAULT 0;
    DECLARE totalEquities DOUBLE DEFAULT 0;
	
    SELECT 
    round(IFNULL(SUM(jeli.debit), 0) -IFNULL(SUM(jeli.credit), 0),0) INTO totalAssets
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section like '%asset%'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear
	;
    
    SELECT 
    round(IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0),0) INTO totalLiabilities
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section like '%liabilit%'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear
	;
    
    SELECT 
    round(IFNULL(SUM(jeli.credit), 0) - IFNULL(SUM(jeli.debit), 0),0) INTO totalEquities
    FROM
    H_Accounting.journal_entry_line_item AS jeli
        INNER JOIN
    H_Accounting.`account` AS ac ON ac.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
        INNER JOIN
    H_Accounting.statement_section AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE
    ss.statement_section like '%equit%'
    AND je.cancelled = 0
        AND YEAR(je.entry_date) = varCalendarYear
	;
    
    select totalEquities + totalLiabilities - totalAssets as equation_in_one_side;
    
    END $$
DELIMITER ;
# THE LINE ABOVES CHANGES BACK OUR DELIMETER TO OUR USUAL ;

CALL H_Accounting.Trio11_Demo (2002);
    
-- We should make sure it returns 0 so that we can demonstrate the equation for each year
-- It is actually true for all years except the ones with missing data like 2020 and 2026
    
    