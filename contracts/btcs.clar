;; Multi-Signature Wallet with Time-locked Transactions, Spending Limits, and Role-Based Access Control

;; Define constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant MIN_SIGNATURES u2)
(define-constant MAX_OWNERS u5)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_OWNER_LIMIT (err u101))
(define-constant ERR_ALREADY_OWNER (err u102))
(define-constant ERR_NOT_OWNER (err u103))
(define-constant ERR_MIN_SIGNATURES (err u104))
(define-constant ERR_INVALID_AMOUNT (err u105))
(define-constant ERR_TX_NOT_FOUND (err u106))
(define-constant ERR_ALREADY_EXECUTED (err u107))
(define-constant ERR_INSUFFICIENT_APPROVALS (err u108))
(define-constant ERR_TIMELOCK_NOT_EXPIRED (err u109))
(define-constant ERR_INVALID_TIMELOCK (err u110))
(define-constant ERR_CANCEL_UNAUTHORIZED (err u111))
(define-constant ERR_TIMELOCK_EXPIRED (err u112))
(define-constant ERR_SPENDING_LIMIT_EXCEEDED (err u113))
(define-constant ERR_INVALID_ROLE (err u114))
(define-constant ERR_INSUFFICIENT_PERMISSIONS (err u115))

;; Define roles
(define-data-var ROLE_ADMIN uint u1)
(define-data-var ROLE_MANAGER uint u2)
(define-data-var ROLE_SPENDER uint u3)

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
    lock-until: uint,
    submitter: principal
  }
)
(define-map spending-limits principal uint)
(define-map user-roles { user: principal, role: uint } bool)

;; Define non-fungible token for transaction IDs
(define-non-fungible-token transaction-id uint)

;; Counter for transaction IDs
(define-data-var transaction-nonce uint u0)

;; Function to check if a user has a specific role
(define-private (has-role (user principal) (role uint))
  (default-to false (map-get? user-roles { user: user, role: role }))
)

;; Function to check if a user has admin privileges
(define-private (is-admin (user principal))
  (has-role user (var-get ROLE_ADMIN))
)

;; Add owner function (updated with role check)
(define-public (add-owner (new-owner principal))
  (begin
    (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
    (asserts! (< (var-get total-owners) MAX_OWNERS) ERR_OWNER_LIMIT)
    (asserts! (is-none (map-get? owners new-owner)) ERR_ALREADY_OWNER)
    (map-set owners new-owner true)
    (var-set total-owners (+ (var-get total-owners) u1))
    (ok true)
  )
)

;; Remove owner function (updated with role check)
(define-public (remove-owner (owner principal))
  (begin
    (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
    (asserts! (> (var-get total-owners) MIN_SIGNATURES) ERR_MIN_SIGNATURES)
    (asserts! (is-some (map-get? owners owner)) ERR_NOT_OWNER)
    (map-delete owners owner)
    (var-set total-owners (- (var-get total-owners) u1))
    (ok true)
  )
)

;; Set spending limit function (updated with role check)
(define-public (set-spending-limit (owner principal) (limit uint))
  (begin
    (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? owners owner)) ERR_NOT_OWNER)
    (map-set spending-limits owner limit)
    (ok true)
  )
)

;; New function to assign a role to a user
(define-public (assign-role (user principal) (role uint))
  (begin
    (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
    (asserts! (or (is-eq role (var-get ROLE_ADMIN)) (is-eq role (var-get ROLE_MANAGER)) (is-eq role (var-get ROLE_SPENDER))) ERR_INVALID_ROLE)
    (map-set user-roles { user: user, role: role } true)
    (ok true)
  )
)

;; New function to revoke a role from a user
(define-public (revoke-role (user principal) (role uint))
  (begin
    (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
    (map-delete user-roles { user: user, role: role })
    (ok true)
  )
)

;; Submit transaction function (updated with role check)
(define-public (submit-transaction (amount uint) (to principal) (lock-until uint))
  (let
    (
      (tx-id (+ (var-get transaction-nonce) u1))
      (sender-limit (default-to u0 (map-get? spending-limits tx-sender)))
    )
    (asserts! (or (has-role tx-sender (var-get ROLE_MANAGER)) (has-role tx-sender (var-get ROLE_SPENDER))) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? owners tx-sender)) ERR_NOT_OWNER)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (>= lock-until block-height) ERR_INVALID_TIMELOCK)
    (asserts! (<= amount sender-limit) ERR_SPENDING_LIMIT_EXCEEDED)
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

;; Approve transaction function (updated with role check)
(define-public (approve-transaction (tx-id uint))
  (let
    (
      (tx (unwrap! (map-get? pending-transactions tx-id) ERR_TX_NOT_FOUND))
    )
    (asserts! (or (has-role tx-sender (var-get ROLE_ADMIN)) (has-role tx-sender (var-get ROLE_MANAGER))) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? owners tx-sender)) ERR_NOT_OWNER)
    (asserts! (not (get executed tx)) ERR_ALREADY_EXECUTED)
    (map-set pending-transactions tx-id
      (merge tx { approvals: (+ (get approvals tx) u1) })
    )
    (ok true)
  )
)

;; Execute transaction function (updated with role check)
(define-public (execute-transaction (tx-id uint))
  (let
    (
      (tx (unwrap! (map-get? pending-transactions tx-id) ERR_TX_NOT_FOUND))
    )
    (asserts! (or (has-role tx-sender (var-get ROLE_ADMIN)) (has-role tx-sender (var-get ROLE_MANAGER))) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? owners tx-sender)) ERR_NOT_OWNER)
    (asserts! (not (get executed tx)) ERR_ALREADY_EXECUTED)
    (asserts! (>= (get approvals tx) MIN_SIGNATURES) ERR_INSUFFICIENT_APPROVALS)
    (asserts! (>= block-height (get lock-until tx)) ERR_TIMELOCK_NOT_EXPIRED)
    (try! (stx-transfer? (get amount tx) (as-contract tx-sender) (get to tx)))
    (map-set pending-transactions tx-id
      (merge tx { executed: true })
    )
    (ok true)
  )
)

;; Cancel transaction function (updated with role check)
(define-public (cancel-transaction (tx-id uint))
  (let
    (
      (tx (unwrap! (map-get? pending-transactions tx-id) ERR_TX_NOT_FOUND))
    )
    (asserts! (or (is-eq tx-sender (get submitter tx)) (has-role tx-sender (var-get ROLE_ADMIN))) ERR_UNAUTHORIZED)
    (asserts! (not (get executed tx)) ERR_ALREADY_EXECUTED)
    (asserts! (< block-height (get lock-until tx)) ERR_TIMELOCK_EXPIRED)
    (map-delete pending-transactions tx-id)
    (try! (nft-burn? transaction-id tx-id tx-sender))
    (ok true)
  )
)

;; Getter functions (unchanged)
(define-read-only (get-total-owners)
  (ok (var-get total-owners))
)

(define-read-only (get-transaction (tx-id uint))
  (ok (map-get? pending-transactions tx-id))
)

(define-read-only (get-current-block-height)
  (ok block-height)
)

(define-read-only (get-spending-limit (owner principal))
  (ok (map-get? spending-limits owner))
)

