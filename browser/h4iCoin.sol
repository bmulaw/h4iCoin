pragma solidity ^0.8.11;

contract h4iCoin {
    
    mapping (address => uint256) public balanceOf;

    string public name = "h4iCoin";
    string public symbol = "H4I";
    uint256 public max_supply = 42000000000000;
    uint256 public unspent_supply = 0;
    uint256 public spendable_supply = 0;
    uint256 public circulating_supply = 0;
    uint256 public decimals = 6;
    uint256 public reward = 50000000;
    uint256 public timeOfLastHalving = block.timestamp;
    uint public timeOfLastIncrease = block.timestamp;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed from, uint256 value);

    function h4iCoing() public {
        timeOfLastHalving = block.timestamp;
    }

    function updateSupply() internal returns (uint256) {
        if (block.timestamp - timeOfLastHalving >= 2100000 minutes) {
            reward /= 2;
            timeOfLastHalving = block.timestamp;
        }

        if (block.timestamp - timeOfLastIncrease >= 150 seconds) {
            uint256 increaseAmount = ((block.timestamp-timeOfLastHalving) / 150 seconds) * reward;
            spendable_supply += increaseAmount;
            unspent_supply += increaseAmount;
            timeOfLastIncrease = block.timestamp;
        }
        circulating_supply = spendable_supply - unspent_supply;

        return circulating_supply;
    }

    // transfer money
    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]); // not sending negative money
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        updateSupply();

        emit Transfer(msg.sender, _to, _value); // notify listeners of transfer
    }

    function mint() public payable {
        uint256 _value = msg.value / 100000000;
        require(balanceOf[msg.sender] + _value >= balanceOf[msg.sender]);
        
        updateSupply();

        require(unspent_supply - _value <= unspent_supply);
        unspent_supply -= _value;
        balanceOf[msg.sender] += _value;

        updateSupply();

        emit Mint(msg.sender, _value);
    }


    function withdraw(uint256 amountToWithdraw) public returns (bool) {
        // prevent overdraft
        require(balanceOf[msg.sender] >= amountToWithdraw);
        require(balanceOf[msg.sender] - amountToWithdraw <= balanceOf[msg.sender]);
    
        balanceOf[msg.sender] -= amountToWithdraw;

        unspent_supply += amountToWithdraw;
        amountToWithdraw *= 100000000;

        payable(msg.sender).transfer(amountToWithdraw);

        updateSupply();
        return true;
    }
}