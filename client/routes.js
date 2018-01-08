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
        if (!Meteor.userId()) {
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
Router.route('/', {
    template: 'views_search',
    name: 'home'
});

// Route for search page
Router.route('/search', {
    template: 'views_search',
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
    var type = this.params._id;
    if (['top', 'trending', 'new'].indexOf(type) > -1){
        this.render('views_list', {
            data: function () {
                console.log('Need to return the data for the view: ', type);
                return null;
                // return Posts.findOne({type: type});
            }
        });
    } else {
        this.render('layout_notFound');
    }
}, {
    name: 'list.show',
    layoutTemplate: 'layout_main'
});

Router.route('/faq', {
    template: 'views_faq',
    name: 'faq'
});