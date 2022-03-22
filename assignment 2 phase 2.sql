DECLARE
	CURSOR c_transactions IS
		SELECT DISTINCT transaction_no, transaction_date, description
			FROM new_transactions;
				
			v_transaction_no 	 NUMBER;
			v_transaction_date  	DATE;
			v_transaction_description 	 VARCHAR2(100);
			
	CURSOR c_transactions_2 IS
		SELECT *
			FROM new_transactions
			WHERE transaction_no = v_transaction_no;
			
	CURSOR c_transactions_3 IS
		SELECT transaction_no, SUM(transaction_amount) transaction_amount_3
				FROM new_transactions
				GROUP BY transaction_no;
			
			v_account_no 	 NUMBER;
			v_account_balance  	NUMBER;

			v_account_trans_type 	CHAR(1);
			v_account_type_code 	VARCHAR2(2);
			
			v_account_no_2 	  NUMBER;
			v_transaction_no_2  	NUMBER;
			v_transaction_date_2  	DATE;
			v_transaction_description_2  	VARCHAR2(100);
			v_transaction_type_2 	 CHAR(1);
			v_transaction_amount_2  	NUMBER;
			
			v_transaction_no_3  	NUMBER;
			v_transaction_type_3 	 CHAR(1);
			v_transaction_amount_3  	NUMBER;
			
			v_error_msg 	wkis_error_log.error_msg%TYPE;
			ex_nodatafound_1 	EXCEPTION;
			ex_invaid_1 	EXCEPTION;
			ex_invaid_2 	EXCEPTION;
			ex_not_equal 	EXCEPTION;
			
			v_debit_value 	NUMBER;
			v_credit_value 	NUMBER;
			
			k_transaction_type_credit 	CONSTANT CHAR(1) := 'C';
			k_transaction_type_debit 	CONSTANT CHAR(1) := 'D';
	
			
BEGIN

	FOR r_transactions IN c_transactions LOOP
		BEGIN

			v_transaction_no := r_transactions.transaction_no;
			IF SQL%NOTFOUND THEN
				RAISE ex_nodatafound_1;
			END IF;
			
			v_transaction_date := r_transactions.transaction_date;
			v_transaction_description := r_transactions.description;
			
			-- Debits and credits are not equal
			FOR r_transactions_3 IN c_transactions_3 LOOP
				v_transaction_amount_3 := r_transactions_3.transaction_amount_3;
				IF v_transaction_amount_3 != 0 THEN
					RAISE ex_not_equal;
				END IF;
			END LOOP;
			
				
			-- insert data into history TABLE
			INSERT INTO transaction_history
			VALUES (v_transaction_no, v_transaction_date, v_transaction_description);

				FOR r_transactions_2 IN c_transactions_2 LOOP					
					
					v_transaction_no_2 := r_transactions_2.transaction_no;
					-- Missing transaction number (NULL transaction number)
					IF SQL%NOTFOUND THEN
						RAISE ex_nodatafound_1;
					END IF;
					
					v_account_no_2 := r_transactions_2.account_no;
					-- Invalid account number
			
					-- Negative value given for a transaction amount
					IF r_transactions_2.transaction_amount < 0 THEN
						RAISE ex_invaid_1;
					ELSE
						v_transaction_amount_2 := r_transactions_2.transaction_amount;
					END IF;
									
					-- Invalid transaction type
					IF r_transactions_2.transaction_type != k_transaction_type_credit OR r_transactions_2.transaction_type != k_transaction_type_debit THEN
						RAISE ex_invaid_2;
					ELSE
						v_transaction_type_2 := r_transactions_2.transaction_type;
					END IF;
					
					
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
			
			
			--COMMIT;
			
			-- EXCEPTION
			EXCEPTION
				WHEN ex_nodatafound_1 THEN
					
					v_error_msg := SUBSTR(SQLERRM, 1, 100);
					
					INSERT INTO wkis_error_log
					(error_msg)
					VALUES(v_error_msg);
					
					--COMMIT;
					
				WHEN ex_invaid_1 THEN
					DBMS_OUTPUT.PUT_LINE('Negative Value given for a transaction amount');
				
				WHEN ex_invaid_2 THEN
					DBMS_OUTPUT.PUT_LINE('Invalid transaction type');
					
				WHEN ex_not_equal THEN
					DBMS_OUTPUT.PUT_LINE('Debits and credits are not equal');
			
			
		END;
	END LOOP;

END;
/