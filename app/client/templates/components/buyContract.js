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

        

        // estimate gas cost then transact new PPC
        web3.eth.estimateGas(transactionObjectPPC, function(err, estimateGas){
            // multiply by 10 hack for testing
            if(!err) transactionObjectPPC.gas = Math.round(estimateGas * 1.1);
            console.log('estimate gas for PPC: ', estimateGas);
            PPC.at(Meteor.settings.public.ppc, function(err, ppccontract){
                if(err) return TemplateVar.set(template, 'state', {isError: true, error: String(err)});
                if (ppccontractInstance) return;
                ppccontractInstance = "initializing";
                Events.at(Meteor.settings.public.events, function(err, eventcontract){
                    clearTimeout(mineTimeout);
                    if(err) return TemplateVar.set(template, 'state', {isError: true, error: String(err)});

                    if(ppccontract.address && eventcontract.address) {
                        TemplateVar.set(template, 'state', {isMined: true, address: ppccontract.address, source: source});
                        ppccontractInstance = ppccontract;
                        eventcontractInstance = eventcontract;
                        ppccontractInstance.initialize.call(
                            template.data.peep.screen_name, 
                            template.data.peep.screen_name, 
                            new Date().getTime(), 
                            transactionObjectPPC, function(err, result){
                                if (err){
                                    console.error('Unable to initialize the account '+template.data.peep.screen_name+' for betting :(', err);
                                } else {
                                    console.log('Successfully initialized the account '+template.data.peep.screen_name+ ' for betting!', "bought: "+result.toNumber(10));
                                }                    
                        });
                    } else {

                        console.log('addr1',ppccontract.address, 'addr2',eventcontract.address);
                        TemplateVar.set(template, 'state', {isError: true, error: String("Unable to submit the transaction")});
                    }
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

                    let transactionObjectEvent = {
                        data: Events.bytecode,
                        gasPrice: web3.eth.gasPrice,
                        gas: 5000000,
                        from: web3.eth.accounts[0]
                    };
                    let transactionObjectPPC = {
                        data: PPC.bytecode,
                        gasPrice: web3.eth.gasPrice,
                        gas: 5000000,
                        from: web3.eth.accounts[0]
                    };
                    web3.eth.estimateGas(transactionObjectEvent, function(err, estimateGas){
                        // multiply by 10 hack for testing
                        if(!err) transactionObjectEvent.gas = Math.round(estimateGas * 1.1);
                        console.log('estimate gas for Events: ', estimateGas);

                        eventcontractInstance.getTradePrice.call(template.data.peep.screen_name, transactionObjectEvent, function(err, result){
                            if (err){
                                console.log('had err in get trade price result')
                                TemplateVar.set(template, 'buyResult', String(err));
                            } else {
                                console.log('the price is ', value*(result.toNumber(10)));
                                web3.eth.estimateGas(transactionObjectPPC, function(err, estimateGas){
                                    if(!err) transactionObjectPPC.gas = Math.round(estimateGas * 1.1);
                                    console.log('estimate gas for PPC: ', estimateGas);
                                    transactionObjectPPC.value = value*(result.toNumber(10)+10);
                                    console.log('value of buy attempt is '+transactionObjectPPC.value);
                                    ppccontractInstance.buy(
                                        template.data.peep.screen_name, 
                                        transactionObjectPPC
                                    ).then(function(result){
                                        // this is the amount bought
                                        console.log('the result of .buy() is ', result.toNumber(10));
                                        TemplateVar.set(template, 'buyResult', result.toNumber(10));
        
                                    }).catch(function(err){
                                        console.log('the result of buy() is an error')
                                        TemplateVar.set(template, 'buyResult', String(err));
                                    });
                                });   
                            }                                                     
                        });
                    });

                    
                } else {
                    console.error('unable to get the Event contract');
                }
            } else {
                console.error('unable to get the PPC contract');
            }
        }

	},
});
