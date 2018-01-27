/**
Template Controllers

@module Templates
*/

/**
The multiply contract template.

Note, the Naze object is now housed in client/lib/contracts/Naze.sol

@class [template] components_buyContract
@constructor
*/

// solidity source code

import source from './NazeSolSource';

// Construct Multiply Contract Object and contract instance
let contractInstance;
let mineTimeout;

// When the template is rendered
Template['components_buyContract'].onRendered(function(){
    TemplateVar.set('state', {isInactive: true});
});

Template['components_buyContract'].helpers({

	/**
	Get multiply contract source code.
	
	@method (source)
	*/

	'source': function(){
		return source;
	},
});

Template['components_buyContract'].events({

	/**
	On "Create New Contract" click
	
	@event (click .btn-default)
	*/

	"click .btn-default": function(event, template){ // Create Contract
        TemplateVar.set('state', {isMining: true});

        clearTimeout(mineTimeout);
        mineTimeout = setTimeout(function(){
            TemplateVar.set(template, 'state', {isError: true, error: String("Unable to initialize the transaction")});
        }, 10000);

        // Set coinbase as the default account
        web3.eth.defaultAccount = web3.eth.coinbase;
        
        // assemble the tx object w/ default gas value
        let transactionObject = {
            data: PPC.bytecode,
            gasPrice: web3.eth.gasPrice,
            gas: 500000,
            from: web3.eth.accounts[0]
        };
        
        // estimate gas cost then transact new PPC
        web3.eth.estimateGas(transactionObject, function(err, estimateGas){
            // multiply by 10 hack for testing
            if(!err) transactionObject.gas = estimateGas * 10;

            PPC.new(transactionObject, function(err, contract){
                clearTimeout(mineTimeout);
                if(err) return TemplateVar.set(template, 'state', {isError: true, error: String(err)});

                if(contract.address) {
                    TemplateVar.set(template, 'state', {isMined: true, address: contract.address, source: source});
                    contractInstance = contract;
                } else {
                    TemplateVar.set(template, 'state', {isError: true, error: String("Unable to submit the transaction")});
                }
            });
        });
	},

    
	/**
	On Multiply Number Input keyup
	
	@event (keyup #multiplyValue)
	*/

	"keyup #buyValue": function(event, template){
        // the input value
		let value = template.find("#buyValue").value;
        if (contractInstance){
            // call Naze method `multiply` which should multiply the `value` by 7
            contractInstance.multiply.call(value, function(err, result){
                TemplateVar.set(template, 'buyResult', result.toNumber(10));

                if(err) TemplateVar.set(template, 'buyResult', String(err));
            });
        }

	},
});
