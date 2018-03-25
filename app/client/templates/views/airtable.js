Template['views_airtable'].helpers({
    /**
     Get the name

     @method (name)
     */

     'height': function(){
         return $(document).height();
     },
     'heightFrame': function(){
        return $(document).height()+25;
    },

    'table': function(){
        return this.table;
    },
    'name': function(){
        return this.name || TAPi18n.__('dapp.airtable.defaultName');
    }
});


Template['views_airtable'].onCreated(function() {
    Meta.setSuffix(TAPi18n.__("dapp.airtable.title"));
});
