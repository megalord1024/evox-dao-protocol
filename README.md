# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js
```


user have their evox bal in the saliber 


vote = saliber balance + deposit amount balance 
     =  unvestedamount + 

goverence = deposit evo balnce 


<===================================================>
overflow logic 

const aggregateOverflowVotes = X 0 

If (votes > tenPercentOfSupply){

    const overflowVotes = votes - tenPercentOfCirculatingSupply

    votes = tenPercentOfCirculatingSupply

    aggregateOverflowVotes += overflowVotes

}

Let totalYesVotes = A

Let totalNoVotes = B


yesVoteProportion = A/(A+B)

overflowToAllocateToYes = yesVoteProportion * aggregateOverflowVotes

overflowToAllocateToNo = aggregateOverflowVotes - overflowToAllocateToYes

 

totalYesVotes += overflowToAllocateToYes

totalNoVotes += overflowToAllocateToNo

if (vote == yes){

    totalYesVotes += votes
}

else{

    totalNoVotes +=votes

}




