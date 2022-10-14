pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./beta_nft.sol";

contract NFTWARbetaBattle is Ownable, ContractGuard {
    NFTWARbetaPARTS public PartsContract;
    mapping(address => uint256[]) public latestUnit;

    constructor(NFTWARbetaPARTS parts) {
        PartsContract =  parts;
    }
    
    event Result(bool isWin);

    function battle(uint256[] memory tokenIds, uint256[] memory enemeyTokenIds) external returns (bool isWin) {
        uint256 i = 0;
        uint256 userDEF = 0;
        uint256 userATK = 0;
        uint256 enemyDEF = 0;
        uint256 enemyATK = 0;

        latestUnit[msg.sender] = tokenIds;

        for(i = 0; i < tokenIds.length; i++ ) {
            require(msg.sender == PartsContract.ownerOf(tokenIds[i]));
            userDEF += PartsContract.getDEF(tokenIds[i]);
            userATK += PartsContract.getATK(tokenIds[i]);
        }

        for(i = 0; i < enemeyTokenIds.length; i++ ) {
            enemyDEF += PartsContract.getDEF(enemeyTokenIds[i]);
            enemyATK += PartsContract.getATK(enemeyTokenIds[i]);
        }

        // 유저 방어력이 상대 공격보다 더 높을 시 
        if(userDEF >= enemyATK){
            // 유저 공격이 상대 방어보다 높으면 이김 (한대)
            if(userATK >= enemyDEF){
                emit Result(true);
                return true;
            }
            // 유저 공격이 상대 방어보다 낮지만, 유저 공격이 더 센 경우 (여러대 선승)
            else if(userDEF - enemyATK >= enemyDEF - userATK){
                emit Result(true);
                return true;
            }
            // 유저가 먼저 쓰러짐 (여러방 패)
            return false;
        }
        else{// 유저 방어력이 상대 공격보다 낮을 시
            // 유저 공격이 상대 방어보다 더 높음 - 서로 한대 - 유저가 이김
            if(userATK >= enemyDEF){
                emit Result(true);
                return true;
            }

            // 한대맞고 죽음
            emit Result(false);
            return false;
        }

        // uint이기때문에 userDEF > enemyATK 라면 프로그램이 터짐
        // // 선공 후공 그냥 막 잡는다
        // if (block.timestamp % 2 == 0) {
        //     while(userDEF > 0 && enemyDEF > 0) {
        //         userDEF -= enemyATK;
        //         enemyDEF -= userATK;
        //     }

        // } else {
        //     while(userDEF > 0 && enemyDEF > 0) {
        //         enemyDEF -= userATK;
        //         userDEF -= enemyATK;
        //     }
        // }
        // if(userDEF > 0) {
        //     return (true);
        // } else {
        //     return (false);
        // }
    }
}
