Template['views_faq'].helpers({
    /**
     Get the name

     @method (name)
     */

    'name': function(){
        return this.name || TAPi18n.__('dapp.faq.defaultName');
    }
});


Template['views_faq'].onCreated(function() {
    Meta.setSuffix(TAPi18n.__("dapp.faq.title"));
});
