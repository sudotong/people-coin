/**
Template Controllers

@module Routes
*/

/**
The app routes

@class App routes
@constructor
*/

// Change the URLS to use #! instead of real paths
// Iron.Location.configure({useHashPaths: true});


ApplicationController = RouteController.extend({
    layoutTemplate: 'layout_main',
    onBeforeAction: function () {
        // do some login checks or other custom logic
        if (EthAccounts.find().fetch().length === -1) {
            // if the user is not logged in, render the Login template
            this.render('login');
        } else {
            // otherwise don't hold up the rest of hooks or our route/action function
            this.next();
        }
    }
});

// Router defaults
Router.configure({
    layoutTemplate: 'layout_main',
    notFoundTemplate: 'layout_notFound',
    yieldRegions: {
        'layout_header': {to: 'header'}
        , 'layout_footer': {to: 'footer'}
    },
    controller: 'ApplicationController'
});

// ROUTES

/**
The receive route, showing the wallet overview

@method dashboard
*/

// Default route
Router.route('/', function(){
    defaultView(this);
    let allPeeps = TwitterFriends.find({}).fetch();
    let peeps = [];
    let added = [];
    let iterated = 6;
    while (peeps.length < 3 && --iterated >0) {
        let randPeep = allPeeps[Math.floor(Math.random()*allPeeps.length)];
        if (randPeep && added.indexOf(randPeep._id) == -1){
            peeps.push(randPeep);
            added.push(randPeep._id);
        }
    }
    this.render('views_search', {
        data: {peeps}
    });
},{
    name: 'home'
});

// Route for search page
Router.route('/search', function(){
    defaultView(this);
    let allPeeps = TwitterFriends.find({}).fetch();
    let peeps = [];
    let added = [];
    let iterated = 6;
    while (peeps.length < 3 && --iterated >0) {
        let randPeep = allPeeps[Math.floor(Math.random()*allPeeps.length)];
        if (randPeep && added.indexOf(randPeep._id) == -1){
            peeps.push(randPeep);
            added.push(randPeep._id);
        }
    }
    this.render('views_search', {
        data: {peeps}
    });
}, {
    name: 'search'
});

// Route for Account page
Router.route('/account', {
    template: 'views_account',
    name: 'account'
});

// Route for List page
Router.route('/list', function(){
    this.redirect('/list/top');
});

Router.route('/list/:_id', function(){
    let type = this.params._id;
    defaultView(this);
    if (['top', 'trending', 'new'].indexOf(type) > -1){
        this.render('views_list', {
            data: {viewType: type}
        });
    } else {
        this.render('layout_notFound');
    }
}, {
    name: 'list.show',
});

Router.route('/guide', {
    template: 'views_guide',
    name: 'guide'
});

Router.route('/search/:_id', function(){
    defaultView(this);
    let peep = TwitterFriends.findOne({screen_name: this.params._id});
    let allPeeps = TwitterFriends.find({}).fetch();
    let peeps = [];
    let added = [];
    let iterated = 6;
    while (peeps.length < 3 && --iterated >0) {
        let randPeep = allPeeps[Math.floor(Math.random()*allPeeps.length)];
        if (randPeep && added.indexOf(randPeep._id) == -1){
            peeps.push(randPeep);
            added.push(randPeep._id);
        }
    }
    if (peep){
        this.render('views_search', {
            data: {peep, peeps}
        });
    } else {
        this.render('layout_notFound');
    }
}, {
    name: 'search.show',
});

Router.route('/faq', {
    template: 'views_faq',
    name: 'faq'
});

Router.route('/view/:_id', function(){
    defaultView(this, 'full');
    this.render('views_airtable', {
        data: {table: this.params._id}
    });
}, {
    name: 'airtable',
});

function defaultView(self, isFull){
    self.layout(isFull == 'full' ? 'layout_main_full' : 'layout_main');
    self.render('layout_header', {to: 'header'});
    self.render('layout_footer', {to: 'footer'});
}
