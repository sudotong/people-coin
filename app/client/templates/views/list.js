Template['views_list'].helpers({
    /**
     Get the name

     @method (name)
     */

    'name': function(){
        return this.name || TAPi18n.__('dapp.list.defaultName');
    },
    'friends': function(){
        var sorts = {
            'top': {numTrades: -1},
            'trending': {lastTrade: -1},
            'new': {created: -1}
        };
        return TwitterFriends.find({}, this.viewType ? {sort: sorts[this.viewType], limit: 50} : null).fetch();
    }
});


Template['views_list'].onCreated(function() {
    Meta.setSuffix(TAPi18n.__("dapp.list.title"));
});
