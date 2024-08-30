# Collaborative Bitcoin Custody Solution

## Overview

This project implements a multi-signature wallet system that allows for customizable, decentralized custody arrangements using Clarity smart contracts on the Stacks blockchain. The system is designed to provide enhanced security and flexibility for managing Bitcoin assets.

## Features

- Multi-signature wallet functionality
- Customizable number of owners (up to 5)
- Minimum signature requirement for transaction execution
- Transaction submission and approval process
- Decentralized custody management
- Time-locked transactions (NEW)

## Smart Contract Structure

The main components of the smart contract include:

1. Owner Management
   - Add and remove wallet owners
   - Track total number of owners

2. Transaction Management
   - Submit new transactions (now with time-locking)
   - Approve pending transactions
   - Execute transactions with sufficient approvals and after time-lock expiry
   - Cancel time-locked transactions (NEW)

3. Access Control
   - Only registered owners can submit, approve, and execute transactions
   - Contract owner has special privileges for managing owners

## Functions

### Owner Management
- `add-owner`: Add a new owner to the wallet
- `remove-owner`: Remove an existing owner from the wallet

### Transaction Management
- `submit-transaction`: Submit a new transaction for approval, now with a time-lock parameter
- `approve-transaction`: Approve a pending transaction
- `execute-transaction`: Execute a transaction that has met the approval threshold and time-lock has expired
- `cancel-transaction`: Cancel a time-locked transaction before it becomes executable (NEW)

### Getters

- `get-total-owners`: Get the current number of wallet owners
- `get-transaction`: Retrieve details of a specific transaction
- `get-current-block-height`: Get the current block height (NEW)

## Time-Locked Transactions

The new time-locking feature adds an extra layer of security and flexibility to our multi-signature wallet:

- Transactions can be scheduled for future execution by specifying a `lock-until` block height.
- Transactions cannot be executed before the specified block height is reached, even if they have sufficient approvals.
- The submitter of a time-locked transaction can cancel it before the lock period expires.
- This feature enables use cases such as:
  - Scheduled payments
  - Cool-down periods for large transactions
  - Cancellation of pending transactions if circumstances change

## Usage

To interact with this smart contract, you'll need to use a Stacks wallet and have STX tokens for transaction fees. The contract can be deployed on the Stacks blockchain, after which you can interact with it using its contract address.

When submitting a transaction, you now need to specify a `lock-until` parameter, which should be a future block height. You can use the `get-current-block-height` function to determine the current block height.

## Future Enhancements

In upcoming iterations, we plan to implement:
- Spending limits
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
