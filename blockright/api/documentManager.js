var documentManagerApiRoutes = require('express').Router();

var Web3 = require('web3');
var config = require('../config/config')

var web3;
if (typeof web3 !== 'undefined') {
    web3 = new Web3(web3.currentProvider);
} else {
    web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:20010"));
    console.log(web3.net.peerCount);
}

web3.eth.defaultAccount = web3.eth.coinbase;

var documentManagerContractAddress = config.documentManagerContractAddress;


// now contract interface
var documentManagerContractABI = [
	{
		"constant": false,
		"inputs": [],
		"name": "allCopyrightsCount",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_documentHash",
				"type": "string"
			}
		],
		"name": "getDocument",
		"outputs": [
			{
				"name": "",
				"type": "string"
			},
			{
				"name": "",
				"type": "string"
			},
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_email",
				"type": "string"
			}
		],
		"name": "getProfile",
		"outputs": [
			{
				"name": "",
				"type": "string"
			},
			{
				"name": "",
				"type": "string"
			},
			{
				"name": "",
				"type": "string"
			},
			{
				"name": "",
				"type": "uint256"
			},
			{
				"name": "",
				"type": "uint256"
			},
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "getTotalCreditsIssued",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "getTotalCreditsIssuedFromCoupons",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "getTotalCreditsIssuedWithoutCoupons",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_email",
				"type": "string"
			}
		],
		"name": "getUserCopyrightsCount",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_email",
				"type": "string"
			}
		],
		"name": "getUserCredits",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_documentHash",
				"type": "string"
			}
		],
		"name": "isDocumentPresent",
		"outputs": [
			{
				"name": "",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_code",
				"type": "string"
			},
			{
				"name": "_value",
				"type": "uint256"
			}
		],
		"name": "issueCoupon",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_email",
				"type": "string"
			},
			{
				"name": "_password",
				"type": "string"
			},
			{
				"name": "_loginType",
				"type": "string"
			}
		],
		"name": "login",
		"outputs": [
			{
				"name": "",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "_actionPerformed",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_email",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_creditsTransferred",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "_time",
				"type": "uint256"
			}
		],
		"name": "transferEvent",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "_actionPerformed",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_email",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_name",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_time",
				"type": "uint256"
			}
		],
		"name": "userEvent",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "_actionPerformed",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_documentHash",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_email",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_uploadCreditCharge",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "_metadata",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_time",
				"type": "uint256"
			}
		],
		"name": "copyrightEvent",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "_actionPerformed",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_code",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_value",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "_time",
				"type": "uint256"
			}
		],
		"name": "couponEvent",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "_actionPerformed",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_paymentTransactionId",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_amount",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_email",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_time",
				"type": "uint256"
			}
		],
		"name": "paymentEvent",
		"type": "event"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_code",
				"type": "string"
			},
			{
				"name": "_email",
				"type": "string"
			}
		],
		"name": "redeemCoupon",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_paymentTransactionId",
				"type": "string"
			},
			{
				"name": "_planType",
				"type": "string"
			},
			{
				"name": "_amount",
				"type": "string"
			},
			{
				"name": "_paymentStatus",
				"type": "string"
			},
			{
				"name": "_email",
				"type": "string"
			},
			{
				"name": "_couponCode",
				"type": "string"
			},
			{
				"name": "_creditsEarned",
				"type": "uint256"
			}
		],
		"name": "registerPayment",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_email",
				"type": "string"
			},
			{
				"name": "_name",
				"type": "string"
			},
			{
				"name": "_password",
				"type": "string"
			},
			{
				"name": "_loginType",
				"type": "string"
			},
			{
				"name": "_id",
				"type": "string"
			}
		],
		"name": "registerUser",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_email",
				"type": "string"
			},
			{
				"name": "_creditsToBeTransferred",
				"type": "uint256"
			}
		],
		"name": "transferCredits",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_code",
				"type": "string"
			},
			{
				"name": "_value",
				"type": "uint256"
			}
		],
		"name": "updateCouponValue",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "constructor"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_email",
				"type": "string"
			},
			{
				"name": "_name",
				"type": "string"
			},
			{
				"name": "_password",
				"type": "string"
			},
			{
				"name": "_loginType",
				"type": "string"
			},
			{
				"name": "_id",
				"type": "string"
			}
		],
		"name": "updateUser",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_email",
				"type": "string"
			},
			{
				"name": "_socialData",
				"type": "string"
			}
		],
		"name": "updateUserSocialData",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_documentHash",
				"type": "string"
			},
			{
				"name": "_email",
				"type": "string"
			},
			{
				"name": "_metadata",
				"type": "string"
			},
			{
				"name": "_uploadCreditCharge",
				"type": "uint256"
			}
		],
		"name": "uploadNewDocument",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	}
];

//now contract initiation
var documentManagerContract = web3.eth.contract(documentManagerContractABI).at(documentManagerContractAddress);

documentManagerApiRoutes.get('/', function(req, res) {

    res.send("Document Manager API server");

});


