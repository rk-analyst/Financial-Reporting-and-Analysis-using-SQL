USE H_Accounting;


DELIMITER $$

CREATE PROCEDURE H_Accounting.sp6_rkapoor(varCalendarYear SMALLINT)
BEGIN
	DECLARE varTotalIncome DOUBLE DEFAULT 0;
	DECLARE varTotalExpense DOUBLE DEFAULT 0;
  
  SELECT 
    SUM(jeli.credit)
INTO varTotalIncome FROM
    statement_section AS ss
        INNER JOIN
    `account` AS a ON a.profit_loss_section_id = ss.statement_section_id
        INNER JOIN
    journal_entry_line_item AS jeli ON a.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
WHERE
    ss.statement_section_code IN ('REV' , 'OI')
        AND YEAR(je.entry_date) = varCalendarYear;
 
 
SELECT 
    SUM(jeli.debit)
INTO varTotalExpense FROM
    statement_section AS ss
        INNER JOIN
    `account` AS a ON a.profit_loss_section_id = ss.statement_section_id
        INNER JOIN
    journal_entry_line_item AS jeli ON a.account_id = jeli.account_id
        INNER JOIN
    H_Accounting.journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
WHERE
    ss.statement_section_code IN ('RET' , 'GEXP',
        'SEXP',
        'OEXP',
        'INCTAX',
        'OTHTAX',
        'COGS')
        AND YEAR(je.entry_date) = varCalendarYear;

	DROP TABLE IF EXISTS H_Accounting.rkapoor_tmp;
  
	-- Now we are certain that the table does not exist, we create with the columns that we need
	CREATE TABLE H_Accounting.rkapoor_tmp
		(profit_loss_line_number INT, 
		 label VARCHAR(50), 
	     amount VARCHAR(50)
		);
  
  -- Now we insert the a header for the report
  INSERT INTO H_Accounting.rkapoor_tmp 
		   (profit_loss_line_number, label, amount)
	VALUES (1, 'PROFIT AND LOSS STATEMENT', "In USD");
  
	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO H_Accounting.rkapoor_tmp
				(profit_loss_line_number, label, amount)
		VALUES 	(2, '', '');
    
	-- Finally we insert the Total Revenues with its value
	INSERT INTO H_Accounting.rkapoor_tmp
			(profit_loss_line_number, label, amount)
	VALUES 	(3, 'Net Profit/ Loss', format(varTotalIncome-varTotalExpense, 2));
    
END $$
DELIMITER ;
# THE LINE ABOVES CHANGES BACK OUR DELIMETER TO OUR USUAL ;

CALL H_Accounting.sp6_rkapoor (2015);

SELECT 
    *
FROM
    H_Accounting.rkapoor_tmp;