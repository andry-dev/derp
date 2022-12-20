// SPDX-License-Identifier: GPL-v3

pragma solidity >=0.7.0 <0.9;

contract Derp {
    struct Product {
        uint32 storeId;
        uint32 localProductId;
        bytes[] reviewHashes;
        bool _initialized;
    }

    struct Review {
        address reviewer;
        int64 upvotes;
        bool _initialized;
    }

    address private owner;

    mapping(address => int64) private reviewTokens;
    mapping(address => int64) private profileTokens;

    Product[] private products;
    mapping(bytes => Review) private reviews;
    mapping(address => mapping(uint64 => bool)) private productsClaimed;

    int8 public constant REVIEW_COST = 2;
    int8 public constant REVIEW_REWARD = 1;
    int8 public constant UPVOTE_COST = 2;
    int8 public constant UPVOTE_REWARD = 1;
    int8 public constant PER_PURCHASE_TOKENS = 10;

    constructor() {
        owner = msg.sender;
    }

    function obtainReviewToken(uint64 productId) public {
        require(!productsClaimed[msg.sender][productId]);

        // Oracle?
        bool boughtItem = true;
        require(boughtItem);

        productsClaimed[msg.sender][productId] = true;
        reviewTokens[msg.sender] += PER_PURCHASE_TOKENS;
    }

    // Reviewer is msg.sender
    function makeReview(uint64 productId, bytes calldata reviewHash)
        public
        returns (bool)
    {
        require(reviewTokens[msg.sender] >= REVIEW_COST);
        require(!reviews[reviewHash]._initialized);
        require(productsClaimed[msg.sender][productId]);

        // Avoids creating a review for a product that doesn't exist.
        require(products[productId]._initialized);

        Review memory r = Review({
            reviewer: msg.sender,
            upvotes: 1,
            _initialized: true
        });

        reviews[reviewHash] = r;
        products[productId].reviewHashes.push(reviewHash);

        reviewTokens[msg.sender] -= REVIEW_COST;
        profileTokens[msg.sender] += REVIEW_REWARD;

        return true;
    }

    function upvoteReview(bytes calldata reviewHash) public {
        Review storage review = reviews[reviewHash];
        require(review._initialized);
        require(reviewTokens[msg.sender] >= UPVOTE_COST);

        reviewTokens[msg.sender] -= UPVOTE_COST;

        review.upvotes += 1;

        profileTokens[review.reviewer] += UPVOTE_REWARD;
    }

    // Utility functions below
    // You should only call these functions on your local node without
    // spending gas.

    function reviewExists(bytes calldata reviewHash)
        public
        view
        returns (bool)
    {
        return reviews[reviewHash]._initialized;
    }

    //
    // function getProduct(uint64 productId)
    //     public
    //     view
    //     returns (Product calldata)
    // {
    //     require(products[productId]._initialized);
    //
    //     return products[productId];
    // }

    function getReviewTokens() public view returns (int64) {
        return reviewTokens[msg.sender];
    }

    function getProfileTokens() public view returns (int64) {
        return profileTokens[msg.sender];
    }
}
