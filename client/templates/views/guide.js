Template['views_guide'].helpers({
    /**
     Get the name

     @method (name)
     */

    'name': function(){
        return this.name || TAPi18n.__('dapp.guide.defaultName');
    }
});


Template['views_guide'].onCreated(function() {
    Meta.setSuffix(TAPi18n.__("dapp.guide.title"));
});
