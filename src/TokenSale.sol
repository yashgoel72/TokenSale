// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenSale is ERC20 {
    address owner;
    uint256 public constant DECIMALS = 18;
    uint256 public constant TOKEN_SUPPLY = 1000000 * (10**DECIMALS); // Total supply of project tokens

    uint256 public presaleMinCap;
    uint256 public publicSaleMinCap;

    uint256 public presaleMaxCap;
    uint256 public publicSaleMaxCap;

    uint256 public presaleMinContribution;
    uint256 public presaleMaxContribution;

    uint256 public publicSaleMinContribution;
    uint256 public publicSaleMaxContribution;

    uint256 public presaleStartTime;
    uint256 public presaleEndTime;

    uint256 public publicSaleStartTime;
    uint256 public publicSaleEndTime;

    mapping(address => uint256) public presaleContributions;
    mapping(address => uint256) public publicSaleContributions;

    event TokensPurchased(address indexed buyer, uint256 amount, uint256 value);
    event TokensDistributed(address indexed recipient, uint256 amount);
    event RefundClaimed(address indexed contributor, uint256 amount);

    modifier onlyOwner() {
    require(owner == msg.sender, "Only Owner Can call this function");
    _;
    }

    modifier onlyPresaleActive() {
        require(block.timestamp >= presaleStartTime && block.timestamp <= presaleEndTime, "Presale is not active");
        _;
    }

    modifier onlyPublicSaleActive() {
        require(block.timestamp >= publicSaleStartTime && block.timestamp <= publicSaleEndTime, "Public sale is not active");
        _;
    }

    constructor(
        uint256 _presaleMinCap,
        uint256 _publicSaleMinCap,
        uint256 _presaleMaxCap,
        uint256 _publicSaleMaxCap,
        uint256 _presaleMinContribution,
        uint256 _presaleMaxContribution,
        uint256 _publicSaleMinContribution,
        uint256 _publicSaleMaxContribution,
        uint256 _presaleStartTime,
        uint256 _presaleEndTime,
        uint256 _publicSaleStartTime,
        uint256 _publicSaleEndTime
    ) ERC20("ProjectToken", "PROJ") {
        require(_presaleMaxCap >= 0 && _publicSaleMaxCap >= 0, "Caps must be greater than 0");
        require(_presaleMaxCap >= _presaleMinCap && _publicSaleMaxCap >= _presaleMinCap, "Max Cap must be greaterthan equal to Min Cap");
        require(_presaleMinContribution > 0 && _presaleMaxContribution >= _presaleMinContribution, "Invalid presale contribution limits");
        require(_publicSaleMinContribution > 0 && _publicSaleMaxContribution >= _publicSaleMinContribution, "Invalid public sale contribution limits");
        require(_presaleStartTime <= _presaleEndTime , "Invalid Presale Start and End Time");
        require(_publicSaleStartTime <= _publicSaleEndTime , "Invalid PublicSale Start and End Time");
        require(_presaleEndTime <= _publicSaleStartTime );

        owner = msg.sender;
        presaleMinCap = _presaleMinCap;
        publicSaleMinCap = _publicSaleMinCap;

        presaleMaxCap = _presaleMaxCap;
        publicSaleMaxCap = _publicSaleMaxCap;

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

        uint256 tokensToTransfer = calculateTokens(msg.value, presaleMaxCap, address(this).balance);
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

        uint256 tokensToTransfer = calculateTokens(msg.value, publicSaleMaxCap, address(this).balance);
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
     * @dev Allows contributors to claim a refund if the minimum cap for the presale is not reached.
     */
    function claimPresaleRefund() external {
        require(block.timestamp > presaleEndTime , "Cannot Claim Refund at this time");
        require(address(this).balance < presaleMinCap , "PreSale MinimumCap has been reached");
        uint256 contributionAmount = presaleContributions[msg.sender];
        require(contributionAmount > 0, "No presale contribution found");

        presaleContributions[msg.sender] = 0;
        payable(msg.sender).transfer(contributionAmount);

        emit RefundClaimed(msg.sender, contributionAmount);
    }

    /**
     * @dev Allows contributors to claim a refund if the minimum cap for the public sale is not reached.
     */
    function claimPublicSaleRefund() external {
        require(block.timestamp > publicSaleEndTime , "Cannot Claim Refund at this time");
        require(address(this).balance < publicSaleMinCap , "PublicSale MinimumCap has been reached");
        uint256 contributionAmount = publicSaleContributions[msg.sender];
        require(contributionAmount > 0, "No public sale contribution found");

        publicSaleContributions[msg.sender] = 0;
        payable(msg.sender).transfer(contributionAmount);

        emit RefundClaimed(msg.sender, contributionAmount);
    }
}