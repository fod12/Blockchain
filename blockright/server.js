var express = require('express'),
    cors = require('cors'),
    app = express();
var bodyParser = require('body-parser');
var Web3 = require('web3');

var bodyParser = require('body-parser')
app.use(bodyParser.urlencoded({
    extended: false
}));
app.use(bodyParser.json());



//session configs
var expressSession = require('express-session');
var cookieParser = require('cookie-parser'); // the session is stored in a cookie, so we use this to parse it


app.use(cookieParser());

app.use(expressSession({
    secret: 'BlockRight_session',
    resave: false,
    saveUninitialized: true
}));


//For enabling CORS
app.use(cors());

app.get('/', function(req, res) {

    res.send("This API server is developed for BlockRight");
})

//API handlers
app.use('/api/documentManager', require('./api/documentManager'));

app.listen(3001, function() {
    console.log('app running on port : 3001');
});
