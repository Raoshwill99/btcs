# Collaborative Bitcoin Custody Solution

## Overview

The Collaborative Bitcoin Custody Solution is an advanced multi-signature wallet system built on the Stacks blockchain using Clarity smart contracts. This project aims to provide a secure, flexible, and decentralized solution for managing Bitcoin assets, catering to individuals, businesses, and organizations requiring enhanced control and security over their cryptocurrency holdings.

## Features

- Multi-signature wallet functionality
- Customizable number of owners (up to 5)
- Minimum signature requirement for transaction execution
- Transaction submission and approval process
- Decentralized custody management
- Time-locked transactions
- Individual spending limits for owners
- Role-based access control (RBAC)
- Multiple asset support
- Safety Module with Recovery Options (NEW)

## Smart Contract Structure

The main components of the smart contract include:

1. Owner Management
   - Add and remove wallet owners
   - Track total number of owners

2. Transaction Management
   - Submit new transactions (with time-locking and spending limit checks)
   - Approve pending transactions
   - Execute transactions with sufficient approvals and after time-lock expiry
   - Cancel time-locked transactions

3. Access Control
   - Role-based permissions for various operations
   - Contract owner has special privileges for managing owners and roles
   - Guardian system for wallet recovery (NEW)

4. Spending Limits
   - Set individual spending limits for each owner per asset type
   - Enforce spending limits during transaction submission

5. Safety Module (NEW)
   - Recovery system with guardians
   - Time-delayed recovery process
   - Multi-signature recovery approval
   - Configuration backup support

## Functions

### Owner Management
- `add-owner`: Add a new owner to the wallet (Admin only)
- `remove-owner`: Remove an existing owner from the wallet (Admin only)

### Safety and Recovery Management (NEW)
- `add-guardian`: Add a new guardian for recovery (Admin only)
- `remove-guardian`: Remove an existing guardian (Admin only)
- `initiate-recovery`: Start the recovery process (Guardian only)
- `approve-recovery`: Approve a recovery request (Guardian only)
- `execute-recovery`: Execute an approved recovery after delay
- `backup-configuration`: Store backup configuration hash (Admin only)

### Role Management
- `assign-role`: Assign a role to a user (Admin only)
- `revoke-role`: Revoke a role from a user (Admin only)

### Getters
- `get-recovery-request-public`: Get details of a specific recovery request
- `is-guardian`: Check if an address is a guardian
- `check-admin`: Check if an address is an admin
- `get-total-owners`: Get the current number of wallet owners
- `get-transaction`: Retrieve details of a specific transaction
- `get-current-block-height`: Get the current block height
- `get-spending-limit`: Retrieve the spending limit for a specific owner
- `get-user-role`: Check if a user has a specific role
- `is-supported-asset`: Check if an asset is supported by the wallet

## Safety Module (NEW)

The new safety module enhances the security and recoverability of the wallet system:

### Guardian System
- Designated guardians who can initiate and approve recovery processes
- Multiple guardians required for recovery approval
- Only admins can add or remove guardians

### Recovery Process
1. Guardian initiates recovery with new owner address
2. Other guardians must approve the recovery request
3. 24-hour time delay before execution
4. Requires minimum number of guardian approvals
5. Only approved recovery requests can be executed

### Backup System
- Administrators can store configuration backup hashes
- Enables safe recovery of wallet settings
- Provides additional layer of security for wallet recovery

## Role-Based Access Control (RBAC)

The RBAC feature provides granular control over user permissions within the wallet system:

- Three predefined roles: ADMIN, MANAGER, and SPENDER
- ADMIN: Can perform all operations, including managing owners, roles, and spending limits
- MANAGER: Can submit, approve, and execute transactions
- SPENDER: Can only submit transactions
- Roles are assigned and revoked by admins
- Each function checks for appropriate role permissions before execution

## Time-Locked Transactions

The time-locking feature adds an extra layer of security and flexibility to our multi-signature wallet:

- Transactions can be scheduled for future execution by specifying a `lock-until` block height
- Transactions cannot be executed before the specified block height is reached
- The submitter of a time-locked transaction can cancel it before the lock period expires
- Enables use cases such as scheduled payments and cool-down periods

## Spending Limits

The spending limits feature provides granular control over transaction amounts:

- Each owner can have individual spending limits set by an admin
- When submitting a transaction, the amount is checked against the sender's spending limit
- Transactions exceeding the sender's spending limit will be rejected
- Enables hierarchical control within organizations

## Usage

To interact with this smart contract, you'll need to use a Stacks wallet and have STX tokens for transaction fees. The contract can be deployed on the Stacks blockchain, after which you can interact with it using its contract address.

### Recovery Process Steps:
1. Guardian initiates recovery with new owner's address
2. Other guardians approve the recovery request
3. Wait for 24-hour delay period
4. Execute recovery if minimum approvals are met

### Backup Process:
1. Administrators can store backup configuration
2. Use backup hash for recovery verification
3. Ensure multiple administrators maintain copies

## Future Enhancements

Upcoming iterations:
- Advanced recovery scenarios handling
- Integration with external security services
- Enhanced backup and restore capabilities
- User interface for easier interaction
- Advanced analytics and reporting features

## Development

This project is developed using Clarity, the smart contract language for the Stacks blockchain. To set up a development environment:

1. Install the [Stacks CLI](https://docs.stacks.co/write-smart-contracts/clarinet)
2. Clone this repository
3. Use Clarinet to test and deploy the contract

## Contributing

Contributions to this project are welcome. Please ensure you follow the coding standards and submit pull requests for any new features or bug fixes.

## License

[MIT License](LICENSE)

## Contact

For any queries regarding this project, please open an issue in the GitHub repository.