documentManagerApiRoutes.post('/signUp', function(req, res) {

    var email = req.body._email;
    var name = req.body._name;
    var password = req.body._password;
    var loginType = req.body._loginType;
    var id = req.body._id;


    documentManagerContract.registerUser.sendTransaction(email, name, password, loginType, id, {
        from: web3.eth.defaultAccount,
        gas: 400000
    }, function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json(result);
        } else
            res.status(401).json("Error" + err);
    });
});


documentManagerApiRoutes.post('/updateUser', function(req, res) {

    var email = req.body._email;
    var name = req.body._name;
    var password = req.body._password;
    var loginType = req.body._loginType;
    var id = req.body._id;


    documentManagerContract.updateUser.sendTransaction(email, name, password, loginType, id, {
        from: web3.eth.defaultAccount,
        gas: 400000
    }, function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json(result);
        } else
            res.status(401).json("Error" + err);
    });
});

documentManagerApiRoutes.post('/login', function(req, res) {

    var email = req.body._email;
    var password = req.body._password;
    var loginType = req.body._loginType;

    documentManagerContract.login.call(email, password, loginType, function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json({
                "isPresent" : result
            });
        } else
            res.status(401).json("Error" + err);
    });

})


documentManagerApiRoutes.post('/getProfile', function(req, res) {

    var email = req.body._email;

    documentManagerContract.getProfile.call(email, function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json({
                "name" : result[0],
                "loginType" : result[1],
                "id" : result[2],
                "credits" : result[3],
                "userCopyrightsCount" : result[4],
		"userSocialData" : result[5]
            });
        } else
            res.status(401).json("Error" + err);
    });

})

documentManagerApiRoutes.post('/updateUserSocialData', function(req, res) {

    var email = req.body._email;
    var socialData = req.body._socialDataJson;

    documentManagerContract.updateUserSocialData.sendTransaction(email, socialData, {
        from: web3.eth.defaultAccount,
        gas: 570000
    }, function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json(result);
        } else
            res.status(401).json("Error" + err);
    });
});

documentManagerApiRoutes.post('/addFile', function(req, res) {

    var fileHash = req.body._fileHash;
    var email = req.body._email;
    var fileMetaData = req.body._fileMetaData;
    var uploadCreditCharge = req.body._uploadCreditCharge;


    documentManagerContract.uploadNewDocument.sendTransaction(fileHash, email, fileMetaData, uploadCreditCharge, {
        from: web3.eth.defaultAccount,
        gas: 400000
    }, function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json(result);
        } else
            res.status(401).json("Error" + err);
    });
});

documentManagerApiRoutes.post('/getDocument', function(req, res) {

    var documentHash = req.body._documentHash;

    documentManagerContract.getDocument.call(documentHash, function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json({
                "email" : result[0],
                "fileMetaData" : result[1],
                "uploadCreditCharge" : result[2]
            });
        } else
            res.status(401).json("Error" + err);
    });

})


documentManagerApiRoutes.post('/registerPayment', function(req, res) {

    var paymentTransactionId = req.body._paymentTransactionId;
    var planType = req.body._planType;
    var amount = req.body._amount;
    var paymentStatus = req.body._paymentStatus;
    var email = req.body._email;
    var couponCode = req.body._couponCode;
    var creditsEarned = req.body._creditsEarned;


    documentManagerContract.registerPayment.sendTransaction(paymentTransactionId, planType, amount, paymentStatus, email, couponCode, creditsEarned, {
        from: web3.eth.defaultAccount,
        gas: 400000
    }, function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json(result);
        } else
            res.status(401).json("Error" + err);
    });
});

documentManagerApiRoutes.post('/transferCredits', function(req, res) {

    var email = req.body._email;
    var creditsToBeTransferred = req.body._creditsToBeTransferred;


    documentManagerContract.transferCredits.sendTransaction(email, creditsToBeTransferred, {
        from: web3.eth.defaultAccount,
        gas: 400000
    }, function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json(result);
        } else
            res.status(401).json("Error" + err);
    });
});

documentManagerApiRoutes.post('/registerCoupounCode', function(req, res) {

    var code = req.body._code;
    var value = req.body._value;


    documentManagerContract.issueCoupon.sendTransaction(code, value, {
        from: web3.eth.defaultAccount,
        gas: 400000
    }, function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json(result);
        } else
            res.status(401).json("Error" + err);
    });
});

documentManagerApiRoutes.post('/updateCouponValue', function(req, res) {

    var code = req.body._code;
    var value = req.body._value;


    documentManagerContract.updateCouponValue.sendTransaction(code, value, {
        from: web3.eth.defaultAccount,
        gas: 400000
    }, function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json(result);
        } else
            res.status(401).json("Error" + err);
    });
});


documentManagerApiRoutes.post('/redeemCoupounCode', function(req, res) {

    var code = req.body._code;
    var email = req.body._email;


    documentManagerContract.redeemCoupon.sendTransaction(code, email, {
        from: web3.eth.defaultAccount,
        gas: 400000
    }, function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json(result);
        } else
            res.status(401).json("Error" + err);
    });
});


documentManagerApiRoutes.post('/getUserCredits', function(req, res) {

    var email = req.body._email;

    documentManagerContract.getUserCredits.call(email, function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json({
                "credits" : result
            });
        } else
            res.status(401).json("Error" + err);
    });

})

