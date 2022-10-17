pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./beta_nft.sol";

contract NFTWARbetaBattle is Ownable, ContractGuard {
    NFTWARbetaPARTS public PartsContract;
    mapping(address => uint256[]) public latestUnit;

    constructor(NFTWARbetaPARTS parts) {
        PartsContract =  parts;
    }
    
    event Battle(uint256 userDEF, uint256 userATK, uint256 enemyDEF, uint256 enemyATK);
    event Result(bool isWin);

    function battle(uint256[] memory tokenIds, uint256[] memory enemeyTokenIds) external returns (bool isWin) {
        uint256 i = 0;
        uint256 userDEF = 0;
        uint256 userATK = 0;
        uint256 enemyDEF = 0;
        uint256 enemyATK = 0;

        latestUnit[msg.sender] = tokenIds;

        for(i = 0; i < tokenIds.length; i++ ) {
            require(msg.sender == PartsContract.ownerOf(tokenIds[i]), "sender is not owner of token");
            userDEF += PartsContract.getDEF(tokenIds[i]);
            userATK += PartsContract.getATK(tokenIds[i]);
        }

        for(i = 0; i < enemeyTokenIds.length; i++ ) {
            enemyDEF += PartsContract.getDEF(enemeyTokenIds[i]);
            enemyATK += PartsContract.getATK(enemeyTokenIds[i]);
        }

        emit Battle(userDEF, userATK, enemyDEF, enemyATK);

        if(userATK == 0 && enemyATK == 0){
            emit Result(true);
            return true;
        }

        // uint이기때문에 userDEF > enemyATK 라면 프로그램이 터짐
        // 선공 후공 랜덤
        if (block.timestamp % 2 == 0) {
            // 후공
            while(true) {
                if(enemyATK >= userDEF){
                    emit Result(false);
                    return false;
                }
                userDEF -= enemyATK;

                if(userATK >= enemyDEF){
                    emit Result(true);
                    return true;
                }
                enemyDEF -= userATK;
            }

        } else {
            // 선공
            while(true) {
                if(userATK >= enemyDEF){
                    emit Result(true);
                    return true;
                }
                enemyDEF -= userATK;

                if(enemyATK >= userDEF){
                    emit Result(false);
                    return false;
                }
                userDEF -= enemyATK;
            }
        }
    }

    function getLatestUnit(address _user) public view returns (uint256[] memory){
        return latestUnit[_user];
    }
}
