;; Multi-Signature Wallet - Initial Commit

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
    executed: bool
  }
)

;; Define non-fungible token for transaction IDs
(define-non-fungible-token transaction-id uint)

;; Counter for transaction IDs
(define-data-var transaction-nonce uint u0)

;; Add owner function
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

;; Remove owner function
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

;; Submit transaction function
(define-public (submit-transaction (amount uint) (to principal))
  (let
    (
      (tx-id (+ (var-get transaction-nonce) u1))
    )
    (asserts! (is-some (map-get? owners tx-sender)) (err u105))
    (asserts! (> amount u0) (err u106))
    (try! (nft-mint? transaction-id tx-id tx-sender))
    (map-set pending-transactions tx-id
      {
        amount: amount,
        to: to,
        approvals: u1,
        executed: false
      }
    )
    (var-set transaction-nonce tx-id)
    (ok tx-id)
  )
)

;; Approve transaction function
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

;; Execute transaction function
(define-public (execute-transaction (tx-id uint))
  (let
    (
      (tx (unwrap! (map-get? pending-transactions tx-id) (err u107)))
    )
    (asserts! (is-some (map-get? owners tx-sender)) (err u105))
    (asserts! (not (get executed tx)) (err u108))
    (asserts! (>= (get approvals tx) MIN_SIGNATURES) (err u109))
    (try! (stx-transfer? (get amount tx) (as-contract tx-sender) (get to tx)))
    (map-set pending-transactions tx-id
      (merge tx { executed: true })
    )
    (ok true)
  )
)

;; Getter for total owners
(define-read-only (get-total-owners)
  (ok (var-get total-owners))
)

;; Getter for transaction details
(define-read-only (get-transaction (tx-id uint))
  (ok (map-get? pending-transactions tx-id))
)