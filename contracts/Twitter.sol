// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/// @title Twitter Follow Feature Interface
/// @dev This allows Twitter to interact with the follow contract
interface ITwitterFollow {
    function follow(address _target) external;
    function unfollow(address _target) external;
    function isUserFollowing(address _user, address _target) external view returns (bool);
}

contract Twitter {
    // STRUCT
    struct Tweet {
        uint id;
        address author;
        string content;
        uint timestamp;
        uint likes;
    }

    // VARIABLES
    uint16 public MAX_TWEET_LIMIT = 200;
    address public owner;
    ITwitterFollow public followContract; // Declare the follow contract

    // MAPPINGS
    mapping(address => Tweet[]) public tweets;

    // EVENTS
    event TweetCreated(uint id, address indexed author, string content, uint timestamp, uint likes);
    event TweetLengthChanged(address indexed owner, uint16 tweetLength);
    event TweetLiked(address indexed author, uint likes);
    event TweetUnLiked(address indexed author, uint likes);
    event Followed(address indexed user, address indexed target);
    event Unfollowed(address indexed user, address indexed target);

    // MODIFIERS
    modifier onlyOwner() {
        require(msg.sender == owner, "YOU'RE NOT THE OWNER");
        _;
    }

    // CONSTRUCTOR
    constructor(address _followContract) {
        owner = msg.sender;
        followContract = ITwitterFollow(_followContract);
    }

    // FOLLOW FEATURE FUNCTIONS
    function followUser(address _target) external {
        followContract.follow(_target);
        emit Followed(msg.sender, _target);
    }

    function unfollowUser(address _target) external {
        followContract.unfollow(_target);
        emit Unfollowed(msg.sender, _target);
    }

    function isFollowing(address _user, address _target) external view returns (bool) {
        return followContract.isUserFollowing(_user, _target);
    }

    // TWEET FUNCTIONS
    function createTweet(string memory _tweet) public {
        require(bytes(_tweet).length > 0, "NO CONTENT, PLEASE WRITE SOMETHING");
        require(tweets[msg.sender].length < MAX_TWEET_LIMIT, "THE MAXIMUM TWEETS REACHED");

        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });

        tweets[msg.sender].push(newTweet);
        emit TweetCreated(newTweet.id, newTweet.author, newTweet.content, newTweet.timestamp, newTweet.likes);
    }

    function numberOfTweets() public view returns (uint) {
        return tweets[msg.sender].length;
    }

    function viewTweet(address _owner, uint _i) public view returns (Tweet memory) {
        return tweets[_owner][_i];
    }

    function getAllTweets(address _owner) public view returns (Tweet[] memory) {
        return tweets[_owner];
    }

    function changeTweetLength(uint16 _newTweetLength) public onlyOwner {
        MAX_TWEET_LIMIT = _newTweetLength;
        emit TweetLengthChanged(msg.sender, _newTweetLength);
    }

    function likeTweet(address author, uint id) public {
        require(tweets[author][id].id == id, "TWEET DOESN'T EXIST");
        tweets[author][id].likes++;

        emit TweetLiked(author, tweets[author][id].likes);
    }

    function unLikeTweet(address author, uint id) public {
        require(tweets[author][id].id == id, "TWEET DOESN'T EXIST");
        require(tweets[author][id].likes > 0, "THERE ARE NO LIKES");
        tweets[author][id].likes--;

        emit TweetUnLiked(author, tweets[author][id].likes);
    }
}
