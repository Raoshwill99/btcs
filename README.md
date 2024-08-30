# Collaborative Bitcoin Custody Solution

## Overview

This project implements a sophisticated multi-signature wallet system that allows for customizable, decentralized custody arrangements using Clarity smart contracts on the Stacks blockchain. The system is designed to provide enhanced security, flexibility, and granular control for managing Bitcoin assets.

## Features

- Multi-signature wallet functionality
- Customizable number of owners (up to 5)
- Minimum signature requirement for transaction execution
- Transaction submission and approval process
- Decentralized custody management
- Time-locked transactions
- Individual spending limits for owners
- Role-based access control (RBAC) (NEW)

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
   - Role-based permissions for various operations (NEW)
   - Contract owner has special privileges for managing owners, roles, and setting spending limits

4. Spending Limits
   - Set individual spending limits for each owner
   - Enforce spending limits during transaction submission

5. Role Management (NEW)
   - Assign and revoke roles to/from users
   - Define permissions based on roles

## Functions

### Owner Management
- `add-owner`: Add a new owner to the wallet (Admin only)
- `remove-owner`: Remove an existing owner from the wallet (Admin only)

### Transaction Management
- `submit-transaction`: Submit a new transaction for approval, with time-lock and spending limit checks (Manager or Spender)
- `approve-transaction`: Approve a pending transaction (Admin or Manager)
- `execute-transaction`: Execute a transaction that has met the approval threshold and time-lock has expired (Admin or Manager)
- `cancel-transaction`: Cancel a time-locked transaction before it becomes executable (Transaction submitter or Admin)

### Spending Limit Management
- `set-spending-limit`: Set or update the spending limit for a specific owner (Admin only)

### Role Management (NEW)
- `assign-role`: Assign a role to a user (Admin only)
- `revoke-role`: Revoke a role from a user (Admin only)

### Getters
- `get-total-owners`: Get the current number of wallet owners
- `get-transaction`: Retrieve details of a specific transaction
- `get-current-block-height`: Get the current block height
- `get-spending-limit`: Retrieve the spending limit for a specific owner
- `get-user-role`: Check if a user has a specific role (NEW)

## Role-Based Access Control (RBAC) (NEW)

The new RBAC feature provides granular control over user permissions within the wallet system:

- Three predefined roles: ADMIN, MANAGER, and SPENDER
- ADMIN: Can perform all operations, including managing owners, roles, and spending limits
- MANAGER: Can submit, approve, and execute transactions
- SPENDER: Can only submit transactions
- Roles are assigned and revoked by admins
- Each function checks for appropriate role permissions before execution

This feature enables:
- Hierarchical management structure within organizations
- Separation of duties for enhanced security
- Flexible permission management for different user types

## Time-Locked Transactions

The time-locking feature adds an extra layer of security and flexibility to our multi-signature wallet:

- Transactions can be scheduled for future execution by specifying a `lock-until` block height.
- Transactions cannot be executed before the specified block height is reached, even if they have sufficient approvals.
- The submitter of a time-locked transaction can cancel it before the lock period expires.

## Spending Limits

The spending limits feature provides granular control over transaction amounts:

- Each owner can have an individual spending limit set by an admin.
- When submitting a transaction, the amount is checked against the sender's spending limit.
- Transactions exceeding the sender's spending limit will be rejected.

## Usage

To interact with this smart contract, you'll need to use a Stacks wallet and have STX tokens for transaction fees. The contract can be deployed on the Stacks blockchain, after which you can interact with it using its contract address.

When submitting a transaction, you need to specify:
1. The amount (which must be within your spending limit)
2. The recipient's address
3. A `lock-until` parameter, which should be a future block height

You can use the `get-current-block-height` function to determine the current block height when setting time-locks.

Admins can manage roles and spending limits using the appropriate functions.

## Future Enhancements

In upcoming iterations, we plan to implement:
- User interface for easier interaction with the smart contract
- Integration with external oracle services for enhanced functionality
- Support for multiple asset types

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
