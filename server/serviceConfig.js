/**
 * Created by sudot on 1/8/2018.
 */


// IMPORTANT: all code in server is temporary and please do not add more unless absolutely necessary
// This is important so the app can be run without a server and decentralized

// configure twitter
Meteor.startup(function() {

    ServiceConfiguration.configurations.update(
        {"service": "twitter"},
        {
            $set: {
                "consumerKey": "RukEAX94pvZQYas53FpqsexyE",
                "secret": "FcCOQmds98ZlbrIJyvGB5W2qJyQZHM6WITySJQLwxFz2xJqYGu"
            }
        },
        {upsert: true}
    );

});