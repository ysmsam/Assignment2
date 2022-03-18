DECLARE
	CURSOR c_transaction IS
		SELECT *
			FROM new_transactions;
	
	CURSOR c_account IS
		SELECT account_no, account_type_code, account_balance
			FROM account
			FOR UPDATE;
			
			v_account_no 	account.account_no%TYPE;
	
			
			v_transaction_no 	transaction_history.transaction_no%TYPE;
			v_transaction_date 	transaction_history.transaction_date%TYPE;
			v_transaction_description 	transaction_history.description%TYPE;


			
			v_transaction_type 	transaction_detail.transaction_type%TYPE;
			v_transaction_amount 	transaction_detail.transaction_amount%TYPE;
	

BEGIN

	FOR r_transactions IN c_transactions LOOP
		v_account_no := r_transactions.account_no;
		-- v_transaction_no := r_transactions.transaction_no;
		v_transaction_date := r_transactions.transaction_date;
		-- v_transaction_type := r_transactions.transaction_type;
		-- v_transaction_description := r_transactions.description;
		v_transaction_amount := r_transactions.transaction_amount;
		
		SELECT DISTINCT transaction_no, transaction_date, description
			INTO v_transaction_no, v_transaction_date, v_transaction_description
			FROM new_transactions
			WHERE v_transaction_no = r_transactions.transaction_no;
		
			
		-- insert data into history TABLE
		INSERT INTO transaction_history
		VALUES (v_transaction_no, v_transaction_date, v_transaction_description);
		
		
		-- insert data into detail TABLE
		INSERT INTO transaction_detail
		VALUES (v_account_no, v_transaction_no, v_transaction_type, v_transaction_amount);

		
		
		-- update account TABLE
		IF(v_transaction_type = account_type_code) THEN
		UPDATE ACCOUNT
			SET account_balance = account_balance + v_transaction_amount
			WHERE account_no = v_account_no;
		END IF;
		
		-- delete the row in new_transactions
		
	END LOOP;


END;
/