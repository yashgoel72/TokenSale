# Token Sale Smart Contract

This repository contains a Solidity smart contract for a token sale with both presale and public sale phases. The contract is designed to be deployed on the Ethereum blockchain and allows users to contribute Ether in exchange for project tokens.

## Features

- **Presale and Public Sale:** Users can contribute Ether during both the presale and public sale phases to receive project tokens.

- **Caps and Limits:** The token sale has maximum caps on the total Ether that can be raised during the presale and public sale. There are also minimum and maximum contribution limits per participant.

- **Token Distribution:** Project tokens are distributed immediately upon contribution.

- **Refund Mechanism:** If the minimum cap for either the presale or public sale is not reached, contributors can claim a refund after the active period.

## Development Tools
This project was developed using the Foundry development environment for Ethereum smart contracts.

## Static Analysis
Slither has been used for automatic static analysis to ensure the contract's security and efficiency.

## Gas Optimization
- The contract has undergone gas optimization strategies during development to reduce transaction costs and improve efficiency.
- Find the @audit tags for the gas optimizations

