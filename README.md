### Echidna-Workshop
Submission repository for the echidna workshop held by Secureum and Trail of Bits Team.


### Files in the repo
- [ABDKMATH64x64 library](https://github.com/DecorativePineapple/echidna-workshop/blob/main/ABDKMath64x64.sol): Forked from the [official ABDK libary](https://github.com/abdk-consulting/abdk-libraries-solidity/blob/master/ABDKMath64x64.sol)
- [EchidnaTest.sol](https://github.com/DecorativePineapple/echidna-workshop/blob/main/EchidnaTest.sol): file containinf the assertions to test the ABDKMATH64x64 library. 

Run the `echidna-test` with :

`echidna-test abdk-libraries-solidity-master/EchidnaTest.sol --contract Test --test-mode assertion --corpus-dir corpus --seq-len 1 --test-limit 400000` 


There's a [blog post](https://decorativepineapple.github.io/posts/a-week-with-echidna/) explaining what's happening here:)


Github: [decorativepineapple](https://github.com/DecorativePineapple/)

Twitter: [0xpineappleland](https://twitter.com/0xpineappleland)

