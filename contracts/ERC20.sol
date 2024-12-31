// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface ERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) external view returns (uint256);

    /**
     * @dev Transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _approver address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _approver, address _spender)
        external
        returns (uint256);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}

/*
    Raw amount vs Token units
*/

contract MyToken is ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals; // for decimals = 3 -> 1 token = 1000, 1.5 token = 1500
    uint256 public totalSupply; // tokens in circulation
    mapping(address => uint256) public balanceOf;
    // approver => spender => amount
    mapping(address => mapping(address => uint256)) public allowance;
    address private owner;

    error InsufficientBalance();
    error InsufficientApproval();
    error Unauthorized();

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert Unauthorized();
        }
        _;
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        if (allowance[_from][msg.sender] < _value) {
            revert InsufficientApproval(); // or return false
        }

        allowance[_from][msg.sender] -= _value;

        return _transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        require(_spender != address(0));

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param amount The amount that will be created.
     */
    function mint(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "Cannot mint to zero address");

        balanceOf[account] += amount;
        totalSupply += amount;

        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "Cannot burn tokens of the zero address");
        require(amount <= balanceOf[account], "The burn amount is greater than the available amount of the account");

        totalSupply -= amount;
        balanceOf[account] -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) private returns (bool) {
        if (balanceOf[_from] < _value) {
            revert InsufficientBalance();
        }
        require(_to != address(0));

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);

        return true;
    }
}
