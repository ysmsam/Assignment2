DECLARE
	CURSOR c_transactions IS
		SELECT DISTINCT transaction_no, transaction_date, description
			FROM new_transactions;
				
			v_transaction_no 	 NUMBER;
			v_transaction_date  	DATE;
			v_transaction_description 	 VARCHAR2(100);
			
	CURSOR c_transactions_2 IS
		SELECT *
			FROM new_transactions;
			--WHERE transaction_no = v_transaction_no;
			
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
	
	v_debit_value := 0;
	v_credit_value := 0;
			
	FOR r_transactions_2 IN c_transactions_2 LOOP					
		BEGIN
			-- Missing transaction number (NULL transaction number)
			IF (r_transactions_2.transaction_no is null) THEN
				RAISE ex_nodatafound_1;
			ELSE
				v_transaction_no_2 := r_transactions_2.transaction_no;
				
				-- Invalid account number
				v_account_no_2 := r_transactions_2.account_no;
				
				-- Negative value given for a transaction amount
				IF r_transactions_2.transaction_amount < 0 THEN
					RAISE ex_invaid_1;
				ELSE
					v_transaction_amount_2 := r_transactions_2.transaction_amount;
					
					-- Invalid transaction type
					IF r_transactions_2.transaction_type <> k_transaction_type_credit OR r_transactions_2.transaction_type <> k_transaction_type_debit THEN
						RAISE ex_invaid_2;
					ELSE
						v_transaction_type_2 := r_transactions_2.transaction_type;
						--IF r_transactions_2.transaction_no_2 = v_transaction_no_2 THEN
						-- Debits and credits are not equal
						IF r_transactions_2.transaction_type = k_transaction_type_debit THEN
							SELECT SUM(transaction_amount)
								INTO v_debit_value
								FROM new_transactions
								WHERE r_transactions_2.transaction_no = v_transaction_no_2;
						ELSIF r_transactions_2.transaction_type = k_transaction_type_credit THEN 
							SELECT SUM(transaction_amount)
								INTO v_credit_value
								FROM new_transactions
								WHERE r_transactions_2.transaction_no = v_transaction_no_2;
						END IF;
						
					END IF;
					
				END IF;
								
				
			END IF;
			
			IF	v_debit_value <> v_credit_value THEN
				RAISE ex_not_equal;
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
		
			COMMIT;
			-- EXCEPTION 2
			EXCEPTION
				WHEN ex_nodatafound_1 THEN
				
					v_error_msg := SUBSTR(SQLERRM, 1, 100);
					
					INSERT INTO wkis_error_log
					(error_msg)
					VALUES(v_error_msg);
					
					COMMIT;
				
				WHEN ex_invaid_1 THEN
					DBMS_OUTPUT.PUT_LINE('Negative Value given for a transaction amount');
				
				WHEN ex_invaid_2 THEN
					DBMS_OUTPUT.PUT_LINE('Invalid transaction type');
					
				WHEN ex_not_equal THEN
					DBMS_OUTPUT.PUT_LINE('Debits and credits are not equal');
			
				--WHEN OTHERS THEN
				--	ROLLBACK;
		END;
	END LOOP;
	
	FOR r_transactions IN c_transactions LOOP
		BEGIN

		-- Missing transaction number (NULL transaction number)
		IF (r_transactions.transaction_no is null) THEN
			RAISE ex_nodatafound_1;
			--RAISE_APPLICATION_ERROR(-20010, 'transaction no is null');
		ELSE
			v_transaction_no := r_transactions.transaction_no;
			
			v_transaction_date := r_transactions.transaction_date;
			v_transaction_description := r_transactions.description;
			
			INSERT INTO transaction_history
			VALUES (v_transaction_no, v_transaction_date, v_transaction_description);
		
			-- delete the row in new_transactions
			DELETE new_transactions WHERE transaction_no = r_transactions.transaction_no;
		
		
			COMMIT;
		
		END IF;
		-- EXCEPTION 1
		EXCEPTION
			WHEN ex_nodatafound_1 THEN
				
				v_error_msg := SUBSTR(SQLERRM, 1, 100);
				
				INSERT INTO wkis_error_log
				(error_msg)
				VALUES(v_error_msg);
				
				COMMIT;
		
		END;
	END LOOP;
	
	-- EXCEPTION MAIN
	--EXCEPTION
	--	WHEN OTHERS THEN
	--		ROLLBACK;

END;
/