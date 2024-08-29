# Collaborative Bitcoin Custody Solution

## Overview

This project implements a multi-signature wallet system that allows for customizable, decentralized custody arrangements using Clarity smart contracts on the Stacks blockchain. The system is designed to provide enhanced security and flexibility for managing Bitcoin assets.

## Features

- Multi-signature wallet functionality
- Customizable number of owners (up to 5)
- Minimum signature requirement for transaction execution
- Transaction submission and approval process
- Decentralized custody management
- Time-locked transactions
- Individual spending limits for owners (NEW)

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
   - Only registered owners can submit, approve, and execute transactions
   - Contract owner has special privileges for managing owners and setting spending limits

4. Spending Limits (NEW)
   - Set individual spending limits for each owner
   - Enforce spending limits during transaction submission

## Functions

### Owner Management
- `add-owner`: Add a new owner to the wallet
- `remove-owner`: Remove an existing owner from the wallet

### Transaction Management
- `submit-transaction`: Submit a new transaction for approval, with time-lock and spending limit checks
- `approve-transaction`: Approve a pending transaction
- `execute-transaction`: Execute a transaction that has met the approval threshold and time-lock has expired
- `cancel-transaction`: Cancel a time-locked transaction before it becomes executable

### Spending Limit Management (NEW)
- `set-spending-limit`: Set or update the spending limit for a specific owner

### Getters
- `get-total-owners`: Get the current number of wallet owners
- `get-transaction`: Retrieve details of a specific transaction
- `get-current-block-height`: Get the current block height
- `get-spending-limit`: Retrieve the spending limit for a specific owner (NEW)

## Time-Locked Transactions

The time-locking feature adds an extra layer of security and flexibility to our multi-signature wallet:

- Transactions can be scheduled for future execution by specifying a `lock-until` block height.
- Transactions cannot be executed before the specified block height is reached, even if they have sufficient approvals.
- The submitter of a time-locked transaction can cancel it before the lock period expires.
- This feature enables use cases such as:
  - Scheduled payments
  - Cool-down periods for large transactions
  - Cancellation of pending transactions if circumstances change

## Spending Limits (NEW)

The new spending limits feature provides granular control over transaction amounts:

- Each owner can have an individual spending limit set by the contract owner.
- When submitting a transaction, the amount is checked against the sender's spending limit.
- Transactions exceeding the sender's spending limit will be rejected.
- This feature enables:
  - Hierarchical control within organizations
  - Risk management for shared wallets
  - Gradual increase of privileges for new owners

## Usage

To interact with this smart contract, you'll need to use a Stacks wallet and have STX tokens for transaction fees. The contract can be deployed on the Stacks blockchain, after which you can interact with it using its contract address.

When submitting a transaction, you need to specify:
1. The amount (which must be within your spending limit)
2. The recipient's address
3. A `lock-until` parameter, which should be a future block height

You can use the `get-current-block-height` function to determine the current block height when setting time-locks.

The contract owner can set spending limits for each owner using the `set-spending-limit` function.

## Future Enhancements

In upcoming iterations, we plan to implement:
- Role-based access control

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