//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ZoinksToken is ERC20, Ownable {

    /// @dev The total number of tokens in circulation
    uint256 private _totalSupply;

    /// @dev initial supply of zoinkstoken
    uint256 public constant INITIAL_ZOINKS_SUPPLY = 35000000000000;

    /// @dev initial LP of zoinks/busd for liquidity
    uint256 public constant INITIAL_ZOINKS_LIQUIDITY_SUPPLY = 1000;

    /// @dev The circulation value
    uint256 private _circulationSupply = 0;

    /// @dev the rebase contract address
    address private _rebaseContract;

    /// @dev Official percent of zoinks token balances for each account
    mapping (address => uint256) private _balances;

    /// @dev Allowance amounts on behalf of others
    mapping(address => mapping(address => uint256)) private _allowances;

    struct InflationRewards {
        address accountAddress;
        uint256 percentage;
    }

    InflationRewards[] public inflationRewards;

    /**
     * @notice Construct a new Zoinks token
     */

    constructor() ERC20("ZOINKS", "ZOINKS") {}

    modifier onlyRebaseContract() {
        require(_rebaseContract == msg.sender, "not rebase contract");
        _;
    }

    function mint(address _address, uint256 _amount) public onlyOwner {
        _mint(_address, _amount);
    }

    function burnZoinks(uint256 _twap) external onlyRebaseContract {
        uint256 burnAmount = (1 - _twap) * _totalSupply;
        _burn(address(this), burnAmount);
    }

    function rebaseInflations(uint256 _twap) external onlyRebaseContract {
        uint256 inflationReward = (_twap - 1) * _circulationSupply / 5;

        for(uint256 i = 0; i < inflationRewards.length; i++)
        {
            uint256 amount = inflationReward * inflationRewards[i].percentage / 100;
            _transfer(address(this), inflationRewards[i].accountAddress, amount);

            _circulationSupply += amount;
        }
    }

    function setRebaseContract(address _account) external onlyOwner {
        _rebaseContract = _account;
    }

    function setInflationReward(address _account, uint256 _percentage) public onlyOwner {
        if(inflationRewards.length <= 7) {
            InflationRewards memory inflationReward;
            inflationReward.accountAddress = _account;
            inflationReward.percentage = _percentage;
            inflationRewards.push(inflationReward);
        }
    }

    function getChainId() internal view returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
    
}
