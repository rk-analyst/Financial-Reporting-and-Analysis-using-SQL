-- Balance sheet

SELECT 
    a.balance_sheet_section_id,
    ss.statement_section,
    IF(ROUND(ABS(SUM(jeli.credit) - SUM(jeli.debit)),
                0) != 0,
        FORMAT(ROUND(ABS(SUM(jeli.credit) - SUM(jeli.debit)),
                0),0),
        FORMAT(IF(ROUND(SUM(jeli.credit), 0) IS NULL,
            ROUND(SUM(jeli.debit), 0),
            ROUND(SUM(jeli.credit), 0)),0)) AS total
FROM
    `account` AS a
        INNER JOIN
    journal_entry_line_item AS jeli ON a.account_id = jeli.account_id
        INNER JOIN
    statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
        OR ss.statement_section_id = a.balance_sheet_section_id
        INNER JOIN
    journal_entry AS je ON jeli.journal_entry_id = je.journal_entry_id
WHERE
    a.balance_sheet_section_id > 0
        AND ss.statement_section_code != ' '
        AND YEAR(je.entry_date) = '2015'
GROUP BY a.balance_sheet_section_id , ss.statement_section;


-- Profit & Loss
SELECT 
    a.profit_loss_section_id,
    ss.statement_section,
    IF(ROUND(ABS(SUM(jeli.credit) - SUM(jeli.debit)),
                0) != 0,
        FORMAT(ROUND(ABS(SUM(jeli.credit) - SUM(jeli.debit)),
                0),0),
        FORMAT(IF(ROUND(SUM(jeli.credit), 0) IS NULL,
            ROUND(SUM(jeli.debit), 0),
            ROUND(SUM(jeli.credit), 0)),0)) AS total
FROM
    `account` AS a
        INNER JOIN
    journal_entry_line_item AS jeli ON a.account_id = jeli.account_id
        INNER JOIN
    statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
        OR ss.statement_section_id = a.balance_sheet_section_id
        INNER JOIN
    journal_entry AS je ON jeli.journal_entry_id = je.journal_entry_id
WHERE
    a.profit_loss_section_id > 0
        AND ss.statement_section_code != ' '
        AND YEAR(je.entry_date) = '2015'
GROUP BY a.profit_loss_section_id , ss.statement_section;


