
;;
;; Simple accounts model.
;;
;;---------------------------------
;;
;;  Create keysets named 'admin-keyset', 'sarah-keyset' and 'james-keyset' and
;;  add some keys to them for loading this contract.
;;
;;  Make sure the message is signed with those added keys as well.
;;
;;---------------------------------

;; --------------------------------------
;;        Step 1: Set Up Module
;; --------------------------------------

;; Step 1 code goes here

;define keyset to guard module
(define-keyset 'admin-keyset (read-keyset "admin-keyset"))

;define smart-contract code
(module payments 'admin-keyset

;; --------------------------------------
;;        Step 2: Schemas and Tables
;; --------------------------------------

;; Step 2 code goes here
  (defschema payments
    balance:decimal
    keyset:keyset)

  (deftable payments-table:{payments})

;; --------------------------------------
;;    Step 3: FUNCTION: Create Account
;; --------------------------------------

;; Step 3 code goes here
  (defun create-account (id initial-balance keyset)
    "Create a new account for ID with INITIAL-BALANCE funds, must be administrator."
    (enforce-keyset 'admin-keyset)
    (enforce (>= initial-balance 0.0) "Initial balances must be >= 0.")
    (insert payments-table id
            { "balance": initial-balance,
              "keyset": keyset }))

;; --------------------------------------
;;       Step 4: FUNCTION: Get Balance
;; --------------------------------------

;; Step 4 code goes here
  (defun get-balance (id)
    "Only users or admin can read balance."
    (with-read payments-table id
      { "balance":= balance, "keyset":= keyset }
      (enforce-one "Access denied"
        [(enforce-keyset keyset)
         (enforce-keyset 'admin-keyset)])
      balance))

;; --------------------------------------
;;        Step 5: FUNCTION: Pay
;; --------------------------------------

;; Step 5 code goes here
  (defun pay (from to amount)
    (with-read payments-table from { "balance":= from-bal, "keyset":= keyset }
      (enforce-keyset keyset)
      (with-read payments-table to { "balance":= to-bal }
        (enforce (> amount 0.0) "Negative Transaction Amount")
        (enforce (>= from-bal amount) "Insufficient Funds")
        (update payments-table from
                { "balance": (- from-bal amount) })
        (update payments-table to
                { "balance": (+ to-bal amount) })
        (format "{} paid {} {}" [from to amount]))))

)

;; --------------------------------------
;;      Step 6: Accounts
;; --------------------------------------

;; Step 6 code goes here

;define table
(create-table payments-table)

;create accounts
(create-account "Sarah" 100.25 (read-keyset "sarah-keyset"))
(create-account "James" 250.0 (read-keyset "james-keyset"))

;; --------------------------------------
;;      Step 7: Transfer
;; --------------------------------------

;; Step 7 code goes here

;; do payment, simluating SARAH keyset.
(pay "Sarah" "James" 25.0)
(format "Sarah's balance is {}" [(get-balance "Sarah")])

;; read James' balance as JAMES
(format "James's balance is {}" [(get-balance "James")])
