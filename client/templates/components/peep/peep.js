Template['components_peep'].onRendered(function() {


});

Template['components_peep'].helpers({
    'peep': function(){
        return this.data ? this.data.peep || this.peep : this.peep;
    },
    'sample': function(){
        return this.sample ? this.data.sample || this.sample : this.sample;
    }
});
