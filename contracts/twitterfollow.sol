// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TwitterFollow {
    /// @notice Mapping to store followers and following relationships
    mapping(address => mapping(address => bool)) private isFollowing;
    mapping(address => address[]) private followers;
    mapping(address => address[]) private following;

    /// @notice Events for logging follow and unfollow actions
    event Followed(address indexed user, address indexed target);
    event Unfollowed(address indexed user, address indexed target);

    /// @notice Follow another user
    function follow(address _target) external {
        require(_target != msg.sender, "You cannot follow yourself");
        require(!isFollowing[msg.sender][_target], "Already following this user");

        isFollowing[msg.sender][_target] = true;
        following[msg.sender].push(_target);
        followers[_target].push(msg.sender);

        emit Followed(msg.sender, _target);
    }

    /// @notice Unfollow a user
    function unfollow(address _target) external {
        require(isFollowing[msg.sender][_target], "Not following this user");

        isFollowing[msg.sender][_target] = false;
        _removeFromArray(following[msg.sender], _target);
        _removeFromArray(followers[_target], msg.sender);

        emit Unfollowed(msg.sender, _target);
    }

    /// @notice Check if a user follows another
    function isUserFollowing(address _user, address _target) external view returns (bool) {
        return isFollowing[_user][_target];
    }

    /// @notice Get followers of a user
    function getFollowers(address _user) external view returns (address[] memory) {
        return followers[_user];
    }

    /// @notice Get users a person is following
    function getFollowing(address _user) external view returns (address[] memory) {
        return following[_user];
    }

    /// @dev Helper function to remove an address from an array
    function _removeFromArray(address[] storage array, address target) private {
        uint256 length = array.length;
        for (uint256 i = 0; i < length; i++) {
            if (array[i] == target) {
                array[i] = array[length - 1];
                array.pop();
                break;
            }
        }
    }
}
