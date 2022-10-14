pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./beta_nft.sol";

contract NFTWARbetaBattle is Ownable, ContractGuard {
    NFTWARbetaPARTS public PartsContract;


    constructor(NFTWARbetaPARTS parts) {
        PartsContract =  parts;
    }

    function battle(uint256[] memory tokenIds, uint256[] memory enemeyTokenIds) external returns (bool isWin) {
        uint256 i = 0;
        uint256 userDEF = 0;
        uint256 userATK = 0;
        uint256 enemyDEF = 0;
        uint256 enemyATK = 0;

        for(i = 0; i < tokenIds.length; i++ ) {
            require(msg.sender == PartsContract.ownerOf(tokenIds[i]));
            userDEF += PartsContract.getDEF(tokenIds[i]);
            userATK += PartsContract.getATK(tokenIds[i]);
        }

        for(i = 0; i < enemeyTokenIds.length; i++ ) {
            enemyDEF += PartsContract.getDEF(enemeyTokenIds[i]);
            enemyATK += PartsContract.getATK(enemeyTokenIds[i]);
        }

        // 선공 후공 그냥 막 잡는다
        if (block.timestamp % 2 == 0) {
            while(userDEF > 0 && enemyDEF > 0) {
                userDEF -= enemyATK;
                enemyDEF -= userATK;
            }

        } else {
            while(userDEF > 0 && enemyDEF > 0) {
                enemyDEF -= userATK;
                userDEF -= enemyATK;
            }
        }
        if(userDEF > 0) {
            return (true);
        } else {
            return (false);
        }
    }
}
