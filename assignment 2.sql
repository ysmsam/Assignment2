DECLARE
	CURSOR c_transactions IS
		-- SELECT DISTINCT transaction_no, transaction_date, description, account_no, transaction_type, transaction_amount
		SELECT DISTINCT transaction_no, transaction_date, description
			FROM new_transactions;
			
			
				
			v_transaction_no 	 NUMBER;
			v_transaction_date  	DATE;
			v_transaction_description 	 VARCHAR2(100);
			-- v_transaction_type  	CHAR(1);
			-- v_transaction_amount   	NUMBER;
			
	CURSOR c_transactions_2 IS
		SELECT *
			FROM new_transactions
			WHERE transaction_no = v_transaction_no;
	
	-- CURSOR c_account IS
	-- 	SELECT account_no, account_type_code, account_balance
	-- 		FROM account
	-- 		FOR UPDATE;
			
			v_account_no 	 NUMBER;
			v_account_balance  	NUMBER;
			-- v_account_type_code 	account.account_type_code%TYPE;
			
			-- v_account_trans_type 	account_type.default_trans_type%TYPE;
			v_account_trans_type 	CHAR(1);
			v_account_type_code 	VARCHAR2(2);
			
			v_account_no_2 	  NUMBER;
			v_transaction_no_2  	NUMBER;
			v_transaction_date_2  	DATE;
			v_transaction_description_2  	VARCHAR2(100);
			v_transaction_type_2 	 CHAR(1);
			v_transaction_amount_2  	NUMBER;
	
			
BEGIN

	FOR r_transactions IN c_transactions LOOP
		BEGIN
			-- v_account_no := r_transactions.account_no;
			v_transaction_no := r_transactions.transaction_no;
			v_transaction_date := r_transactions.transaction_date;
			-- v_transaction_type := r_transactions.transaction_type;
			v_transaction_description := r_transactions.description;
			-- v_transaction_amount := r_transactions.transaction_amount;
			
			-- SELECT DISTINCT transaction_no, transaction_date, description
			-- 	INTO v_transaction_no, v_transaction_date, v_transaction_description
			-- 	FROM new_transactions
			-- 	WHERE transaction_no = r_transactions.transaction_no;
			
			
				
			-- insert data into history TABLE
			INSERT INTO transaction_history
			VALUES (v_transaction_no, v_transaction_date, v_transaction_description);
			

			
			-- FOR r_account IN c_account LOOP
				
			-- 	v_account_balance := r_account.account_balance;
			-- 	SELECT default_trans_type
			-- 		INTO v_account_trans_type
			-- 		FROM account_type
			-- 		WHERE r_account.account_type_code = account_type.account_type_code;
				
				FOR r_transactions_2 IN c_transactions_2 LOOP
				
				v_account_no_2 := r_transactions_2.account_no;
				v_transaction_no_2 := r_transactions_2.transaction_no;
				-- v_transaction_date_2 := r_transactions_2.transaction_date;
				v_transaction_type_2 := r_transactions_2.transaction_type;
				-- v_transaction_description_2 := r_transactions_2.description;
				v_transaction_amount_2 := r_transactions_2.transaction_amount;
					
					-- insert data into detail TABLE
					INSERT INTO transaction_detail
					VALUES (v_account_no_2, v_transaction_no_2, v_transaction_type_2, v_transaction_amount_2);
					
					-- update account TABLE
					SELECT account_balance
						INTO v_account_balance
						FROM account
						WHERE account_no = v_account_no_2;
					
					SELECT account_type_code
						INTO v_account_type_code
						FROM ACCOUNT
						WHERE account_no = v_account_no_2;
					
					SELECT default_trans_type
						INTO v_account_trans_type
						FROM account_type
						WHERE account_type_code = v_account_type_code;
					
					IF(v_transaction_type_2 = v_account_trans_type) THEN
						v_account_balance := v_account_balance + v_transaction_amount_2;
					ELSE
						v_account_balance := v_account_balance - v_transaction_amount_2;
					END IF;

					UPDATE ACCOUNT
						SET account_balance = v_account_balance
						WHERE account_no = v_account_no_2;
				END LOOP;
				
			-- END LOOP;
			
			-- delete the row in new_transactions
			DELETE FROM new_transactions WHERE transaction_no = r_transactions.transaction_no;
			
			-- EXCEPTION
			
			
		END;
	END LOOP;

END;
/