/**
 * Created by sudot on 1/8/2018.
 */


// IMPORTANT: all code in server is temporary and please do not add more unless absolutely necessary
// This is important so the app can be run without a server and decentralized

// configure twitter
Meteor.startup(function() {


    let Twitter = require('twitter');
    let client = new Twitter({
        consumer_key: "RukEAX94pvZQYas53FpqsexyE",
        consumer_secret: "FcCOQmds98ZlbrIJyvGB5W2qJyQZHM6WITySJQLwxFz2xJqYGu",

        // TODO make access token keys anonymous
        access_token_key: "359362638-pk8Zin1kYOkUEWbx2WNSlvnKBcqGlh6kQh4fxfA4",
        access_token_secret: "wsh6t4jso7E1bKFgoOjOTUWPEgpiqm78x6LysQ52JycvA"
    });

    // {
    //     "previous_cursor": 0,
    //     "previous_cursor_str": "0",
    //     "next_cursor": 1333504313713126852,
    //     "users": [
    //     {
    //     }],
    //     "next_cursor_str": "1333504313713126852"
    // };


    // I20180108-02:23:01.857(-8)?      { id: 16067035,
    // I20180108-02:23:01.857(-8)?        id_str: '16067035',
    // I20180108-02:23:01.858(-8)?        name: 'Olivier Grisel',
    // I20180108-02:23:01.870(-8)?        screen_name: 'ogrisel',
    // I20180108-02:23:01.873(-8)?        location: 'Paris, France',
    // I20180108-02:23:01.874(-8)?        url: 'http://ogrisel.com',
    // I20180108-02:23:01.880(-8)?        description: 'Engineer at @Parietal_INRIA, contributes to scikit-learn. Tweets about Python, Machine Learning research in general and Deep Learning in particular.',
    // I20180108-02:23:01.883(-8)?        protected: false,
    // I20180108-02:23:01.886(-8)?        followers_count: 21954,
    // I20180108-02:23:01.887(-8)?        friends_count: 1866,
    // I20180108-02:23:01.887(-8)?        listed_count: 1266,
    // I20180108-02:23:01.887(-8)?        created_at: 'Sun Aug 31 14:51:19 +0000 2008',
    // I20180108-02:23:01.888(-8)?        favourites_count: 1876,
    // I20180108-02:23:01.891(-8)?        utc_offset: 3600,
    // I20180108-02:23:01.893(-8)?        time_zone: 'Paris',
    // I20180108-02:23:01.894(-8)?        geo_enabled: true,
    // I20180108-02:23:01.896(-8)?        verified: false,
    // I20180108-02:23:01.897(-8)?        statuses_count: 11921,
    // I20180108-02:23:01.898(-8)?        lang: 'fr',
    // I20180108-02:23:01.898(-8)?        contributors_enabled: false,
    // I20180108-02:23:01.899(-8)?        is_translator: false,
    // I20180108-02:23:01.899(-8)?        is_translation_enabled: false,
    // I20180108-02:23:01.902(-8)?        profile_background_color: '53464C',
    // I20180108-02:23:01.903(-8)?        profile_background_image_url: 'http://pbs.twimg.com/profile_background_images/725802369/a9bef563ef107d39b78c9f65d67a5dbd.png',
    // I20180108-02:23:01.903(-8)?        profile_background_image_url_https: 'https://pbs.twimg.com/profile_background_images/725802369/a9bef563ef107d39b78c9f65d67a5dbd.png',
    // I20180108-02:23:01.904(-8)?        profile_background_tile: true,
    // I20180108-02:23:01.904(-8)?        profile_image_url: 'http://pbs.twimg.com/profile_images/1775098078/moa_normal.jpg',
    // I20180108-02:23:01.904(-8)?        profile_image_url_https: 'https://pbs.twimg.com/profile_images/1775098078/moa_normal.jpg',
    // I20180108-02:23:01.906(-8)?        profile_banner_url: 'https://pbs.twimg.com/profile_banners/16067035/1362325045',
    // I20180108-02:23:01.907(-8)?        profile_link_color: 'ABB8C2',
    // I20180108-02:23:01.907(-8)?        profile_sidebar_border_color: 'CDB790',
    // I20180108-02:23:01.915(-8)?        profile_sidebar_fill_color: '9ED7C1',
    // I20180108-02:23:01.920(-8)?        profile_text_color: 'F62D4B',
    // I20180108-02:23:01.922(-8)?        profile_use_background_image: true,
    // I20180108-02:23:01.924(-8)?        has_extended_profile: false,
    // I20180108-02:23:01.934(-8)?        default_profile: false,
    // I20180108-02:23:01.939(-8)?        default_profile_image: false,
    // I20180108-02:23:01.951(-8)?        following: true,
    // I20180108-02:23:01.953(-8)?        live_following: false,
    // I20180108-02:23:01.954(-8)?        follow_request_sent: false,
    // I20180108-02:23:01.954(-8)?        notifications: false,
    // I20180108-02:23:01.955(-8)?        muting: false,
    // I20180108-02:23:01.955(-8)?        blocking: false,
    // I20180108-02:23:01.955(-8)?        blocked_by: false,
    // I20180108-02:23:01.956(-8)?        translator_type: 'none' },

    var keys = [];
    var data = {};
    client.get('friends/list', {count: 200, include_user_entities: false, skip_status: true}, function(error, friends, response) {
        console.log('friends', friends ? JSON.stringify(friends.users.map(function(f){
            if (keys.indexOf(f.screen_name) == -1 && f.profile_image_url) {
                keys.push(f.screen_name);
                data[f.screen_name] = {profile_image_url: f.profile_image_url, description: f.description};
            }
            return f.screen_name;
        })) : "??");

        // console.log('\ndata: ', JSON.stringify(data));

        // Keys:
        // ["id","id_str","name","screen_name","location","url","description","protected","followers_count","friends_count","listed_count","created_at",
        // "favourites_count","utc_offset","time_zone","geo_enabled","verified","statuses_count","lang","contributors_enabled","is_translator",
        // "is_translation_enabled","profile_background_color","profile_background_image_url","profile_background_image_url_https","profile_background_tile",
        // "profile_image_url","profile_image_url_https","profile_banner_url","profile_link_color","profile_sidebar_border_color","profile_sidebar_fill_color",
        // "profile_text_color","profile_use_background_image","has_extended_profile","default_profile","default_profile_image","following","live_following",
        // "follow_request_sent","notifications","muting","blocking","blocked_by","translator_type"]
    });

});