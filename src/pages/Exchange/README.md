#How to use Chromium

###Things to do before using:
- Make sure the correct parameters are set before deploying the contract. It needs the oracle's address and the CBLT token address.
- Set up the oracle by entering new tokens into the updateToken function and give them values. 
  - Only go to 15 numbers or fewer so the fee structure will work. (100000000000000)
- Send CBLT tokens to the exchange so that it can use them to trade.

###Functions:
- getCbltExchangeRate: 
  - The token that the user is going to send to the exchange is the first parameter. The second is the token they are going to receive. The third parameter is the amount in which the user is going to send to the exchange. 
    - The number that is returned needs to be divided by 1000000. I have it set up on the front end already.
- swapForCblt: 
  - First parameter is the token that is going to be sent to the exchange. The second parameter is the amount he is going to send.
- swapCbltForToken: 
  - First parameter is the token that the user will receive from the exchange. The second parameter is the amount of CBLT tokens he is sending to the exchange.

###Front-end:
- The swapCbltForToken function or interface has not been created yet.
- The swapForCblt function still needs to implement the approve token function whenever the user 
  tries to exchange a token for CBLT.
- The oracle page in the ChromiumMain page can be taken out, I just have it there for development 
  so that it's easy to enter tokens into the oracle

###Tips:
- Whenever you first deploy, make sure that CBLT has a value in the oracle. The CBLT info is 
  in the oracle constructor but sometimes it doesn't set CBLT and it will have to be entered manually.
- All the numbers are set up to work in Wei. The front end should do most of the conversion so that the user 
  doesn't have to enter the amount in Wei.
- The exchange will only work with tokens that it can call the token's ABI.
- Whenever you enter a token into the oracle, give it a little while to update. 
