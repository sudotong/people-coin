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

    let data = {};
    let friends = TwitterFriends.find({}).fetch().map(friend => {
        data['@'+friend.screen_name] = friend.image;
        return friend.screen_name
    });
    $("input#searchBox").autocomplete({data, limit: 5, minLength: 1, onAutoComplete: function(screen_name){
        if (screen_name && screen_name.startsWith('@')) screen_name = screen_name.substring(1);
        let peep = TwitterFriends.findOne({screen_name});
        if (screen_name && peep) Router.go('search.show', {_id: screen_name}, {peep});
    }});
    console.log('initialized autocomplete with '+friends.length+' records');
});

// when the template is destroyed
Template['components_searchBox'].onDestroyed(function() {

});

Template['components_searchBox'].events = {
    'keyup input#searchBox': function () {
        // AutoCompletion.autocomplete({
        //     element: 'input#searchBox',       // DOM identifier for the element
        //     collection: TwitterFriends,              // MeteorJS collection object
        //     field: 'screen_name',                    // Document field name to search for
        //     limit: 5 });              // Sort object to filter results with
        //filter: { 'gender': 'female' }}); // Additional filtering
    },
    'change input#searchBox': function (e) {
        let screen_name = $(e.target).val();
        if (screen_name && screen_name.startsWith('@')) screen_name = screen_name.substring(1);
        let peep = TwitterFriends.findOne({screen_name});
        if (screen_name && peep) Router.go('search.show', {_id: screen_name}, {peep});
    }
};


Template['components_searchBox'].helpers({
    twitterUsers: function(){
        return [];
    }
});