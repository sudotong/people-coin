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

// Router defaults
Router.configure({
    layoutTemplate: 'layout_main',
    notFoundTemplate: 'layout_notFound',
    yieldRegions: {
        'layout_header': {to: 'header'}
        , 'layout_footer': {to: 'footer'}
    }
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
// TODO handle top/live/new
Router.route('/list', {
    template: 'views_list',
    name: 'list'
});

Router.route('/faq', {
    template: 'views_faq',
    name: 'faq'
});