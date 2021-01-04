/*
@Copyright Drop Games 2020
 ___   ___   __  __   ______   ______   ______         _______   __       ________   ______   ______     
/__/\ /__/\ /_/\/_/\ /_____/\ /_____/\ /_____/\      /_______/\ /_/\     /_______/\ /_____/\ /_____/\    
\::\ \\  \ \\ \ \ \ \\:::_ \ \\::::_\/_\:::_ \ \     \::: _  \ \\:\ \    \::: _  \ \\:::_ \ \\::::_\/_   
 \::\/_\ .\ \\:\_\ \ \\:(_) \ \\:\/___/\\:(_) ) )_    \::(_)  \/_\:\ \    \::(_)  \ \\:\ \ \ \\:\/___/\  
  \:: ___::\ \\::::_\/ \: ___\/ \::___\/_\: __ `\ \    \::  _  \ \\:\ \____\:: __  \ \\:\ \ \ \\::___\/_ 
   \: \ \\::\ \ \::\ \  \ \ \    \:\____/\\ \ `\ \ \    \::(_)  \ \\:\/___/\\:.\ \  \ \\:\/.:| |\:\____/\
    \__\/ \::\/  \__\/   \_\/     \_____\/ \_\/ \_\/     \_______\/ \_____\/ \__\/\__\/ \____/_/ \_____\/
*/

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

pragma solidity ^0.8.0;

// @dev base contract that allows company access and functional control
contract HBBase {


    //* ownership hierarchy adapted from cryptotitties */

    /// @dev Emited when contract is upgraded 
    event ContractUpgrade(address newContract);

    // @dev company addresses
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;

    /// @dev Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    /// @dev Access modifier for CFO-only functionality
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    /// @dev Access modifier for COO-only functionality
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }

    /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param _newCEO The address of the new CEO
    function setCEO(address _newCEO) public onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    /// @dev Assigns a new address to act as the CFO. Only available to the current CEO.
    /// @param _newCFO The address of the new CFO
    function setCFO(address _newCFO) public onlyCEO {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param _newCOO The address of the new COO
    function setCOO(address _newCOO) public onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }

    function withdrawBalance() external onlyCFO {
        cfoAddress.transfer(this.balance);
    }


    /*** Pausable functionality adapted from OpenZeppelin ***/
    // used to potentially 

    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier whenPaused {
        require(paused);
        _;
    }

    /// @dev Called by any "C-level" role to pause the contract. Used only when
    ///  a bug or exploit is detected and we need to limit damage.
    function pause() public onlyCLevel whenNotPaused {
        paused = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    function unpause() public onlyCEO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}


contract HBItems is ERC1155 is HBBase{

  //Index of our Space Rock ERC20 wrap
  uint256 public constant SPRK = 0;

  //Tier 2 Items printed by creator
  uint256 private _serialIDIterator = 1;

  address[] public founders;

  

  constructor() ERC1155("https://api.playhyperblade.com/item/{id}.json")
  {
  }

   /**
    * @dev Introduces a new item to the economy must by approved by a C-Level Drop Games executive
    * @param _initialOwner          Address of the future owner of the token
    * @param _initialSupply          Token ID to mint
    * @param _mintQuantity    Amount of tokens to mint
    * @param _data        Data to pass if receiver is contract
    */
  function createItem(
    address _initialOwner,
    uint256 _initialSupply,
    string calldata _uri,
    bytes calldata _data
  ) onlyCLevel  returns(uint256) {
    uint256 _id = generateSerialTokenID();
    _mint(_initialOwner, _id, _initialSupply, data)
    return _id;
  }


  function generateSerialTokenID() private returns (uint256) {
    return _serialIDIterator++;
  }

  /**
    * @dev Mints some amount of tokens to an address
    * @param _to          Address of the future owner of the token
    * @param _id          Token ID to mint
    * @param _quantity    Amount of tokens to mint
    * @param _data        Data to pass if receiver is contract
    */
  function mint(
    address _to,
    uint256 _id,
    uint256 _quantity,
    bytes memory _data
  ) public creatorOnly(_id) {
    _mint(_to, _id, _quantity, _data);
    tokenSupply[_id] = tokenSupply[_id].add(_quantity);
  }
}


