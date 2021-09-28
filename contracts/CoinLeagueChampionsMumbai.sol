//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CoinsLeagueChampionsMumbai is ERC721, VRFConsumerBase, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 constant MAX_SUPPLY = 15000;
    uint256 constant PRICE = 0.001 ether;
    uint256 constant HOLDING_KIT = 10 * 10 ** 18;// 10 KIT
    uint256 constant HOLDING_BITT = 1000 * 10 ** 18;// 1000 BITT
    uint256 constant SALE_TIMESTAMP = 1632751640;
    uint256 constant SALE_EARLY_TIMESTAMP = 1632751640;
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    IERC20 internal immutable DEXKIT;
    IERC20 internal immutable BITTOKEN;
    // Mapping of rarity with token ID
    mapping(uint256 => uint256) public rarity;
    mapping(bytes32 => address) requestToSender;
    mapping(bytes32 => uint256) requestToTokenId;
                                    //%1, 5 %, 7.5%, 9%, 12.5%, 15%                               
    uint256 [] accumulated_rarity = [0, 10, 60, 135, 225, 350, 500, 700, 1000];
    //VRF Data       
    // Item	Value
    // LINK Token	0x326C977E6efc84E512bB9C30f76E30c160eD06FB
    // VRF Coordinator	0x8C7382F9D8f56b33781fE506E897a4F1e2d17255
    // Key Hash	0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4
    // Fee	0.0001 LINK

    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyhash, address _kit, address _bittoken)
    ERC721("CoinsLeagueChampions", "Champions")
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

    function safeMint() public payable returns (bytes32 requestId)  {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with Link"
        );
        if(canSaleEarly()){
            require(block.timestamp >= SALE_EARLY_TIMESTAMP );
        }else{
            require(block.timestamp >= SALE_TIMESTAMP );
        }

        require(_tokenIdCounter.current() <= MAX_SUPPLY, "Max Supply reached" );
        require(msg.value == PRICE, "Not enough amount" );
        requestId = requestRandomness(keyHash, fee);
        requestToSender[requestId] = msg.sender;
        requestToTokenId[requestId] = _tokenIdCounter.current();
        _tokenIdCounter.increment();       
        return requestId;   
    }

    function canSaleEarly() public returns(bool){
        return DEXKIT.balanceOf(msg.sender) >= HOLDING_KIT || BITTOKEN.balanceOf(msg.sender) >= HOLDING_BITT;
    }

    function price() external pure returns (uint256){
        return PRICE;
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
        for(uint256 i = 0; i < accumulated_rarity.length; i++){
            if(accumulated_rarity[i] >= randomRarity && accumulated_rarity[i] < randomRarity){
                index = i;
                break;
            }
        }
        rarity[id] = index + 1;
        _safeMint(requestToSender[requestId], requestToTokenId[requestId]);
    }

    function withdrawLink() external onlyOwner(){
        LINK.transfer(owner(), LINK.balanceOf(address(this)));
    }

    function withdrawETH() external payable onlyOwner(){
       (bool sent, ) = owner().call{
            value: address(this).balance
        }("");
        require(sent, "Failed to send Ether");
    }


}