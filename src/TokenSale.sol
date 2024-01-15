// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenSale is ERC20, Ownable {
    uint256 public constant DECIMALS = 18;
    uint256 public constant TOKEN_SUPPLY = 1_000_000 * (10**DECIMALS); // Total supply of project tokens

    uint256 public presaleCap;
    uint256 public publicSaleCap;

    uint256 public presaleMinContribution;
    uint256 public presaleMaxContribution;

    uint256 public publicSaleMinContribution;
    uint256 public publicSaleMaxContribution;

    uint256 public presaleStartTime;
    uint256 public presaleEndTime;

    uint256 public publicSaleStartTime;
    uint256 public publicSaleEndTime;

    bool public presaleActive;
    bool public publicSaleActive;

    mapping(address => uint256) public presaleContributions;
    mapping(address => uint256) public publicSaleContributions;

    event TokensPurchased(address indexed buyer, uint256 amount, uint256 value);
    event TokensDistributed(address indexed recipient, uint256 amount);
    event RefundClaimed(address indexed contributor, uint256 amount);

    modifier onlyPresaleActive() {
        require(presaleActive && block.timestamp >= presaleStartTime && block.timestamp <= presaleEndTime, "Presale is not active");
        _;
    }

    modifier onlyPublicSaleActive() {
        require(publicSaleActive && block.timestamp >= publicSaleStartTime && block.timestamp <= publicSaleEndTime, "Public sale is not active");
        _;
    }

    constructor(
        uint256 _presaleCap,
        uint256 _publicSaleCap,
        uint256 _presaleMinContribution,
        uint256 _presaleMaxContribution,
        uint256 _publicSaleMinContribution,
        uint256 _publicSaleMaxContribution,
        uint256 _presaleStartTime,
        uint256 _presaleEndTime,
        uint256 _publicSaleStartTime,
        uint256 _publicSaleEndTime
    ) ERC20("ProjectToken", "PROJ") {
        require(_presaleCap > 0 && _publicSaleCap > 0, "Caps must be greater than 0");
        require(_presaleMinContribution > 0 && _presaleMaxContribution >= _presaleMinContribution, "Invalid presale contribution limits");
        require(_publicSaleMinContribution > 0 && _publicSaleMaxContribution >= _publicSaleMinContribution, "Invalid public sale contribution limits");

        presaleCap = _presaleCap;
        publicSaleCap = _publicSaleCap;

        presaleMinContribution = _presaleMinContribution;
        presaleMaxContribution = _presaleMaxContribution;

        publicSaleMinContribution = _publicSaleMinContribution;
        publicSaleMaxContribution = _publicSaleMaxContribution;

        presaleStartTime = _presaleStartTime;
        presaleEndTime = _presaleEndTime;

        publicSaleStartTime = _publicSaleStartTime;
        publicSaleEndTime = _publicSaleEndTime;

        _mint(address(this), TOKEN_SUPPLY);
    }

    /**
     * @dev Contribute Ether to the presale and receive project tokens in return.
     */
    function contributeToPresale() external payable onlyPresaleActive {
        require(msg.value >= presaleMinContribution && msg.value <= presaleMaxContribution, "Invalid contribution amount");

        uint256 tokensToTransfer = calculateTokens(msg.value, presaleCap, address(this).balance);
        require(tokensToTransfer > 0, "Presale cap reached");

        presaleContributions[msg.sender] += msg.value;
        _transfer(address(this), msg.sender, tokensToTransfer);

        emit TokensPurchased(msg.sender, tokensToTransfer, msg.value);
    }

    /**
     * @dev Contribute Ether to the public sale and receive project tokens in return.
     */
    function contributeToPublicSale() external payable onlyPublicSaleActive {
        require(msg.value >= publicSaleMinContribution && msg.value <= publicSaleMaxContribution, "Invalid contribution amount");

        uint256 tokensToTransfer = calculateTokens(msg.value, publicSaleCap, address(this).balance);
        require(tokensToTransfer > 0, "Public sale cap reached");

        publicSaleContributions[msg.sender] += msg.value;
        _transfer(address(this), msg.sender, tokensToTransfer);

        emit TokensPurchased(msg.sender, tokensToTransfer, msg.value);
    }

    /**
     * @dev Distribute project tokens to a specified address. Can only be called by the owner.
     * @param recipient The address to receive the tokens.
     * @param amount The amount of tokens to distribute.
     */
    function distributeTokens(address recipient, uint256 amount) external onlyOwner {
        require(amount > 0, "Invalid token amount");
        _transfer(address(this), recipient, amount);
        emit TokensDistributed(recipient, amount);
    }

    /**
     * @dev Allows contributors to claim a refund if the minimum cap for either the presale or public sale is not reached.
     */
    function claimRefund() external {
        require(!presaleActive || block.timestamp > presaleEndTime, "Refunds not available yet");

        if (presaleActive && address(this).balance < presaleCap) {
            claimPresaleRefund();
        }

        if (publicSaleActive && address(this).balance < publicSaleCap) {
            claimPublicSaleRefund();
        }
    }

    /**
     * @dev Internal function to calculate the number of tokens to transfer based on the contribution amount and caps.
     * @param contributionAmount The amount of Ether contributed.
     * @param saleCap The maximum cap for the sale phase.
     * @param currentBalance The current balance of the contract.
     * @return The number of tokens to transfer.
     */
    function calculateTokens(uint256 contributionAmount, uint256 saleCap, uint256 currentBalance) internal pure returns (uint256) {
        uint256 tokensToTransfer = (contributionAmount * TOKEN_SUPPLY) / saleCap;
        if (tokensToTransfer > currentBalance) {
            return 0;
        }
        return tokensToTransfer;
    }

    /**
     * @dev Internal function to handle
