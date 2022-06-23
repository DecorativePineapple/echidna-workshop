// SPDX-License-Identifier: BSD-4-Clause
pragma solidity ^0.8.1;

import "./ABDKMath64x64.sol";
//run it with /home/chr/Documents/echidna/echidna-test ./EchidnaTest.sol --contract Test --test-mode assertion --corpus-dir corpus --seq-len 1 --test-limit 10000000 


contract Test {
   int128 internal constant MIN_64x642 = -0x80000000000000000000000000000000;

   function abs(int128 x) public returns (int128) {
    return ABDKMath64x64.abs(x);
  }

function testAbs() public{
    //ensure that the absolute function of x doesn't overflow
   try this.abs(MIN_64x642){
        assert(false);
      } catch (bytes memory /*lowLevelData*/){
        assert(true);
      }
}


  function testAbs2(int128 xzgx) public{
    //ensure that the absolute function of x doesn't overflow
    if (xzgx == MIN_64x642){
      try this.abs(xzgx){
        assert(false);
      } catch (bytes memory /*lowLevelData*/){
        assert(true);
      }
    }
  }
}