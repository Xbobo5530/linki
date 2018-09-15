// const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });



const functions = require('firebase-functions');
const admin = require('firebase-admin');

// ES5 require
const metaScraper = require('meta-scraper').default;

// const metascraper = require('metascraper')

// const metascraper = require('metascraper')([
//     require('metascraper-author')(),
//     require('metascraper-date')(),
//     require('metascraper-description')(),
//     require('metascraper-image')(),
//     require('metascraper-logo')(),
//     require('metascraper-clearbit-logo')(),
//     require('metascraper-publisher')(),
//     require('metascraper-title')(),
//     require('metascraper-url')()
//   ]);
// const got = require('got')

admin.initializeApp();

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

exports.populateMeta = functions.firestore
    .document('Links/{linkId}')
    .onCreate((snap, context) => {
        //get the new object representing the document
        const newLinkDoc = snap.data()
        //get the url
        const url = newLinkDoc.url
        console.log('the newly created url is: ' + url)


        // Returns a promise. 
        metaScraper('https://facebook.com')
            .then( (data) => {
                console.log(data);
                /*
                  { 
                    error: false,
                    allTags: [ 
                      { charset: 'utf-8' },
                      { name: 'referrer', content: 'default', id: 'meta_referrer'},
                      { property: 'og:site_name', content: 'Facebook' }
                      ...more tags
                    ],
                    pageTitle: 'Facebook - Log In or Sign Up',
                    pubDate: false,
                    title: 'Facebook - Log In or Sign Up',
                    description: 'Create an account or log into Facebook. Connect with friends, family and other people you know. Share photos and videos, send messages and get updates.',
                    image: 'https://www.facebook.com/images/fb_icon_325x325.png'
                  }
                */
               expect(typeof data).toBe('object');
               expect(Array.isArray(data.meta)).toBe(true);
               return console.log(data)
            }).catch(error => {
                expect(error).toBeTruthy();
            });


        const targetUrl = url
        (async () => {
            const {body: html, url} = await got(targetUrl)
            const metadata = await metascraper({html, url})
            console.log(metadata)
          })()

        // show url on screen
        // exports.functions.https.onRequest((request, response) => {
        //     response.send('the new url is: ' + url + '\nthe meta data is ' + metadata);
        // });

    })


// exports.helloWorld = functions.https.onRequest((request, response) => {
//     console.log('this thing works, hahhhaa');
//  response.send(url);
// });