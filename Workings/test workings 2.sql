USE H_Accounting;

SELECT  a.balance_sheet_section_id, ss.statement_section_code, SUM(jeli.debit), SUM(jeli.credit), SUM(jeli.debit)-SUM(jeli.credit), SUM(ABS(jeli.debit)-(jeli.credit))
FROM `account` AS a 
INNER JOIN journal_entry_line_item AS jeli ON a.account_id =jeli.account_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id OR
  ss.statement_section_id = a.balance_sheet_section_id
INNER JOIN  journal_entry AS je
on jeli.journal_entry_id = je.journal_entry_id 
WHERE a.balance_sheet_section_id > 0 AND ss.statement_section_code !=' ' AND YEAR(je.entry_date) = '2015'
GROUP BY a.balance_sheet_section_id,ss.statement_section_code;

SELECT (5473427.699999998-4794026.88)-(898058.2399999995-345709.17)-127051.75;
SELECT 2604411.1999999997+14913.69-1853985.13-579704.47-59050.88;

SELECT  a.profit_loss_section_id, ss.statement_section_code, SUM(jeli.debit), SUM(jeli.credit), SUM(jeli.debit)-SUM(jeli.credit)
FROM `account` AS a 
INNER JOIN journal_entry_line_item AS jeli ON a.account_id =jeli.account_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id OR
  ss.statement_section_id = a.balance_sheet_section_id
INNER JOIN  journal_entry AS je
on jeli.journal_entry_id = je.journal_entry_id 
WHERE a.profit_loss_section_id > 0 AND ss.statement_section_code !=' ' AND YEAR(je.entry_date) = '2015'
GROUP BY a.profit_loss_section_id,ss.statement_section_code;