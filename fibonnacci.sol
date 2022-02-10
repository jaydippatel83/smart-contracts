pragma solidity ^0.8.0;

contract fibbonecci{
    function fib(uint n) pure external returns(uint){
        if(n==0){
            return 0;
        }
        uint f_1 = 1;
        uint f_2 = 1;
        for(uint i = 2; i < n ;i++){
            uint fi = f_1 + f_2;
            f_2 = f_1;
            f_1 = fi;
        }
        return f_1;
    }
}