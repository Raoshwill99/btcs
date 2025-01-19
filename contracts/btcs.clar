;; Multi-Signature Wallet with Safety Module for Recovery

;; Define constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant MIN_SIGNATURES u2)
(define-constant MAX_OWNERS u5)
(define-constant RECOVERY_DELAY u144) ;; Approximately 24 hours in blocks

;; Error constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_GUARDIAN (err u118))
(define-constant ERR_RECOVERY_IN_PROGRESS (err u119))
(define-constant ERR_RECOVERY_NOT_READY (err u120))
(define-constant ERR_NOT_FOUND (err u121))
(define-constant ERR_ALREADY_EXECUTED (err u122))
(define-constant ERR_INSUFFICIENT_APPROVALS (err u123))

;; Define all data maps
(define-map owners principal bool)
(define-map admin-role principal bool)
(define-map guardians principal bool)
(define-map recovery-requests 
    uint 
    {
        initiator: principal,
        new-owner: principal,
        timestamp: uint,
        approvals: uint,
        executed: bool
    }
)

;; Data variables
(define-data-var recovery-nonce uint u0)

;; Initialize contract owner as admin and owner
(map-set admin-role CONTRACT_OWNER true)
(map-set owners CONTRACT_OWNER true)

;; Check if principal is admin
(define-private (is-admin (principal principal))
    (default-to false (map-get? admin-role principal))
)

;; Add guardian function
(define-public (add-guardian (new-guardian principal))
    (begin
        (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
        (map-set guardians new-guardian true)
        (ok true)
    )
)

;; Remove guardian function
(define-public (remove-guardian (guardian principal))
    (begin
        (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
        (map-delete guardians guardian)
        (ok true)
    )
)

;; Add admin function
(define-public (add-admin (new-admin principal))
    (begin
        (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
        (map-set admin-role new-admin true)
        (ok true)
    )
)

;; Remove admin function
(define-public (remove-admin (admin principal))
    (begin
        (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
        (asserts! (not (is-eq admin CONTRACT_OWNER)) ERR_UNAUTHORIZED)
        (map-delete admin-role admin)
        (ok true)
    )
)

;; Initiate recovery function
(define-public (initiate-recovery (new-owner principal))
    (let
        (
            (request-id (+ (var-get recovery-nonce) u1))
        )
        (asserts! (default-to false (map-get? guardians tx-sender)) ERR_INVALID_GUARDIAN)
        (map-set recovery-requests request-id
            {
                initiator: tx-sender,
                new-owner: new-owner,
                timestamp: block-height,
                approvals: u1,
                executed: false
            }
        )
        (var-set recovery-nonce request-id)
        (ok request-id)
    )
)

;; Approve recovery function
(define-public (approve-recovery (request-id uint))
    (let
        (
            (request (get-recovery-request request-id))
        )
        (asserts! (is-some request) ERR_NOT_FOUND)
        (let 
            (
                (unwrapped-request (unwrap-panic request))
            )
            (asserts! (default-to false (map-get? guardians tx-sender)) ERR_INVALID_GUARDIAN)
            (asserts! (not (get executed unwrapped-request)) ERR_ALREADY_EXECUTED)
            (map-set recovery-requests request-id
                (merge unwrapped-request { approvals: (+ (get approvals unwrapped-request) u1) })
            )
            (ok true)
        )
    )
)

;; Execute recovery function
(define-public (execute-recovery (request-id uint))
    (let
        (
            (request (get-recovery-request request-id))
        )
        (asserts! (is-some request) ERR_NOT_FOUND)
        (let 
            (
                (unwrapped-request (unwrap-panic request))
            )
            (asserts! (>= (- block-height (get timestamp unwrapped-request)) RECOVERY_DELAY) ERR_RECOVERY_NOT_READY)
            (asserts! (>= (get approvals unwrapped-request) MIN_SIGNATURES) ERR_INSUFFICIENT_APPROVALS)
            (asserts! (not (get executed unwrapped-request)) ERR_ALREADY_EXECUTED)
            
            ;; Mark recovery as executed
            (map-set recovery-requests request-id
                (merge unwrapped-request { executed: true })
            )
            (ok true)
        )
    )
)

;; Helper function to transfer ownership
(define-private (transfer-ownership (new-owner principal))
    (begin
        (map-delete owners CONTRACT_OWNER)
        (map-set owners new-owner true)
        (ok true)
    )
)

;; Getter for recovery request details
(define-private (get-recovery-request (request-id uint))
    (map-get? recovery-requests request-id)
)

;; Public getter for recovery request details
(define-read-only (get-recovery-request-public (request-id uint))
    (ok (map-get? recovery-requests request-id))
)

;; Check if address is a guardian
(define-read-only (is-guardian (address principal))
    (ok (default-to false (map-get? guardians address)))
)

;; Check if address is an admin
(define-read-only (check-admin (address principal))
    (ok (is-admin address))
)

;; Additional functions for backup and restore
(define-public (backup-configuration (backup-hash (buff 32)))
    (begin
        (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
        (print backup-hash)
        (ok true)
    )
)