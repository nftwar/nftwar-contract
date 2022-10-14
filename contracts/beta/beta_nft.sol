pragma solidity ^0.8.0;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Powered by Basis Cash
// revert multiple transaction (DoS) on same block
// only one tx for one EoA on one block
contract ContractGuard {
    mapping(uint256 => mapping(address => bool)) private _status;

    function checkSameOriginReentranted() internal view returns (bool) {
        return _status[block.number][tx.origin];
    }

    function checkSameSenderReentranted() internal view returns (bool) {
        return _status[block.number][msg.sender];
    }

    modifier onlyOneBlock() {
        require(
            !checkSameOriginReentranted(),
            'ContractGuard: one block, one function'
        );
        require(
            !checkSameSenderReentranted(),
            'ContractGuard: one block, one function'
        );

        _;

        _status[block.number][tx.origin] = true;
        _status[block.number][msg.sender] = true;
    }
}

contract NFTWARbetaPARTS is ERC721A, Ownable {
    string private _baseURIextended;
    mapping(uint256 => uint256) public ATK;
    mapping(uint256 => uint256) public DEF;

    // contruct contract
    constructor(string memory URI) ERC721A("NFTWAR Beta Parts", "NbPARTS") {
        setBaseURI(URI);
    }

    // LGTM
    function setATK(uint256 offset, uint256[] memory param) public onlyOwner() {
        for(uint256 i = 0; i < param.length; i++) {
            ATK[offset + i] = param[i];
        }
    }

    // LGTM
    function setDEF(uint256 offset, uint256[] memory param) public onlyOwner() {
        for(uint256 i = 0; i < param.length; i++) {
            DEF[offset + i] = param[i];
        }
    }

    // LGTM
    function getATK(uint256 toeknId) public view returns (uint256) {
        return ATK[toeknId];
    }


    // LGTM
    function getDEF(uint256 toeknId) public view returns (uint256) {
        return DEF[toeknId];
    }

    // LGTM
    function setBaseURI(string memory baseURI_) public  onlyOwner() {
        _baseURIextended = baseURI_;
    }

    // LGTM
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    // On Beta Mint is infinte
    function mint(uint256 n) public payable {
        _safeMint(msg.sender, n);
    }
}
