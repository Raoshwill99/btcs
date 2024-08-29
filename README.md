# Collaborative Bitcoin Custody Solution

## Overview

This project implements a multi-signature wallet system using Clarity smart contracts on the Stacks blockchain. The system allows for customizable, decentralized custody arrangements for managing Bitcoin assets.

### Key Features

- Multi-signature wallet functionality
- Customizable number of required signatures
- Owner management (add/remove)
- Transaction submission, approval, and execution
- Built on Stacks blockchain, interacting with Bitcoin

## Smart Contract Structure

The main smart contract (`multi-sig-wallet`) contains the following key components:

1. Constants:
   - `CONTRACT_OWNER`: The address that deployed the contract
   - `MIN_SIGNATURES`: Minimum number of signatures required to execute a transaction
   - `MAX_OWNERS`: Maximum number of wallet owners allowed

2. Data Structures:
   - `owners`: Map of principal addresses to boolean, representing wallet owners
   - `pending-transactions`: Map of transaction IDs to transaction details
   - `transaction-id`: Non-fungible token for unique transaction IDs

3. Main Functions:
   - `add-owner`: Add a new owner to the wallet
   - `remove-owner`: Remove an existing owner from the wallet
   - `submit-transaction`: Submit a new transaction for approval
   - `approve-transaction`: Approve a pending transaction
   - `execute-transaction`: Execute a transaction that has met the signature threshold

4. Getter Functions:
   - `get-total-owners`: Retrieve the current number of wallet owners
   - `get-transaction`: Retrieve details of a specific transaction

## Setup and Deployment

To deploy this smart contract:

1. Ensure you have the Stacks CLI installed and configured.
2. Deploy the contract to the Stacks blockchain using the Stacks CLI:

   stx deploy multi-sig-wallet.clar
   `

3. Note the contract address after successful deployment.

## Usage

Interact with the deployed contract using the Stacks CLI or integrate it into your dApp:

1. Add owners:
   `
   stx call add-owner <new-owner-address>
   `

2. Submit a transaction:
   `
   stx call submit-transaction <amount> <recipient-address>
   `

3. Approve a transaction:
   `
   stx call approve-transaction <transaction-id>
   `

4. Execute a transaction:
   `
   stx call execute-transaction <transaction-id>
   `

## Security Considerations

- Ensure that the `CONTRACT_OWNER` address is securely managed, as it has special privileges.
- Carefully manage the list of owners and the `MIN_SIGNATURES` threshold to maintain the security of the wallet.
- Always verify transaction details before approval and execution.

## Future Enhancements

In upcoming iterations, we plan to implement:

- Time-locked transactions
- Spending limits
- Role-based access control

## Contributing

This project is under active development. Please refer to the repository's issues and pull requests for the latest status and contribution guidelines.

## License

[Insert appropriate license information here]

## Contact

[Insert contact information or link to project repository here]
