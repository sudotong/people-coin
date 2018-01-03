Template['views_list'].helpers({
    /**
     Get the name

     @method (name)
     */

    'name': function(){
        return this.name || TAPi18n.__('dapp.list.defaultName');
    }
});


Template['views_list'].onCreated(function() {
    Meta.setSuffix(TAPi18n.__("dapp.list.title"));
});
