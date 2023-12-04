// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ChatApp {
    struct user {
        string name;
        friend[] friendList;
    }
    struct friend {
        address publickey;
        string name;
    }

    struct message {
        address sender;
        uint256 timestamp;
        string msg;
    }

    struct AllUserStuck {
        string name;
        address accountAddress;
    }
    AllUserStuck[] getAllusers;
    mapping(address => user) userList;
    mapping(bytes32 => message[]) allMessages;

    function checkUserExists(address publickey) public view returns (bool) {
        return bytes(userList[publickey].name).length > 0;
    }

    function createAccount(string calldata name) external {
        require(checkUserExists(msg.sender) == false, "User Already exists");
        require(bytes(name).length > 0, "Username cannot be empty");
        userList[msg.sender].name;
        getAllusers.push(AllUserStuck(name, msg.sender));
    }

    function getUsername(
        address publickey
    ) external view returns (string memory) {
        require(checkUserExists(publickey), "User is not reg");
        return userList[publickey].name;
    }

    function addFriend(address friend_key, string calldata name) external {
        require(checkUserExists(msg.sender), "create account");
        require(checkUserExists(friend_key), "user is not registered");
        require(msg.sender != friend_key, "user can not add themselves");
        require(
            checkAlreadyFriends(msg.sender, friend_key) == false,
            "these users are already friends"
        );

        _addFriend(msg.sender, friend_key, name);
        _addFriend(friend_key, msg.sender, userList[msg.sender].name);
    }

    function checkAlreadyFriends(
        address publickey1,
        address pubkey2
    ) internal view returns (bool) {
        if (
            userList[publickey1].friendList.length >
            userList[pubkey2].friendList.length
        ) {
            address tmp = publickey1;
            publickey1 = pubkey2;
            pubkey2 = tmp;
        }
        for (uint256 i = 0; i < userList[publickey1].friendList.length; i++) {
            if (userList[publickey1].friendList[i].publickey == pubkey2) {
                return true;
            }
        }
        return false;
    }

    function _addFriend(
        address me,
        address friend_key,
        string memory name
    ) internal {
        friend memory newFriend = friend(friend_key, name);
        userList[me].friendList.push(newFriend);
    }

    function getMyFriendList() external view returns (friend[] memory) {
        return userList[msg.sender].friendList;
    }

    function _getChatCode(
        address pubkey1,
        address pubkey2
    ) internal pure returns (bytes32) {
        if (pubkey1 < pubkey2) {
            return keccak256(abi.encodePacked(pubkey1, pubkey2));
        } else return keccak256(abi.encodePacked(pubkey2, pubkey1));
    }

    function sendMessage(address friend_key, string calldata _msg) external {
        require(checkUserExists(msg.sender), "Create an account first");
        require(checkUserExists(friend_key), "User is not registered");
        require(
            checkAlreadyFriends(msg.sender, friend_key),
            "You are not friend with the given user"
        );

        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        message memory newMsg = message(msg.sender, block.timestamp, _msg);
        allMessages[chatCode].push(newMsg);
    }

    function readMessage(
        address friend_key
    ) external view returns (message[] memory) {
        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        return allMessages[chatCode];
    }

    function getAllAppUser() public view returns (AllUserStuck[] memory) {
        return getAllusers;
    }
}
