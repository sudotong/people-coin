
// Basic (local) collections
// we use {connection: null} to prevent them from syncing with our not existing Meteor server

// A test persitent collection
TwitterFriends = new Mongo.Collection('mydb', {connection: null});
new PersistentMinimongo2(TwitterFriends);


TwitterFriends.remove({});
let tf = ["hadiyahdotme","KimmyDanny","NatalieFratto","karan_hiremath","alicevdeng","jessicacollier","steemit","leezabuh","brian_armstrong","code_jide","fllorencekwok","zooko","ScottRogowsky","vmanasvi","petewarden","random_forests","googleresearch","jason_mayes","jtwald","typesfast","MineFilecoin","jazminJKwest","cultureisfuture","soylent","johnloeber","btaylor","mischaarmada","maiab","bradfordcross","gems","Chief_Obi","kevinmarume","erickpinos","Rainmakers_only","orbirental","paddlecareers","compa_as","thinkGatsby","hello_iamelliot","lightningai","graphcool","corbett","mathteacher309","RoyPurdy","vikesh002","villageglobal","Wayne","ivan7237d","km","kevintpayne","gxzliu","SusanSearchPro","thesalesmethod","addyosmani","LILBTHEBASEDGOD","julie_a_shah","drfeifei","bqueener","matelabs_ai","SHERM8N","curious_rv","DannieHerz","AccelepriseSF","jisungkimm","floodgatefund","FloydHub_","pandastartup","BloomToken","JeffTPhD","jeffiel","Acceleprise","MGCardamone","stevenudotong","jamescham","BloombergBeta","roybahat","danimman","DhruvaKumar","tandersontaa","SlackHQ","stewart","welbyaltidor","kgimvalley","AlikoDangote","Illeto","kuntajts","amandaaakate","Polymail","santoshSmohan","crystalrose","elizabethsnower","dashbotio","swelly127","amygheng","viccypont","btrenchard","Parietal_INRIA","ogrisel","BrianNorgard","karoly_zsolnai","thedroneboy","marannelson","joininteract","kevinttully","Blavity","Jon__Jackson","ekp","atShruti","Joi","FuckNazisVLP","aunder","6Gems","chrismessina","mish_peralta","anvishapai","shaft","KwameSomPimpong","tituslungu","asuth","LauraDeming","AdrianGrant","EarnestSweat","WadeGMorgan","MarciaLDyson","seq23","ierollins","MorganDeBaun","arinzeobiezue","kharijohnson","manishsinhaha","antimatter15","iyadrahwan","scalablecoop","bradheitmann","_KyraClaire","9MileLabs","brent_alvord","heyreiwang","nbt","TryEvaBot","hoctopi","onedayitoogofly","IAugenstein","nwquah","foundersofcolor","stubailo","christinaqi","techsetters_io","ivanbeckley","TheRealBuzz","CALLR","buster","patpaulcollins","arianafont","dr0nestagram","PriyaRangarajan","JoinJara","joincolony","thejerrylu","8ennett","sw","BrendonCassidy","karine_hsu","manan19","tferriss","akin_adesina","ConnextProject","tgmason","Lux_Capital","naval","GigiGraham5","StaceyFerreira","iaboyeji","jerrytalton","dan____f","changds","johnnylin","golemproject","julianzawist","VitalikButerin","seanrose","SorayaFouladi","EmanAbiola","comma_ai","vkhosla","olshansky","licuende","ncasenmare","rowantrollope","TomasReimers","josephwandile","letsjetpack","FatimaDicko_","useloom","cwarzel","eladgil","jimscheinman","blockstack","yadavajay","theweester"];
for (let i=0;i<tf.length;i++){
    if (!TwitterFriends.findOne({screen_name: tf[i]})) {
        let randDate = new Date(new Date().getTime() - Math.random()*1000*60*60*24*60);
        let randCreatedDate = new Date(new Date().getTime() - Math.random()*1000*60*60*24*60);
        TwitterFriends.insert({
            screen_name: tf[i],
            lastTrade: new Date(Math.max(randCreatedDate.getTime(), randDate.getTime())),
            numTrades: Math.ceil(Math.random()*10000),
            created: randCreatedDate
        });
    }
}
console.log('upserted twitterfriends!');