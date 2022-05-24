// SPDX-License-Identifier: BSD-4-Clause
pragma solidity ^0.8.1;

import "./ABDKMath64x64.sol";

contract Test {
   int128 internal zero = ABDKMath64x64.fromInt(0);
   int128 internal one = ABDKMath64x64.fromInt(1);

   //add the max and min in order to try and catch the reverts
   int128 internal constant MIN_64x64 = -0x80000000000000000000000000000000;
   int128 internal constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

   event Value2(string, uint256);
   event Value(string, int64);
   event Value3(string, int128);
   event Assertion(string, int128);

   function debug(string calldata x, int128 y) public {
     emit Value(x, ABDKMath64x64.toInt(y));
   }
 
   function add(int128 x, int128 y) public returns (int128) {
     return ABDKMath64x64.add(x, y);
   }

   function mul(int128 x, int128 y) public returns (int128) {
     return ABDKMath64x64.mul(x, y);
   }

   function div(int128 x, int128 y) public returns (int128) {
     return ABDKMath64x64.div(x, y);
   }

   function fromInt(int256 x) public returns (int128) {
     return ABDKMath64x64.fromInt(x);
   }

   function pow(int128 x, uint256 y) public returns (int128) {
     return ABDKMath64x64.pow(x, y);
   }

   function neg(int128 x) public returns (int128) {
     return ABDKMath64x64.neg(x);
   }

   function inv(int128 x) public returns (int128) {
     return ABDKMath64x64.inv(x);
   }

   function sqrt(int128 x) public returns (int128) {
     return ABDKMath64x64.sqrt(x);
   }

  //add in our functions in order to test if library functions revert
  //needed because in this point in solidity, try can only be used with external function calls(must include 'this' keyword)

  function exp(int128 x) public returns (int128) {
    return ABDKMath64x64.exp(x);
  }
  
  function divi(int256 x, int256 y) public returns (int128) {
     return ABDKMath64x64.divi(x, y);
  }

  function abs(int128 x) public returns (int128) {
    return ABDKMath64x64.abs(x);
  }

  function sub(int128 x, int128 y) public returns (int128) {
    return ABDKMath64x64.sub(x,y);
  }

  function log_2 (int128 x) public returns (int128){
    return ABDKMath64x64.log_2(x);
  }

  function exp_2 (int128 x) public returns (int128) {  
    return ABDKMath64x64.exp_2(x);
  }

 function fromUInt (uint256 x) public returns (int128) {
   return ABDKMath64x64.fromUInt(x);
 }

  //helper functions

  /**
   * a partial implementation isclose function
   * This is a helper function to calculate if the two values are close
   *@param a signed 64.64 fixed point number
   *@param b signed 64.64 fixed point number
  */

  /*
    inspired by the math.isclose() python function -> https://docs.python.org/3/library/math.html#math.isclose
    abs(a-b) <= max(rel_tol * max(abs(a), abs(b)), abs_tol)
    the problem is that it uses multiply functionality in order to caclulate the 
    relative tolerance of 2 numbers. So, we cannot use it in order to test the mul() and div() properties:). 
  */
  function isClose(int128 a, int128 b, int256 abs_tol) public returns(bool){
    //absolute difference
    int128 diff = ABDKMath64x64.sub(a, b);
    int128 absDiff = ABDKMath64x64.abs(diff);

    //convert abs_tol to 64.64 int128 
    int128 abs_tol2 = ABDKMath64x64.fromInt(abs_tol);

    return (absDiff <= abs_tol2);
  }

/**
   * a second implementation of isclose() functionality
   * Inspired by gustavo's discord post
   * This is a helper function to calculate if the two values are close
   * Due to rounding, the first condition (a <= b ) is that it must be less than the desired result
   * the rel
   *@param a signed 64.64 fixed point number
   *@param b signed 64.64 fixed point number, representing the desired result
   *@param rel_tol int256  number, representing the relative tolerance. So if rel_tol = 0.3 -> relevant tolerance is 0.30 
   *@
  */
  function isClose2(int128 a, int128 b, int256 rel_tol) public returns(bool){
    //convert the relative tolerance from int256 to int128
    int128 rel_tol2 = fromInt(rel_tol);

    return (a <= b && a >= sub(b, div(b, rel_tol2)));
    }


  /**
   * This is a helper function to calculate the max number -> needed for avg
   *@param x signed 64.64 fixed point number
   *@param y signed 64.64 fixed point number
   *@return signed 64.64-bit fixed point number
   * 
  */
  function maximum(int128 x, int128 y) public returns(int128){
   int128 diffResult = ABDKMath64x64.sub(x, y);
   if (diffResult > zero){
     return (x);
   } else {
     return (y);
   }
  }

  /**
   * This is a helper function to calculate the nimumum number -> needed for avg
   *@param x signed 64.64 fixed point number
   *@param y signed 64.64 fixed point number
   *@return signed 64.64-bit fixed point number
   * 
  */
 function minimum(int128 x, int128 y) public  returns(int128) {
   int128 diffResult = ABDKMath64x64.sub(x, y);
   if (diffResult > zero){
     return (y);
   } else {
     return (x);
   }
}

  //tests
   function testAdd(int128 x, int128 y, int128 z) public {
     //ensure that the sum doesn't overflow
     //must be changed with the use of sub() instead of add(), because if the add() has a vulnerability or the code changed, the code should work
     int256 result = int256(x) + y;
     if ((result >= MIN_64x64) && (result <= MAX_64x64)){
      try this.add(x, y){
        assert (true);
      } catch ( bytes memory /*lowLevelData*/){
        assert(false);
      }
    }

     //x + y = y + x
     assert(ABDKMath64x64.add(x,y) == ABDKMath64x64.add(y,x));

     //(x + z) + y = z + (x + y) = x + (z + y) 
     assert(add((ABDKMath64x64.add(x,z)),y) == add((ABDKMath64x64.add(x,y)),z));
     assert(add((ABDKMath64x64.add(z,y)), x) == add((ABDKMath64x64.add(x,z)),y));

     //if x = 0 -> x + y = x
     if (x == zero){
       assert(ABDKMath64x64.add(x,y) == y);  
     } else if (y == zero){
       assert(ABDKMath64x64.add(x,y) == x);  
     }
   }

  /**
   * Test the negative value functionality
   *@param x signed 64.64 fixed point number
   */
  function testNeg(int128 x) public{
    //ensure that neg doesn't overflow
    if (x == MIN_64x64){
      try this.neg(x){
        assert(false);
      } catch (bytes memory /*lowLevelData*/){
        assert(true);
      }
    } 
    
    //negative of a non negative is a non-positive
    if (x >= 0 ){
      assert(neg(x) <= zero );
    } else { //negative of a negative is a positive
      assert(neg(x) > zero); 
    }

    //0 - x == neg(x)
    assert(neg(x) == sub(zero,x));
  }

   /**
   * Test the absolute value functionality
   *@param x signed 64.64 fixed point number
   *@param y signed 64.64 fixed point number
   */
  function testAbs(int128 x, int128 y) public{
    //ensure that the absolute function of x doesn't overflow
    if (x == MIN_64x64){
      try this.abs(x){
        assert(false);
      } catch (bytes memory /*lowLevelData*/){
        assert(true);
      }
    } 

    int128 aAndB = ABDKMath64x64.add(x, y);
    int128 absAAndB = ABDKMath64x64.abs(aAndB);

    int128 absX = ABDKMath64x64.abs(x);
    int128 absY = ABDKMath64x64.abs(y);

    //the absolute value must be > 0
    assert((ABDKMath64x64.abs(x) >= zero) && (ABDKMath64x64.abs(y) >= zero));

    //if x=0 => abs(x) = 0 
    if (x == zero){
      assert(ABDKMath64x64.abs(x) == zero);
    }

    //|x+y| <= |x|+|y|
    assert(ABDKMath64x64.sub(absAAndB, ABDKMath64x64.add(absX, absY)) <= zero);

    //the absolute value of the opposite number must be the same
    int128 x2 = ABDKMath64x64.neg(x);
    assert(absX == ABDKMath64x64.abs(x2));

    if (ABDKMath64x64.sub(absX, y) <= zero){ //|a| <= b <=> -b <= a <= b
      assert((ABDKMath64x64.add(x, y) >= zero) &&  (ABDKMath64x64.sub(x,y) <= zero));
    } else{ // |a| >= b <=> a <= -b or a >= b
      assert((ABDKMath64x64.add(x, y) <= zero) ||  (ABDKMath64x64.sub(x,y) >= zero));
    }
  }


  /**
   * Test the sub function
   *@param x signed 64.64 fixed point number
   *@param y signed 64.64 fixed point number
   */
  function testSub(int128 x , int128 y) public{
    //try to catch overflow in the sub function
    int256 result = int256(x) - y;
    if (result < MIN_64x64 || result > MAX_64x64){
      try this.sub(x, y){
        assert (false);
      } catch ( bytes memory /*lowLevelData*/){
        assert(true);
      }
    }

    //if y = 0 -> x - y = x
    if (y == zero){
      assert(ABDKMath64x64.sub(x, y) == x);
    }

    //if x = 0 -> x - y = neg(y)
    if (x == zero){
      assert(ABDKMath64x64.sub(x,y) == neg(y));
    }

    //x - y = -(y-x) = neg(y-x)
    int128 result1 = ABDKMath64x64.sub(x,y);
    int128 result2 = ABDKMath64x64.sub(y,x);

    assert(result1 == neg(result2));
  }


  /**
   * Test the inv function
   *@param x signed 64.64 fixed point number
   *@param y signed 64.64 fixed point number
   /*

   /*
   * tried to test more properties such as inv(inv(x)) == x
   * but they fail, due to the rounding thing!
   * couldn't find a reliable precision loss in order to check all those properties
    
   (for example : if x = 2 -> 1 / x = 0.5 rounded to zero and then 1/0 -> error
   * int128 inv1 = ABDKMath64x64.inv(x);

    *events
    *emit Value("value of x", int64(ABDKMath64x64.toInt(x)));
    *emit Value("value of inv x", int64(ABDKMath64x64.toInt(inv1)));
    *assert(ABDKMath64x64.inv(inv1) == x);
   */
  function testInv(int128 x, int128 y) public{
    //ensure that it reverts when x is zero
    if (x == zero){
      try this.inv(x){
        assert (false);
      } catch (bytes memory /*lowLevelData*/){
        assert(true);
      }
    }

    //1 / x = div(1,x);
    int128 invX = ABDKMath64x64.inv(x);
    int128 divInvX = ABDKMath64x64.div(one, x);

    assert(invX == divInvX);
    
    //Created invariants when comparing the inv(x) and the x functions
    //graph at https://www.wolframalpha.com/input?i=plot+1%2Fx+and+x
    if (sub(x, zero) >= zero){ //branch when x >= 0
      assert (sub(invX, zero) >= 0); //when x >= 0 inv(x) >= 0
      if (sub(x, one) <= zero){ //branch when x >= 0 and x <= 1
        assert(sub(invX, x) >= zero);
      } else { //branch when x >= 0 and x > 1
        assert(sub(invX, x) <= zero);
      }
    } else { //branch when x < 0
      assert (sub(invX, zero) <= 0);
      if (add(x, one) <= zero) { //branch when x < 0 and x <= -1
        assert(sub(invX, x) >= zero);
      } else { //branch when x < 0 and x > -1
        assert(sub(invX, x) <= zero);
      }
    }

    //created invariants for x and y
    //1/x is a decreasing function when x * y > 0
    if (sub(mul(x, y),zero) >= zero){
      if (sub(x, y) >= zero){
        assert(inv(x) <= inv(y));
      }
    }
    
    //test the isClose and isClose2 functionality
    //change -> correct is 2
    assert(isClose2(mul(x, inv(x)), one, 1));

    //assert(isClose(ABDKMath64x64.inv(inv1), x, 2 ));
  }


  /**
   * Test the mul functionality
   *@param x signed 64.64 fixed point number
   *@param y signed 64.64 fixed point number
   *@param z signed 64.64 fixed point number
   */
  function testMul(int128 x, int128 y, int128 z) public{
    //should check the precondition :D

    //if x and y have the same sign, the mul is positive, else its negative
    //first check if x * y > 0, x and y must be both positive or negative

    //zero included because if x = -1, y = -1 the answer is rounded to zero due to the 64.64 fraction
    if ((ABDKMath64x64.sub(x, zero) > 0 && ABDKMath64x64.sub(y, zero) > 0) || (ABDKMath64x64.sub(x, zero) < 0 && ABDKMath64x64.sub(y, zero) < 0)){
      //events left while testing :D
      //emit Value("value of x is", ABDKMath64x64.toInt(x));
      //emit Value("value of y is", ABDKMath64x64.toInt(y));
      //emit Value("value of x * y is", ABDKMath64x64.toInt(ABDKMath64x64.mul(x,y)));
      assert(ABDKMath64x64.mul(x, y) >= zero);
    } else{
      assert(ABDKMath64x64.mul(x, y) <= zero);
    }

    //x * 1 = x
    assert(ABDKMath64x64.mul(x, one) == x);

    //x * y = y * x
    assert(ABDKMath64x64.mul(x, y) == ABDKMath64x64.mul(y, x));

    // check if x or y 0 then y * x = 0
    if (x == zero || y == zero){
      assert(ABDKMath64x64.mul(x,y) == zero);
    }


    //Multiplication by a positive number preserves the order
    //if x > 0; b > c then ab > ac
    //due to rounding, we can include also ab >= ac
    if (sub(x, zero) > zero){
      if (sub(y, z) >= zero){
        assert(sub(mul(x, y), mul(x, z)) >= zero);
      }
    } else { // if x > 0; b > c then ab < ac
      if (sub(y, z) >= zero){
        assert(sub(mul(x, y), mul(x, z)) <= zero);
      }
    }

    //a * (1 /a) = 1
    //the Equality is not valid, because if x = 3; 1/x = 0.3 -> 0
    //we can assert that is less or equal than, because we know the desired result!
    assert(ABDKMath64x64.mul(x, ABDKMath64x64.inv(x)) <= one);


    //a * (-1) = -a
    assert(ABDKMath64x64.neg(x) == ABDKMath64x64.mul(x, ABDKMath64x64.fromInt(-1)));

    /*
    //some tests I created in order to try to find some consistency into comparing this (x * y) * z = x * (y * z) = y * (x * z) property of multiplication

    //Unfortunately, they didn't work :(

    //(x * y) * z = x * (y * z) = y * (x * z)
    //This one == cannot be tested due to precision loss, so the order the numbers multiplied matter

    //different multiplications
    int128 mulxy = ABDKMath64x64.mul(x,y);
    int128 mulyz = ABDKMath64x64.mul(z,y);
    int128 mulxz = ABDKMath64x64.mul(x,z);

    //we can find the rounded integer result of multiplication of the 3 numbers
    int64 integerNumber =  ABDKMath64x64.toInt(x) * ABDKMath64x64.toInt(y) * ABDKMath64x64.toInt(z);

    int128 maxyx = maximum(abs(x), abs(y));
    int128 maxyz = maximum(abs(y), abs(z));


    //create three assertions
    //the absolute number of the difference of the rounded integer conv
    //the idea is : |integerNumber - z * xy| <= maximum of the abs(x,y,x)
    //after the conversion it looks like this:
    assert((sub(abs(sub(mul(z, mulxy), ABDKMath64x64.fromInt(integerNumber))),maximum(abs(maxyx), abs(maxyz)))) <= zero);
    */

  }

/**
   * Test the sqrt functionality
   *@param x signed 64.64 fixed point number
   *@param y signed 64.64 fixed point number 
*/
  function testSqrt(int128 x, int128 y) public{
    //ensure that x is a nonNegative number (x>=0)
    if (x < zero){
      try this.sqrt(x){
        assert (false);
      } catch (bytes memory /*lowLevelData*/){
        assert(true);
      }
    }

/*
    //one property is : sqrt(x ^ 2) = abs(x)
    //for some reason I cannot make it work :(  
    //events for int64
    emit Value("x is : ", ABDKMath64x64.toInt((x)));
    emit Value("sqrt(x) is", ABDKMath64x64.toInt(sqrt(x)));
    emit Value("pow is" , ABDKMath64x64.toInt(ABDKMath64x64.pow(x,2)));
    emit Value("sqrt of pow is", ABDKMath64x64.toInt((ABDKMath64x64.sqrt(ABDKMath64x64.pow(x,2)))));
    emit Value("abs is", ABDKMath64x64.toInt((ABDKMath64x64.abs(x))));

    
    //events for int128 -> 64.64
    emit Value3("x is : ", x);
    emit Value3("sqrt(x) is", sqrt(x));
    emit Value3("pow is" , ABDKMath64x64.pow(x,2));
    emit Value3("sqrt of pow is", ABDKMath64x64.sqrt(ABDKMath64x64.pow(x,2)));
    emit Value3("abs is", ABDKMath64x64.abs(x));

    assert(ABDKMath64x64.sqrt(ABDKMath64x64.pow(x,2)) == ABDKMath64x64.abs(x));
*/

    //calculate the sqrt of the x and store in the sqrtX variable
    int128 sqrtX = ABDKMath64x64.sqrt(x);

    //monotony of sqrt function
    //sqrt is an increasing function
    if (x == y){
      assert(ABDKMath64x64.sqrt(x) == ABDKMath64x64.sqrt(y));
    } else if (sub(x, y) <= zero){
      assert(ABDKMath64x64.sqrt(x) <= ABDKMath64x64.sqrt(y));
    } else {
      assert(ABDKMath64x64.exp_2(x) >= ABDKMath64x64.exp_2(y));
    }


    //if x = 0 -> sqrt(x) = 0
    if (x == 0){
      assert(sqrtX == 0);
    }
    
    //always the sqrt must be >= 0
    int128 difference1 = ABDKMath64x64.sub(x, ABDKMath64x64.fromInt(0));
    assert(difference1 >= ABDKMath64x64.fromInt(0));

    //always the sqrt must be lower or equal the original number when the number is > 1 and
    //sqrt(x) > x when the for 0 < x < 1
    //https://www.wolframalpha.com/input?i=graph+x+and+sqrt%28x%29 
    int128 difference = ABDKMath64x64.sub(x,sqrtX );
    if (x >= one){
      //events for the check! 
      emit Value("X is ", int64(ABDKMath64x64.toInt(x)));
      emit Value("Difference is", int64(difference));

      assert(difference >= zero);
    } else {
      assert(difference <= zero);
    }
  }

/**
   * Test the average(ABDKMath64x64.avg(int128 x, int128 y)) functionality
   *@param x signed 64.64 fixed point number
   *@param y signed 64.64 fixed point number
   * 
*/
  function testAvg(int128 x, int128 y) public {
    int128 avgResult = ABDKMath64x64.avg(x,y);

    //if x == y the average number is the same
    if (x == y){
      assert(avgResult == x);
    }

    //avg lies between minimum and maximum
    int128 maxNumber = maximum(x, y);
    int128 minNumber = minimum(x, y);

    //lower than the max
    assert(ABDKMath64x64.sub(avgResult, maxNumber) <= zero);
    
    //higher thatn the minimum
    assert(ABDKMath64x64.sub(avgResult, minNumber) >= zero);

  }

/**
   * Test the pow functionality of the library
   * @param x signed 64.64-bit fixed point number
   * @param y uint256 value
   * @param z uint256 value -> z as an argument to test more exponential properites
*/
   function testPow(int128 x, uint256 y, uint256 z) public{
     int128 xToTheY = ABDKMath64x64.pow(x,y);
     int128 xToTheZ = ABDKMath64x64.pow(x,z);


    //x ^ 0 = 1
    if (y == 0){
      assert (xToTheY == one);
    }

     //x ^ 1 = x
     if (y == 1){
       assert(x == xToTheY);
     }

    /*
    tried different math properties that include more than one multiplications
    probably failed due to rounding in the multiplication
    // (x ^ y) × (x ^ z) = x ^ (y + z)
    int128 xToTheYAndZ = ABDKMath64x64.pow(x, z+y);
    //events
    //emit Value("x is", int64(ABDKMath64x64.toInt(x)));
    //emit Value2("y is", y);
    //emit Value2("z is", z);
    //assert (xToTheYAndZ == ABDKMath64x64.mul(xToTheY, xToTheZ));

    // (x ^ y) / (x ^ z) = x ^ (y - z)
    int128 xToTheYMinusZ = ABDKMath64x64.pow(x, y-z);
    //assert (xToTheYMinusZ == ABDKMath64x64.div(xToTheY, xToTheZ));

    //negative exponent property
    */
}

/**
   * Test the sqrt functionality
   *@param x signed 64.64 fixed point number
   *@param y signed 64.64 fixed point number
*/
function testGavg(int128 x, int128 y) public{
  int128 gavgXY = ABDKMath64x64.gavg(x, y);
  int128 gavgYX = ABDKMath64x64.gavg(y, x);

  // gavgXY = gavgYX
  assert(gavgXY == gavgYX);


  //if x = 0 or y = 0 -> gavg = 0
  if ((x == zero) || (y == 0)){
    require(gavgXY == 0);
  }

/*
  tried different math properties that include more than one multiplications
  probably failed due to rounding happening in the multiplication
  int128 gavgX1 = ABDKMath64x64.gavg(x, one);
  int128 gavgY1 = ABDKMath64x64.gavg(y, one);

  //assert(gavgXY == ABDKMath64x64.mulu(gavgX1, gavgY1));

  int128 sqrtX = ABDKMath64x64.sqrt(x);
  int128 sqrtY = ABDKMath64x64.sqrt(y);
  //assert(ABDKMath64x64.mul(sqrtX, sqrtY) == gavgXY);


  //sqrt(X) = sqrt(x * 1)
  assert(gavgX1 == sqrtX);

  //sqrt(Y) = sqrt(Y * 1)
  assert(gavgY1 == sqrtY);
 */ 
}


/**
   * Test the log functionality
   *@param x signed 64.64 fixed point number
   *@param y signed 64.64 fixed point number
*/
function testLog(int128 x, int128 y) public{
  //check if it revers when x non positive (x <= 0)
   if (x <= zero){
    try this.log_2(x){
      assert (false);
    } catch (bytes memory /*lowLevelData*/){
      assert(true);
    }
  }

  int128 logX = ABDKMath64x64.log_2(x);
  int128 logY = ABDKMath64x64.log_2(y);

  //monotony of log
  //If  a > 1  then the logarithmic functions are monotone increasing functions.
  //If  0 < a < 1  then the logarithmic functions are monotone decreasing functions.
  //so log2(x) is an increasing function
  if (x == y){
    assert(logX == logY);
  } else if (ABDKMath64x64.sub(x,y) >= zero){
    assert(logX >= logY);
  } else {
    assert(logX <= logY);
  }

  //graph at https://www.rapidtables.com/math/algebra/logarithm/log-graph.png
  //probably not a different property, is the monotony comparison against log2(1) = 0 
  if (ABDKMath64x64.sub(x, one) > zero){
    assert (logX >= 0);
  } else if (x == one){
    assert(logX == 0);
  } else {
    assert(logX <= 0); 
  }

  //multiply properties not added because mul produces error, due to fraction rounding 
}

/**
   * Test the div functionality
   * @param x signed 256-bit integer number
   * @param y signed 256-bit integer number
*/
function testDiv(int128 x, int128 y) public{
  //try to catch division with zero
  if (y == zero){
    try this.div(x, y){
      assert (false);
    } catch (bytes memory /*lowLevelData*/){
      assert(true);
    }
  }

  //if y == one, x/y = 1
  if (y == one){
    assert(ABDKMath64x64.div(x, y) == x);
  }
  
  //if x == 0 -> x/y = 0
  if (x == zero){
    assert(ABDKMath64x64.div(x, y) == zero);
  }

  //if x == y, x/y == one
  if (x == y){
    assert(ABDKMath64x64.div(x, y) == one);
  }

  //if x == -y -> x / y == neg(one)
  if (x == ABDKMath64x64.neg(y)){
    assert(ABDKMath64x64.div(x, y) == ABDKMath64x64.neg(one));
  }
}


/**
   * Test the divi functionality
   * @param x signed 256-bit integer number
   * @param y signed 256-bit integer number
*/
function testDivi(int256 x, int256 y) public{
  int128 x2 = ABDKMath64x64.fromInt(x);
  int128 y2 = ABDKMath64x64.fromInt(y);

  //try to catch division with zero
  if (y == 0){
    try this.divi(x, y){
      assert (false);
    } catch (bytes memory /*lowLevelData*/){
      assert(true);
    }
  }
  
  //divi and div must produce the same result because both are rounded towards zero
  require(ABDKMath64x64.divi(x, y) == ABDKMath64x64.div(x2, y2));

  //divu and divi shall produce the same results
  //uint256 maxU = 115792089237316195423570985008687907853269984665640564039457584007913129639935 ;
  if ((x > 0) && (y > 0)){
    uint256 ux = uint256(x);
    uint256 uy = uint256(y);
    require(ABDKMath64x64.divi(x, y) == ABDKMath64x64.divu(ux, uy));
  } 
}

/**
   * Test the exp_2 functionality
   * @param x signed 256-bit integer number
   * @param y signed 256-bit integer number
*/
function testExp2(int128 x, int128 y) public{
  //ensure that it reverts when x >= 0x400000000000000000
  if (x >= 0x400000000000000000){
    try this.exp_2(x){
      assert (false);
    } catch (bytes memory /*lowLevelData*/){
      assert(true);
    }
  }

  //2 ^ x >= 0;
  assert(ABDKMath64x64.exp_2(x) >= zero);

  //2 ^ x == e ^ x when x = 0
  //https://www.wolframalpha.com/input?i=plot+e%5Ex+and+2+%5E+x
  if (x == zero){
    assert(ABDKMath64x64.exp(x) == ABDKMath64x64.exp_2(x));
  } else if (x > zero) {
    assert(ABDKMath64x64.exp(x) >= ABDKMath64x64.exp_2(x));
  } else {
    assert(ABDKMath64x64.exp(x) <= ABDKMath64x64.exp_2(x));
  }

  //exp_2 is an increasing function
  if (x == y){
    assert(ABDKMath64x64.exp_2(x) == ABDKMath64x64.exp_2(y));
  } else if (ABDKMath64x64.sub(x,y) >= zero){
    assert(ABDKMath64x64.exp_2(x) >= ABDKMath64x64.exp_2(y));
  } else {
    assert(ABDKMath64x64.exp_2(x) <= ABDKMath64x64.exp_2(y));
  }
}

/**
   * Test the exp functionality
   * @param x signed 256-bit integer number
  * @param x signed 256-bit integer number
*/
function testExp(int128 x, int128 y) public{
  //ensure that it reverts when x >= 0x400000000000000000
  if (x >= 0x400000000000000000){
    try this.exp(x){
      assert (false);
    } catch (bytes memory /*lowLevelData*/){
      assert(true);
    }
  }

  int128 testx = this.exp(x);
  int128 testy = this.exp(y);
  //always exp >=0
  assert((testx >= zero) && (testy >=zero)) ;

  //exp is an increasing function
  if (x == y){
    assert(testx == testy);
  } else if (ABDKMath64x64.sub(x,y) >= zero){
    assert(testx >= testy);
  } else {
    assert(testx <= testy);
  }
}


/**
   * Test the fromInt functionality
   * @param x signed 256-bit integer number
  * @param x signed 256-bit integer number
*/
function testFromInt(int256 x, uint256 y) public{
  //try to catch the revert for x
  bool precond1 = (x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
  if (!precond1){
    try this.fromInt(x){
      assert (false);
    } catch (bytes memory /*lowLevelData*/){
      assert(true);
    }
  }

  //try to catch the revert for y
  if (y > 0x7FFFFFFFFFFFFFFF){
    try this.fromUInt(y){
      assert (false);
    } catch (bytes memory /*lowLevelData*/){
      assert(true);
    }
  }

  //assert that if  int(x) == int(y), then x2 == y2
  int128 x2 = ABDKMath64x64.fromInt(x);
  int128 y2 = ABDKMath64x64.fromUInt(y);

  if (int(x) == int(y)){
    assert (x2 == y2);
  }
  }
}
