/**
Template Controllers

@module Templates
*/

/**
The view2 template

@class [template] views_view2
@constructor
*/

Template['views_account'].helpers({
	/**
	 Get the name

	 @method (name)
	 */

	'name': function(){
		return this.name || TAPi18n.__('dapp.account.defaultName');
	}
});


Template['views_account'].onCreated(function() {
	  Meta.setSuffix(TAPi18n.__("dapp.account.title"));
});
