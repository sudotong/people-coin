/**
 Template Controllers

 @module Templates
 */

/**
 The search box template

 @class [template] components_searchBox
 @constructor
 */

// when the template is rendered
Template['components_searchBox'].onRendered(function() {
    AutoCompletion.init("input#searchBox");
});

// when the template is destroyed
Template['components_searchBox'].onDestroyed(function() {

});

Template['components_searchBox'].events = {
    'keyup input#searchBox': function () {
        AutoCompletion.autocomplete({
            element: 'input#searchBox',       // DOM identifier for the element
            collection: TwitterFriends,              // MeteorJS collection object
            field: 'screen_name',                    // Document field name to search for
            limit: 5 });              // Sort object to filter results with
        //filter: { 'gender': 'female' }}); // Additional filtering
    }
}


Template['components_searchBox'].helpers({
    twitterUsers: function(){
        return [];
    }
});