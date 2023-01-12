// SPDX-License-Identifier: GPL-v3

pragma solidity >=0.7.0 <0.9;

import "../dependencies/provable/provableAPI.sol";

contract Derp is usingProvable {
    struct Product {
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

    mapping(uint64 => Product) private products;
    mapping(bytes => Review) private reviews;
    mapping(address => mapping(uint64 => bool)) private productsClaimed;

    // newID = products.push({});

    int8 public constant REVIEW_COST = 2;
    int8 public constant REVIEW_REWARD = 1;
    int8 public constant UPVOTE_COST = 2;
    int8 public constant UPVOTE_REWARD = 1;
    int8 public constant PER_PURCHASE_TOKENS = 10;

    constructor() {
        owner = msg.sender;
    }

    /*
    function obtainAllReviewTokens(address account) public {
        require(!productsClaimed[account][productId]);

        // store_id

        // Oracle?
        bool boughtItem = true;
        require(boughtItem);

        // [local_product_id]

        productsClaimed[account][productId] = true;
        reviewTokens[account] += PER_PURCHASE_TOKENS;
    }
    */

    function obtainReviewToken(address account, uint64 productId) external {
        require(
            !productsClaimed[account][productId],
            "Product already claimed"
        );

        // Oracle?
        bool boughtItem = true;
        require(boughtItem);

        productsClaimed[account][productId] = true;
        reviewTokens[account] += PER_PURCHASE_TOKENS;
    }

    // Reviewer is msg.sender
    function makeReview(uint64 productId, bytes calldata reviewHash)
        external
        returns (bool)
    {
        require(reviewTokens[msg.sender] >= REVIEW_COST, "Not enough tokens");
        require(!reviews[reviewHash]._initialized, "Review already exists");
        require(productsClaimed[msg.sender][productId], "Product not claimed");

        // Avoids creating a review for a product that doesn't exist.
        require(products[productId]._initialized, "Product doesn't exist");

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

    function upvoteReview(bytes calldata reviewHash) external {
        Review storage review = reviews[reviewHash];
        require(review._initialized);
        require(reviewTokens[msg.sender] >= UPVOTE_COST);

        reviewTokens[msg.sender] -= UPVOTE_COST;

        review.upvotes += 1;

        profileTokens[review.reviewer] += UPVOTE_REWARD;
    }

    function refreshProducts() external {
        // Oracle

        uint64 storeId = 0;
        uint64 localProductId = 1;

        Product memory p = Product({
            _initialized: true,
            reviewHashes: new bytes[](0)
        });

        uint64 productId = (storeId << 32) | localProductId;

        products[productId] = p;
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

    function getProduct(uint64 productId) public view returns (Product memory) {
        require(products[productId]._initialized, "Product doesn't exist");

        return products[productId];
    }

    function getReviewTokens() public view returns (int64) {
        return reviewTokens[msg.sender];
    }

    function getProfileTokens() public view returns (int64) {
        return profileTokens[msg.sender];
    }
}
