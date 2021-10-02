//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CoinLeagueChampionsMumbai is ERC721, VRFConsumerBase, Ownable {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;
    Counters.Counter private _tokenIdCounter;
    address constant internal TEAM_WALLET = 0x69be1977431935eEfCEb3cb23A682Dd1b601A1D4;
    uint256 constant PRE_MINE_MAX_SUPPLY = 150;
    uint256 constant MAX_SUPPLY_1 = 7850;
    uint256 constant MAX_SUPPLY_2 = 8000;
    uint256 constant MAX_SUPPLY = 15000;
    uint256 constant PRICE_FIRST = 0.001 ether;
    uint256 constant PRICE_SECOND = 0.001 ether;
    uint256 constant HOLDING_KIT = 125 * 10 ** 18;// 125 KIT
    uint256 constant HOLDING_BITT = 750 * 10 ** 18;// 750 BITT
    uint256 constant SALE_TIMESTAMP_FIRST = 1632751640;
    uint256 constant SALE_EARLY_TIMESTAMP_FIRST = 1632751640;
    uint256 constant SALE_TIMESTAMP_SECOND = 1632751640;
    uint256 constant SALE_EARLY_TIMESTAMP_SECOND = 1632751640;
     // Properties used for games
    mapping(uint256 => uint256) public attack;
    mapping(uint256 => uint256) public defense;
    mapping(uint256 => uint256) public run;
    bytes32 internal keyHash;
    uint256 internal fee;

    uint256 public randomResult;
    IERC20 internal immutable DEXKIT;
    IERC20 internal immutable BITTOKEN;
    IERC20 internal immutable WETH = IERC20(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619);
    // Mapping of rarity with token ID
    mapping(uint256 => int256) public rarity;
    mapping(bytes32 => address) requestToSender;
    mapping(bytes32 => uint256) requestToTokenId;
                                    //%1, 5 %, 7.5%, 9%, 12.5%, 15%                               
    uint256 [] accumulated_rarity = [0, 10, 60, 135, 225, 350, 500, 700, 1000];
    // VRF Data       
    // Item	Value
    // LINK Token	0x326C977E6efc84E512bB9C30f76E30c160eD06FB
    // VRF Coordinator	0x8C7382F9D8f56b33781fE506E897a4F1e2d17255
    // Key Hash	0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4
    // Fee	0.0001 LINK

    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyhash, address _kit, address _bittoken)
    ERC721("CoinLeagueChampions", "Champions")
    VRFConsumerBase(
            _VRFCoordinator, // VRF Coordinator
            _LinkToken  // LINK Token
        ) public
     {
        keyHash = _keyhash;
        fee = 0.0001 * 10**18; // 0.1 LINK
        DEXKIT = IERC20(_kit);
        BITTOKEN = IERC20(_bittoken);
    }
    // Owner can mint at any time
    function preMine() public onlyOwner returns (bytes32 requestId){
        require(_tokenIdCounter.current() < PRE_MINE_MAX_SUPPLY, "Pre mine supply reached" );
        requestId = safeMint();
    }

    function mintFirstRound() public returns (bytes32 requestId){
        if(canSaleEarly()){
            require(block.timestamp >= SALE_EARLY_TIMESTAMP_FIRST );
        }else{
            require(block.timestamp >= SALE_TIMESTAMP_FIRST );
        }
        require(_tokenIdCounter.current() >= PRE_MINE_MAX_SUPPLY, "Need to Premine First" );
        require(_tokenIdCounter.current() < MAX_SUPPLY_1 + PRE_MINE_MAX_SUPPLY, "First Round Max Supply reached" );
        WETH.safeTransferFrom(msg.sender, TEAM_WALLET, PRICE_FIRST);
        requestId = safeMint();
        
    }

    function mintSecondRound() public returns (bytes32 requestId){
        if(canSaleEarly()){
            require(block.timestamp >= SALE_EARLY_TIMESTAMP_SECOND );
        }else{
            require(block.timestamp >= SALE_TIMESTAMP_SECOND );
        }
        require(_tokenIdCounter.current() <= MAX_SUPPLY_1 + PRE_MINE_MAX_SUPPLY, "Still tokens on first round" );
        WETH.safeTransferFrom(msg.sender, TEAM_WALLET, PRICE_SECOND);
        requestId = safeMint();     
    }

    

    function safeMint() internal returns (bytes32 requestId)  {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with Link"
        );
        require(_tokenIdCounter.current() < MAX_SUPPLY, "Max Supply reached" );
        requestId = requestRandomness(keyHash, fee);
        requestToSender[requestId] = msg.sender;
        requestToTokenId[requestId] = _tokenIdCounter.current();
        _tokenIdCounter.increment();       
    }

    function canSaleEarly() public returns(bool){
        return DEXKIT.balanceOf(msg.sender) >= HOLDING_KIT || BITTOKEN.balanceOf(msg.sender) >= HOLDING_BITT;
    }

    // Tokens are generated when id exists based on the defined rarity
    function _baseURI() internal pure override returns (string memory) {
        return "https://coinleaguechampions.dexkit.com/api/";
    }

    function contractURI() public view returns (string memory) { 
        return "https://coinleaguechampions.dexkit.com/info";
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
        internal
        override
    {
        uint256 id = requestToTokenId[requestId];
        uint256 randomRarity = (randomNumber % 1000);
        uint256 index = 0;
        for(uint256 i = 0; i < 8; i++){
            if(randomRarity > accumulated_rarity[i] && randomRarity <= accumulated_rarity[i + 1]){
                index = i;
                break;
            }
        }
        rarity[id] = int256(index);
        attack[id] = uint256(keccak256(abi.encode(randomNumber, 1))) % 1000;
        defense[id] = uint256(keccak256(abi.encode(randomNumber, 2))) % 1000;
        run[id] = uint256(keccak256(abi.encode(randomNumber, 3))) % 1000;
        _safeMint(requestToSender[requestId], requestToTokenId[requestId]);
    }

    function withdrawLink() external onlyOwner{
        LINK.transfer(owner(), LINK.balanceOf(address(this)));
    }

    function withdrawETH() external payable onlyOwner{
       (bool sent, ) = owner().call{
            value: address(this).balance
        }("");
        require(sent, "Failed to send Ether");
    }


}