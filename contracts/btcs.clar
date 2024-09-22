;; Multi-Signature Wallet with Time-locked Transactions, Spending Limits, RBAC, and Multiple Asset Support (MAS)

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
(define-constant ERR_UNSUPPORTED_ASSET (err u116))
(define-constant ERR_INSUFFICIENT_BALANCE (err u117))

;; Define roles
(define-data-var ROLE_ADMIN uint u1)
(define-data-var ROLE_MANAGER uint u2)
(define-data-var ROLE_SPENDER uint u3)

;; Define supported asset types
(define-trait supported-asset-trait
  (
    (transfer (uint principal principal) (response bool uint))
    (get-balance (principal) (response uint uint))
  )
)

;; Define data variables
(define-data-var total-owners uint u0)

;; Define data maps
(define-map owners principal bool)
(define-map pending-transactions
  uint
  {
    asset: principal,
    amount: uint,
    to: principal,
    approvals: uint,
    executed: bool,
    lock-until: uint,
    submitter: principal
  }
)
(define-map spending-limits { owner: principal, asset: principal } uint)
(define-map user-roles { user: principal, role: uint } bool)
(define-map supported-assets principal bool)

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

;; Add owner function (unchanged)
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

;; Remove owner function (unchanged)
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

;; Set spending limit function (updated for multiple assets)
(define-public (set-spending-limit (owner principal) (asset principal) (limit uint))
  (begin
    (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? owners owner)) ERR_NOT_OWNER)
    (asserts! (is-some (map-get? supported-assets asset)) ERR_UNSUPPORTED_ASSET)
    (map-set spending-limits { owner: owner, asset: asset } limit)
    (ok true)
  )
)

;; Assign role function (unchanged)
(define-public (assign-role (user principal) (role uint))
  (begin
    (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
    (asserts! (or (is-eq role (var-get ROLE_ADMIN)) (is-eq role (var-get ROLE_MANAGER)) (is-eq role (var-get ROLE_SPENDER))) ERR_INVALID_ROLE)
    (map-set user-roles { user: user, role: role } true)
    (ok true)
  )
)

;; Revoke role function (unchanged)
(define-public (revoke-role (user principal) (role uint))
  (begin
    (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
    (map-delete user-roles { user: user, role: role })
    (ok true)
  )
)

;; New function to add supported asset
(define-public (add-supported-asset (asset principal))
  (begin
    (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
    (asserts! (contract-call? asset get-balance CONTRACT_OWNER) ERR_UNSUPPORTED_ASSET)
    (map-set supported-assets asset true)
    (ok true)
  )
)

;; Submit transaction function (updated for multiple assets)
(define-public (submit-transaction (asset principal) (amount uint) (to principal) (lock-until uint))
  (let
    (
      (tx-id (+ (var-get transaction-nonce) u1))
      (sender-limit (default-to u0 (map-get? spending-limits { owner: tx-sender, asset: asset })))
    )
    (asserts! (or (has-role tx-sender (var-get ROLE_MANAGER)) (has-role tx-sender (var-get ROLE_SPENDER))) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? owners tx-sender)) ERR_NOT_OWNER)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (>= lock-until block-height) ERR_INVALID_TIMELOCK)
    (asserts! (<= amount sender-limit) ERR_SPENDING_LIMIT_EXCEEDED)
    (asserts! (is-some (map-get? supported-assets asset)) ERR_UNSUPPORTED_ASSET)
    (try! (nft-mint? transaction-id tx-id tx-sender))
    (map-set pending-transactions tx-id
      {
        asset: asset,
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

;; Execute transaction function (updated for multiple assets)
(define-public (execute-transaction (tx-id uint))
  (let
    (
      (tx (unwrap! (map-get? pending-transactions tx-id) ERR_TX_NOT_FOUND))
      (asset-contract (contract-call? (get asset tx) get-balance CONTRACT_OWNER))
    )
    (asserts! (or (has-role tx-sender (var-get ROLE_ADMIN)) (has-role tx-sender (var-get ROLE_MANAGER))) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? owners tx-sender)) ERR_NOT_OWNER)
    (asserts! (not (get executed tx)) ERR_ALREADY_EXECUTED)
    (asserts! (>= (get approvals tx) MIN_SIGNATURES) ERR_INSUFFICIENT_APPROVALS)
    (asserts! (>= block-height (get lock-until tx)) ERR_TIMELOCK_NOT_EXPIRED)
    (asserts! (>= (unwrap! asset-contract ERR_UNSUPPORTED_ASSET) (get amount tx)) ERR_INSUFFICIENT_BALANCE)
    (try! (contract-call? (get asset tx) transfer (get amount tx) CONTRACT_OWNER (get to tx)))
    (map-set pending-transactions tx-id
      (merge tx { executed: true })
    )
    (ok true)
  )
)

;; Cancel transaction function (unchanged)
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

;; Getter functions (some updated for multiple assets)
(define-read-only (get-total-owners)
  (ok (var-get total-owners))
)

(define-read-only (get-transaction (tx-id uint))
  (ok (map-get? pending-transactions tx-id))
)

(define-read-only (get-current-block-height)
  (ok block-height)
)

(define-read-only (get-spending-limit (owner principal) (asset principal))
  (ok (map-get? spending-limits { owner: owner, asset: asset }))
)

(define-read-only (get-user-role (user principal) (role uint))
  (ok (has-role user role))
)

(define-read-only (is-supported-asset (asset principal))
  (ok (is-some (map-get? supported-assets asset)))
)