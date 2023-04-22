SELECT  a.account_id, `account`, SUM(jeli.debit), SUM(jeli.credit)
FROM `account` AS a 
INNER JOIN journal_entry_line_item AS jeli ON a.account_id =jeli.account_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id OR
  ss.statement_section_id = a.balance_sheet_section_id
INNER JOIN  journal_entry AS je
on jeli.journal_entry_id = je.journal_entry_id 
WHERE a.balance_sheet_section_id > 0 AND ss.statement_section_code ='EQ' AND YEAR(je.entry_date) = '2016'
GROUP BY a.account_id, `account`;

SELECT  a.profit_loss_section_id, ss.statement_section, round(sum(case when  ss.debit_is_positive = 0 then (jeli.credit) 
when ss.debit_is_positive = 1 then (jeli.debit) end),0) as total
FROM `account` AS a 
INNER JOIN journal_entry_line_item AS jeli ON a.account_id =jeli.account_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id OR
  ss.statement_section_id = a.balance_sheet_section_id
INNER JOIN  journal_entry AS je
on jeli.journal_entry_id = je.journal_entry_id 
WHERE a.profit_loss_section_id > 0 AND ss.statement_section_code !=' ' AND YEAR(je.entry_date) = '2016'
GROUP BY a.profit_loss_section_id,ss.statement_section;