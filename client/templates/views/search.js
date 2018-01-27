/**
Template Controllers

@module Templates
*/

/**
The view1 template

@class [template] views_view1
@constructor
*/

Template['views_search'].helpers({
    /**
    Get the name

    @method (name)
    */

    'name': function(){
        return this.name || TAPi18n.__('dapp.search.defaultName');
    },
    'peep': function(){
        return this.peep;
    },
    'peeps': function(){
        return this.peeps;
    }
});

// When the template is created
Template['views_search'].onCreated(function(){
	Meta.setSuffix(TAPi18n.__("dapp.search.title"));
});
