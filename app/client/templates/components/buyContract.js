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
let ppccontractInstance;
let eventcontractInstance;
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
        let transactionObjectPPC = {
            data: PPC.bytecode,
            gasPrice: web3.eth.gasPrice,
            gas: 5000000,
            from: web3.eth.accounts[0]
        };

        let transactionObjectEvent = {
            data: Events.bytecode,
            gasPrice: web3.eth.gasPrice,
            gas: 5000000,
            from: web3.eth.accounts[0]
        };

        // estimate gas cost then transact new PPC
        web3.eth.estimateGas(transactionObjectPPC, function(err, estimateGas){
            // multiply by 10 hack for testing
            // if(!err) transactionObjectPPC.gas = estimateGas * 100;
            console.log('estimate gas for PPC: ', estimateGas);
            PPC.deployed(function(err, ppccontract){
                if(err) return TemplateVar.set(template, 'state', {isError: true, error: String(err)});
                web3.eth.estimateGas(transactionObjectEvent, function(err, estimateGas){
                    // multiply by 10 hack for testing
                    // if(!err) transactionObjectEvent.gas = estimateGas * 100;
                    if (ppccontractInstance) return;
                    ppccontractInstance = "initializing";
                    console.log('estimate gas for event: ', estimateGas);
                    Events.deployed(function(err, eventcontract){
                        clearTimeout(mineTimeout);
                        if(err) return TemplateVar.set(template, 'state', {isError: true, error: String(err)});

                        if(ppccontract.address && eventcontract.address) {
                            TemplateVar.set(template, 'state', {isMined: true, address: ppccontract.address, source: source});
                            ppccontractInstance = ppccontract;
                            eventcontractInstance = eventcontract;
                            ppccontractInstance.initialize.call(template.data.peep.screen_name, template.data.peep.screen_name, new Date().getTime(), function(err, result){
                                if (err) {
                                    console.error('Unable to initialize the account '+template.data.peep.screen_name+' for betting :(');
                                } else {
                                    console.log('Successfully initialized the account '+template.data.peep.screen_name+ ' for betting!', result);
                                }
                            });
                        } else {
                            // this gets called many times in callback?

                            // console.log('addr1',ppccontract.address, 'addr2',eventcontract.address);
                            // TemplateVar.set(template, 'state', {isError: true, error: String("Unable to submit the transaction")});
                        }
                    });
                });
            });
        });
	},

    
	/**
	On Multiply Number Input keyup
	
	@event (keyup #multiplyValue)
	*/

	"keyup #buyValue": function(event, template){
        // the input value
        if (event.which == 13) {
            let value = template.find("#buyValue").value || 1;
            if (ppccontractInstance){
                if (eventcontractInstance){
                    eventcontractInstance.getTradePrice.call(template.data.peep.screen_name, function(err,result){
                        if(err) TemplateVar.set(template, 'buyResult', String(err));
                        console.log('the price is ', result, result ? value*(result.toNumber(10)) : null);
                        ppccontractInstance.buy(template.data.peep.screen_name, {value: result ? value*(result.toNumber(10)+10) : 1000000, from: web3.eth.accounts[0]},function(err, result){
                            // this is the amount bought

                            console.log('the result of .buy() is ', result, result ? result.toNumber(10) : null);
                            TemplateVar.set(template, 'buyResult', result ? result.toNumber(10) : 'Unable to get buy');

                            if(err) TemplateVar.set(template, 'buyResult', String(err));
                        });
                    })
                } else {
                    console.error('unable to get the Event contract');
                }
            } else {
                console.error('unable to get the PPC contract');
            }
        }

	},
});