documentManagerApiRoutes.post('/getAllFilesForUser', function(req, res) {

    var email = req.body._email;

    documentManagerContract.getUserCopyrightsCount.call(email, function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json({
                "userCopyrights" : result
            });
        } else
            res.status(401).json("Error" + err);
    });

})


documentManagerApiRoutes.get('/getAllFileCount', function(req, res) {


    documentManagerContract.allCopyrightsCount.call(function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json({
                "allCopyrights" : result
            });
        } else
            res.status(401).json("Error" + err);
    });

})


documentManagerApiRoutes.get('/getTotalCreditsIssued', function(req, res) {


    documentManagerContract.getTotalCreditsIssued.call(function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json({
                "totalCreditsIssued" : result
            });
        } else
            res.status(401).json("Error" + err);
    });

})

documentManagerApiRoutes.get('/getTotalCreditsIssuedFromCoupons', function(req, res) {


    documentManagerContract.getTotalCreditsIssuedFromCoupons.call(function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json({
                "totalCreditsIssued" : result
            });
        } else
            res.status(401).json("Error" + err);
    });

})

documentManagerApiRoutes.get('/getTotalCreditsIssuedWithoutCoupons', function(req, res) {


    documentManagerContract.getTotalCreditsIssuedWithoutCoupons.call(function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json({
                "totalCreditsIssued" : result
            });
        } else
            res.status(401).json("Error" + err);
    });

})


documentManagerApiRoutes.post('/isFilePresent', function(req, res) {

    var fileHash = req.body._fileHash;

    documentManagerContract.isDocumentPresent.call(fileHash, function(err, result) {
        console.log(result);
        if (!err) {

            //console.log(response);
            res.json({
                "isPresent" : result
            });
        } else
            res.status(401).json("Error" + err);
    });

})

documentManagerApiRoutes.get('/getUserRegistrationLogs', function(req, res) {

    var userEvent = documentManagerContract.userEvent({
        from: web3.eth.defaultAccount
    }, {
        fromBlock: 0,
        toBlock: 'latest'
    });

    userEvent.get(function(err, result) {
        //console.log(result);
        if (!err) {

            //console.log(response);
            res.json(result);
        } else
            return res.json("Error" + err);
    });

})

documentManagerApiRoutes.get('/getPaymentReport', function(req, res) {

    var paymentEvent = documentManagerContract.paymentEvent({
        from: web3.eth.defaultAccount
    }, {
        fromBlock: 0,
        toBlock: 'latest'
    });

    paymentEvent.get(function(err, result) {
        //console.log(result);
        if (!err) {

            //console.log(response);
            res.json(result);
        } else
            return res.json("Error" + err);
    });

})

documentManagerApiRoutes.get('/getCouponLogs', function(req, res) {

    var couponEvent = documentManagerContract.couponEvent({
        from: web3.eth.defaultAccount
    }, {
        fromBlock: 0,
        toBlock: 'latest'
    });

    couponEvent.get(function(err, result) {
        //console.log(result);
        if (!err) {

            //console.log(response);
            res.json(result);
        } else
            return res.json("Error" + err);
    });

})

documentManagerApiRoutes.get('/getCopyrightLogs', function(req, res) {

    var copyrightEvent = documentManagerContract.copyrightEvent({
        from: web3.eth.defaultAccount
    }, {
        fromBlock: 0,
        toBlock: 'latest'
    });

    copyrightEvent.get(function(err, result) {
        //console.log(result);
        if (!err) {

            //console.log(response);
            res.json(result);
        } else
            return res.json("Error" + err);
    });

})
documentManagerApiRoutes.post('/getAllCopyrightedFilesForUser', function(req, res) {

    var copyrightEvent = documentManagerContract.copyrightEvent({
        from: web3.eth.defaultAccount
    }, {
        fromBlock: 0,
        toBlock: 'latest'
    });

    copyrightEvent.get(function(err, result) {
        //console.log(result);
        if (!err) {



      var arrayLength = result.length;
           
            var processedArray = [];
            for (var i = 0; i < arrayLength; i++) {

   if (result[i].args._email == req.body._email) {

                    processedArray.push(

                        {

                            "blockNumber": result[i].blockNumber,
                            "transactionHash": result[i].transactionHash,
                            "documentHash": result[i].args._documentHash,
                            "email": result[i].args._email,
                            "uploadCreditCharge" : result[i].args._uploadCreditCharge
                           
                        }

                    )
                }

            }
        	//true

            //console.log(response);
            res.json(processedArray);
        } else
            return res.json("Error" + err);
    });

});
documentManagerApiRoutes.get('/getTransferLogs', function(req, res) {

    var transferEvent = documentManagerContract.transferEvent({
        from: web3.eth.defaultAccount
    }, {
        fromBlock: 0,
        toBlock: 'latest'
    });

    transferEvent.get(function(err, result) {
        //console.log(result);
        if (!err) {

            //console.log(response);
            res.json(result);
        } else
            return res.json("Error" + err);
    });

})

module.exports = documentManagerApiRoutes;
