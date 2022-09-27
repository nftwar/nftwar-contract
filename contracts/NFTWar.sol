// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// this is attribute part (remember, this is just enum!)
enum Attr {
    TYPE,
    ATK,
    DEF
}

// temp type
enum ModuleType {
    W1, // not require
    W2, // not require
    BAG, // not require
    HEAD, // require
    LEG, // require
    FRAME // require
}

// base contract
contract Item is ERC721URIStorage, ERC721Enumerable, Ownable {
    mapping(uint256 => uint256[]) attribute;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function mint(address target, uint256[] memory _attributes) public returns (uint256) {
        uint256 tokenId = totalSupply() + 1; // tokenId start from 1, NOT ZERO!
        attribute[tokenId] = _attributes;
        _mint(target, tokenId);
        return tokenId;
    }

    function burn(uint256 _tokenId) public returns (bool) {
        _burn(_tokenId);
        return true;
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
       return super.tokenURI(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

contract Module is Item {
    constructor() Item("NFTWAR Module", "nMODULE") {}
}

contract Mech is Item {
    constructor() Item("NFTWAR Mech", "nMECH") {}
}

contract NFTWAR_V1 {
    Ranking ranking;
    Item mech;
    Item module;

    mapping(uint256 => uint256[]) public mechHas;
    mapping(address => uint256) public counter;

    function mint() public payable returns (uint256, uint256[] memory) {
        require(msg.value >= 10 ether * counter[msg.sender]);
        uint256[] memory attributes;
        uint256 tokenId = module.mint(msg.sender, attributes);
        counter[msg.sender] += 1;

        ranking.addRanking(msg.sender);
        
        return (tokenId, attributes);
    }

    // modules[] -> mech
    function build(uint256 _mechId, uint256[] memory _modules) public returns (uint256) {
        // init mech Attribute
        // 0x38 = 111000_(2)
        uint256[] memory mechAttribute = [uint256(0x38), 0, 0];
        // if rebuild -> destory mech first
        if(_mechId != 0) { destory(_mechId); }
        // get modules (transfer) & build it (mint)
        for(uint256 i = 0; i < _modules.length; i++) {
            module.transferFrom(msg.sender, address(this), _modules[i]);

            // is there better way?
            mechAttribute[Attr.ATK] += module.attribute[_modules[i]][Attr.ATK];
            mechAttribute[Attr.DEF] += module.attribute[_modules[i]][Attr.DEF];
            
            // Module
            mechAttribute[Attr.TYPE] ^= (0x1 << module.attribute[_modules[i]][Attr.TYPE]);
        }
        require(mechAttribute[Attr.TYPE] == 0);
        uint256 newMechId = mech.mint(msg.sender, mechAttribute);
        mechHas[newMechId] = _modules;
        return newMechId;
    }

    // mech -> modules[]
    function destory(uint256 _mechId) public returns (bool) {
        mech.transferFrom(msg.sender, address(this), _mechId);
        mech.burn(_mechId);
        for(uint256 i = 0; i < mechHas[_mechId].length; i++) {
            module.transferFrom(address(this), msg.sender, mechHas[_mechId][i]);
        }
        // is this needed?
        mechHas[_mechId] = [];
        return true;
    }

    // mech vs mech
    // select my mech -> auto searching foe -> return result & update ELO
    function battle(uint256 tokenId) public returns (bool) {
        require(mech.ownerOf(tokenId) == msg.sender);

        address foe = ranking.rankingList[ranking.ranking - 1];

        bool isWin = runBattle(tokenId, foe);

        if(isWin) {
            ranking.swapRanking(msg.sender, foe);
        }

        return (isWin);
    }

    function buildAndBattle(uint256 _mechId, uint256[] memory _modules) public returns (bool) {
        uint256 mechId;
        if(_mechId == 0) {
            mechId = build(_mechId, _modules);
        } else {
            mechId = _mechId;
        }
        uint256 isWin = battle(mechId);
        
        return (isWin);
    }

    function runBattle(uint256 _ATokenId, address _B) internal returns (bool win) {
        bool attackFirst = (0 == keccak256(keccak256(block.timestamp)) % 2);
        uint256 _BTokenId = mech.tokenOfOwnerByIndex(_B, 0);

        (, int256 AATK, int256 ADEF) = mechHas[_ATokenId];
        (, int256 BATK, int256 BDEF) = mechHas[_BTokenId];

    }
}

contract Ranking {
    mapping(address => uint256) public ranking;
    address[] public rankingList = [];
    uint256 public userCounter = 0;

    function swapRanking(address _A, address _B) public {
        require(ranking[_A] != 0);
        require(ranking[_B] != 0);

        // (rankingList[ranking[_A] - 1 ], rankingList[ranking[_B] - 1 ]) = (rankingList[ranking[_A] - 1 ], rankingList[ranking[_A] - 1 ]);
        address arr = rankingList[ranking[_A] - 1 ];
        rankingList[ranking[_A] - 1] = rankingList[ranking[_B] - 1];
        rankingList[ranking[_B] - 1] = arr;

        // (ranking[_A], ranking[_B]) = (ranking[_B], ranking[_A]);
        uint256 tmp = ranking[_A];
        ranking[_A] = ranking[_B];
        ranking[_B] = tmp;        
    }

    function addRanking(address _A) public {
        if(ranking[_A] == 0) {
            userCounter += 1;
            ranking[_A] = userCounter;
            rankingList.push(_A);       
        }
    }
}


/*
contract ELO {
    uint256 constant K = 20;
    mapping(address => uint256) rating;

    function getELO(address user) public view returns (uint256){
        if(rating[user]) return rating[user];
        return 1000;
    }

    function setELO(address user, uint point) public returns (uint256 point)  {
        rating[user] = point;
    }

    function findNearUser(uint256 rating) public view returns (address user) {

    }

    function updateELO(address _A, address _B, bool A_Wins) public {
        calcEloDiff(rating[_A], rating[_b]);

        if (A_Wins) {
            rating[_A] += K * ;
            rating[_B] -= K * ;
        } else {
            rating[_A] -= K * ;
            rating[_B] += K * ;
        }
    }

    function calcEloDiff(uint _pointA, uint _pointB) public view returns () {

    }
}
*/