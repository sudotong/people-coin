/**
Template Controllers

@module Templates
*/

/**
The multiply contract template.

Note, the MultiplyContract object is now housed in client/lib/contracts/MultiplyContract.sol

@class [template] components_multiplyContract
@constructor
*/

// solidity source code
let source = `contract MultiplyContract {
    function multiply(uint a) public pure returns(uint d) { return a * 7; }
}`;

// Construct Multiply Contract Object and contract instance
let contractInstance;
let mineTimeout;

// When the template is rendered
Template['components_multiplyContract'].onRendered(function(){
    TemplateVar.set('state', {isInactive: true});
});

Template['components_multiplyContract'].helpers({

	/**
	Get multiply contract source code.
	
	@method (source)
	*/

	'source': function(){
		return source;
	}
});

Template['components_multiplyContract'].events({

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
            data: MultiplyContract.bytecode, 
            gasPrice: web3.eth.gasPrice,
            gas: 500000,
            from: web3.eth.accounts[0]
        };
        
        // estimate gas cost then transact new MultiplyContract
        web3.eth.estimateGas(transactionObject, function(err, estimateGas){
            // multiply by 10 hack for testing
            if(!err) transactionObject.gas = estimateGas * 10;
            MultiplyContract.new(transactionObject, function(err, contract){
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

	"keyup #multiplyValue": function(event, template){
        // the input value
		let value = template.find("#multiplyValue").value;
        if (contractInstance && value){
            // call MultiplyContract method `multiply` which should multiply the `value` by 7
            contractInstance.multiply.call(value, function(err, result){
                TemplateVar.set(template, 'multiplyResult', result.toNumber(10));
                if(err){
                    TemplateVar.set(template, 'multplyResult', String(err));
                }
            });
        } else {
            console.error('Unable to get the contract instance or value ', value);
        }

	}
});
