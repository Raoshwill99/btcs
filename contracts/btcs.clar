;; Multi-Signature Wallet with Time-locked Transactions

;; Define constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant MIN_SIGNATURES u2)
(define-constant MAX_OWNERS u5)

;; Define data variables
(define-data-var total-owners uint u0)

;; Define data maps
(define-map owners principal bool)
(define-map pending-transactions
  uint
  {
    amount: uint,
    to: principal,
    approvals: uint,
    executed: bool,
    lock-until: uint,  ;; New field for time-locking
    submitter: principal  ;; New field to track who submitted the transaction
  }
)

;; Define non-fungible token for transaction IDs
(define-non-fungible-token transaction-id uint)

;; Counter for transaction IDs
(define-data-var transaction-nonce uint u0)

;; Add owner function (unchanged)
(define-public (add-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err u100))
    (asserts! (< (var-get total-owners) MAX_OWNERS) (err u101))
    (asserts! (is-none (map-get? owners new-owner)) (err u102))
    (map-set owners new-owner true)
    (var-set total-owners (+ (var-get total-owners) u1))
    (ok true)
  )
)

;; Remove owner function (unchanged)
(define-public (remove-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err u100))
    (asserts! (> (var-get total-owners) MIN_SIGNATURES) (err u103))
    (asserts! (is-some (map-get? owners owner)) (err u104))
    (map-delete owners owner)
    (var-set total-owners (- (var-get total-owners) u1))
    (ok true)
  )
)

;; Submit transaction function (updated with time-locking)
(define-public (submit-transaction (amount uint) (to principal) (lock-until uint))
  (let
    (
      (tx-id (+ (var-get transaction-nonce) u1))
    )
    (asserts! (is-some (map-get? owners tx-sender)) (err u105))
    (asserts! (> amount u0) (err u106))
    (asserts! (>= lock-until block-height) (err u110))  ;; Ensure lock time is in the future
    (try! (nft-mint? transaction-id tx-id tx-sender))
    (map-set pending-transactions tx-id
      {
        amount: amount,
        to: to,
        approvals: u1,
        executed: false,
        lock-until: lock-until,
        submitter: tx-sender
      }
    )
    (var-set transaction-nonce tx-id)
    (ok tx-id)
  )
)

;; Approve transaction function (unchanged)
(define-public (approve-transaction (tx-id uint))
  (let
    (
      (tx (unwrap! (map-get? pending-transactions tx-id) (err u107)))
    )
    (asserts! (is-some (map-get? owners tx-sender)) (err u105))
    (asserts! (not (get executed tx)) (err u108))
    (map-set pending-transactions tx-id
      (merge tx { approvals: (+ (get approvals tx) u1) })
    )
    (ok true)
  )
)

;; Execute transaction function (updated with time-lock check)
(define-public (execute-transaction (tx-id uint))
  (let
    (
      (tx (unwrap! (map-get? pending-transactions tx-id) (err u107)))
    )
    (asserts! (is-some (map-get? owners tx-sender)) (err u105))
    (asserts! (not (get executed tx)) (err u108))
    (asserts! (>= (get approvals tx) MIN_SIGNATURES) (err u109))
    (asserts! (>= block-height (get lock-until tx)) (err u111))  ;; Check if the time-lock has expired
    (try! (stx-transfer? (get amount tx) (as-contract tx-sender) (get to tx)))
    (map-set pending-transactions tx-id
      (merge tx { executed: true })
    )
    (ok true)
  )
)

;; New function to cancel a time-locked transaction
(define-public (cancel-transaction (tx-id uint))
  (let
    (
      (tx (unwrap! (map-get? pending-transactions tx-id) (err u107)))
    )
    (asserts! (is-eq tx-sender (get submitter tx)) (err u112))  ;; Only the submitter can cancel
    (asserts! (not (get executed tx)) (err u108))
    (asserts! (< block-height (get lock-until tx)) (err u113))  ;; Can only cancel if still locked
    (map-delete pending-transactions tx-id)
    (try! (nft-burn? transaction-id tx-id tx-sender))
    (ok true)
  )
)

;; Getter for total owners (unchanged)
(define-read-only (get-total-owners)
  (ok (var-get total-owners))
)

;; Getter for transaction details (unchanged)
(define-read-only (get-transaction (tx-id uint))
  (ok (map-get? pending-transactions tx-id))
)

;; New getter for current block height
(define-read-only (get-current-block-height)
  (ok block-height)
)