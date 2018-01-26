# People Coin

Bet on the people that you know, and cash out when others bet on them after you.

## Getting Started

Run Geth:
```geth --rpc --rpccorsdomain "http://localhost:3000" --etherbase 45d71b61cb4394bfee56ba926cf1f134dd7d500a```

(use etherbase address: `45d71b61cb4394bfee56ba926cf1f134dd7d500a`)

Run Meteor:
```meteor```

### Prerequisites

You will need to download the go-ethereum client, and you will need to have installed meteor.


### Installing

Install Geth (go-ethereum).
Windows: https://github.com/ethereum/go-ethereum/wiki/Installation-instructions-for-Windows

Run `meteor npm install`

## Running the tests

TODO write tests with truffle https://github.com/blmalone/eth-smart-contracts

Install testrpc: https://github.com/ethereumjs/testrpc
npm install -g ethereumjs-testrpc

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

TBD

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/sudotong/naze-coin/tags).

## Authors

* **Sam Udotong** - *Initial work* - [sudotong](https://github.com/sudotong)

See also the list of [contributors](https://github.com/sudotong/naze-coin/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Open source projects for help with Solidity contracts: https://github.com/mevu-bet/mevu/tree/master/contracts
* Inspiration: CryptoKitties

Useful tutoials:
https://github.com/ethereum/wiki/wiki/Dapp-using-Meteor
http://dinukshaish.blogspot.com/2017/03/creating-dapp-using-ethereum-and-meteor.html

Twitter search: http://strangemilk.com/twitter-api-with-javascript/#twittertldr

## Open Questions

* Store the number of searches and views per twitter account on purchase on the ETH blockchain?
* How do we do more in general on the blockchain in a decentralized fashion
