[23:41] Mengdan Liu
DECLARE CURSOR c_trans IS
SELECT *
FROM new_transactions;
v_trans_no NUMBER;
v_trans_date DATE;
v_trans_desc VARCHAR2(100);
v_act_no NUMBER;
v_trans_type CHAR(1);
v_trans_amount NUMBER;
v_trans_no_count NUMBER;
e_no_trans_no EXCEPTION;
e_db_not_equal EXCEPTION;
e_invalid_act_no EXCEPTION;
e_neg_amount EXCEPTION;
e_invalid_trans_type EXCEPTION;
CURSOR c_trans2 IS
SELECT *
FROM new_transactions
WHERE transaction_no = v_trans_no;
v_account_no NUMBER;
v_account_balance NUMBER;
v_account_trans_type CHAR(1);
v_account_type_code VARCHAR2(2);
CURSOR c_history IS
select * from
transaction_history
where transaction_no = v_trans_no;
BEGIN FOR r_trans IN c_trans LOOP
BEGIN
IF v_account_balance < 0 THEN
RAISE e_neg_amount;
END IF;
IF v_trans_type <> 'C' OR v_trans_type <> 'C'THEN
RAISE e_invalid_trans_type;
END IF;
v_trans_no := r_trans.transaction_no;
v_trans_date := r_trans.transaction_date;
v_trans_desc := r_trans.description;
v_act_no := r_trans.account_no;
v_trans_type := r_trans.transaction_type;
v_trans_amount := r_trans.transaction_amount;
select COUNT(transaction_no)
INTO v_trans_no_count
from transaction_history
where transaction_no = v_trans_no;
IF v_trans_no_count = 0 THEN
IF v_trans_no = NULL THEN
RAISE e_no_trans_no;
end if;
-- insert data into history TABLE 
INSERT INTO transaction_history
VALUES (v_trans_no, v_trans_date, v_trans_desc);
-- insert data into detail TABLE
END IF;
INSERT INTO transaction_detail
VALUES (v_act_no , v_trans_no, v_trans_type, v_trans_amount); FOR r_trans2 IN c_trans2 LOOP
-- update account TABLE
SELECT account_balance
INTO v_account_balance
FROM account
WHERE account_no = v_act_no;
SELECT account_type_code
INTO v_account_type_code
FROM ACCOUNT
WHERE account_no = v_act_no;
SELECT default_trans_type
INTO v_account_trans_type
FROM account_type
WHERE account_type_code = v_account_type_code;
IF(v_trans_type = v_account_trans_type) THEN
v_account_balance := v_account_balance + v_trans_amount;
ELSE
v_account_balance := v_account_balance - v_trans_amount;
END IF; UPDATE ACCOUNT
SET account_balance = v_account_balance
WHERE account_no = v_act_no;
END LOOP;
EXCEPTION
WHEN e_no_trans_no THEN
ROLLBACK;
DBMS_OUTPUT.PUT_LINE ('Missing a transaction number');
WHEN e_db_not_equal THEN
ROLLBACK;
DBMS_OUTPUT.PUT_LINE ('Debits and credits are not equal');
WHEN e_invalid_act_no THEN
ROLLBACK;
DBMS_OUTPUT.PUT_LINE ('Invalid account number');
WHEN e_neg_amount THEN
ROLLBACK;
DBMS_OUTPUT.PUT_LINE ('Negative value given for a transaction amount');
WHEN e_invalid_trans_type THEN
ROLLBACK;
DBMS_OUTPUT.PUT_LINE ('Invalid transaction type');
WHEN OTHERS THEN
ROLLBACK;
DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
END LOOP;END;
/

[23:41] Mengdan Liu
DECLARE CURSOR c_trans IS
SELECT *
FROM new_transactions;
v_trans_no NUMBER;
v_trans_date DATE;
v_trans_desc VARCHAR2(100);
v_act_no NUMBER;
v_trans_type CHAR(1);
v_trans_amount NUMBER;
v_trans_no_count NUMBER;
e_no_trans_no EXCEPTION;
e_db_not_equal EXCEPTION;
e_invalid_act_no EXCEPTION;
e_neg_amount EXCEPTION;
e_invalid_trans_type EXCEPTION;
CURSOR c_trans2 IS
SELECT *
FROM new_transactions
WHERE transaction_no = v_trans_no;
v_account_no NUMBER;
v_account_balance NUMBER;
v_account_trans_type CHAR(1);
v_account_type_code VARCHAR2(2);
CURSOR c_history IS
select * from
transaction_history
where transaction_no = v_trans_no;
BEGIN FOR r_trans IN c_trans LOOP
BEGIN
IF v_account_balance < 0 THEN
RAISE e_neg_amount;
END IF;
IF v_trans_type <> 'C' OR v_trans_type <> 'C'THEN
RAISE e_invalid_trans_type;
END IF;
v_trans_no := r_trans.transaction_no;
v_trans_date := r_trans.transaction_date;
v_trans_desc := r_trans.description;
v_act_no := r_trans.account_no;
v_trans_type := r_trans.transaction_type;
v_trans_amount := r_trans.transaction_amount;
select COUNT(transaction_no)
INTO v_trans_no_count
from transaction_history
where transaction_no = v_trans_no;
IF v_trans_no_count = 0 THEN
IF v_trans_no = NULL THEN
RAISE e_no_trans_no;
end if;
-- insert data into history TABLE INSERT INTO transaction_history
VALUES (v_trans_no, v_trans_date, v_trans_desc);
-- insert data into detail TABLE
END IF;
INSERT INTO transaction_detail
VALUES (v_act_no , v_trans_no, v_trans_type, v_trans_amount); FOR r_trans2 IN c_trans2 LOOP
-- update account TABLE
SELECT account_balance
INTO v_account_balance
FROM account
WHERE account_no = v_act_no;
SELECT account_type_code
INTO v_account_type_code
FROM ACCOUNT
WHERE account_no = v_act_no;
SELECT default_trans_type
INTO v_account_trans_type
FROM account_type
WHERE account_type_code = v_account_type_code;
IF(v_trans_type = v_account_trans_type) THEN
v_account_balance := v_account_balance + v_trans_amount;
ELSE
v_account_balance := v_account_balance - v_trans_amount;
END IF; UPDATE ACCOUNT
SET account_balance = v_account_balance
WHERE account_no = v_act_no;
END LOOP;
EXCEPTION
WHEN e_no_trans_no THEN
ROLLBACK;
DBMS_OUTPUT.PUT_LINE ('Missing a transaction number');
WHEN e_db_not_equal THEN
ROLLBACK;
DBMS_OUTPUT.PUT_LINE ('Debits and credits are not equal');
WHEN e_invalid_act_no THEN
ROLLBACK;
DBMS_OUTPUT.PUT_LINE ('Invalid account number');
WHEN e_neg_amount THEN
ROLLBACK;
DBMS_OUTPUT.PUT_LINE ('Negative value given for a transaction amount');
WHEN e_invalid_trans_type THEN
ROLLBACK;
DBMS_OUTPUT.PUT_LINE ('Invalid transaction type');
WHEN OTHERS THEN
ROLLBACK;
DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
END LOOP;END;
/

