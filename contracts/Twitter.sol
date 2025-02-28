// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Twitter{

    //STRUCT
    struct Tweet {
        uint id;
        address author;
        string content;
        uint timestamp;
        uint likes;
    }

    //VARAIBLES
    uint16 public MAX_TWEET_LIMIT = 200;
    address public owner;

    //MAPPINGS
    mapping(address => Tweet[]) public tweets;

    //CONSTRUCTOR
    constructor(){
        owner = msg.sender;
    }

    //MODIFIERS
    modifier onlyOwner(){
        require(msg.sender == owner, "YOU'RE NOT THE OWNER");
        _;
    }

    //EVENTS
    event TweetCreated(uint id, address indexed author, string content, uint timestamp, uint likes);
    event TweetLengthChanged(address indexed owner, uint16 tweetlength);
    event TweetLiked(address indexed author, uint likes);
    event TweetUnLiked(address indexed author, uint likes);


    //FUNCTIONS

    function createTweet(string memory _tweet) public {
        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes : 0
        });

        tweets[msg.sender].push(newTweet);
        emit TweetCreated(newTweet.id, newTweet.author, newTweet.content, newTweet.timestamp, newTweet.likes);
    }


    function numberOfTweets() public view returns (uint) {
        return tweets[msg.sender].length;    
    }

    function viewTweet(address _owner, uint _i) public view returns(Tweet memory){
        return tweets[_owner][_i];
    }

    function getAllTweets(address _owner) public view returns(Tweet [] memory){
        return tweets[_owner];
    }

    function changeTweetLength(uint16 _newTweetLength) public onlyOwner {
        MAX_TWEET_LIMIT = _newTweetLength;
        emit TweetLengthChanged(msg.sender,_newTweetLength);
    }

    function likeTweet(address author, uint id) public{
        require(tweets[author][id].id == id, "TWEET DOESN'T EXIST");
        tweets[author][id].likes++;

        emit TweetLiked(msg.sender, tweets[msg.sender][id].likes);
    }

    function uLlikeTweet(address author, uint id) public{
        require(tweets[author][id].id == id, "TWEET DOESN'T EXIST");
        require(tweets[author][id].likes > 0, "THERE ARE NO LIKES");
        tweets[author][id].likes--;

        emit TweetUnLiked(msg.sender, tweets[msg.sender][id].likes);
    }


}