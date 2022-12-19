// SPDX=License-Identifier: GPL-v3

pragma solidity >= 0.7.0 < 0.9;

contract Derp {
    struct Product {
        uint32 storeId;
        uint32 productId;
    }

    struct Review {
        address owner;
        bytes hash;
        Product product;
    }

    mapping(address => uint) private reviewTokens;
    mapping(address => uint) private profileTokens;
    
    Review[] private reviews;

    constructor() {

    }

    // Reviewer is msg.sender
    function makeReview(Product calldata product, bytes calldata reviewHash) public returns(bool)  {
        // Oracle?
        bool bought_item = true;
        if (!bought_item) {
            return false;
        }

        // Review r;
        // r.owner = msg.sender;
        // r.product = product;
        // reviews[reviewHash] = r;
        
        Review memory review = Review({
            owner: msg.sender,
            hash: reviewHash,
            product: product
        });
        uint reviewId = reviews.push(review) - 1;

        // uint64 id = (uint64(product.storeId) << 32) | uint64(product.productId);
        // Check if products exists beforehand
        // products[id].reviews[msg.sender] = reviewHash;

        reviewTokens[msg.sender] -= 1;
        profileTokens[msg.sender] += 1;

        return true;
    }

    /*
        const hash = ipfs.upload(reviewText)

        contract.makeReview.send(product, hash).then(response => {
            if response {
                post('fantasticoserver', ...);
            }
        });
    */

    function reviewExists(bytes calldata reviewHash) returns(bool) {
        return reviews[reviewHash];
    }

    // contract.reviewExists.call(hash)

    function getReviewsFromProduct(Product calldata product) {

    }

    function rateReview(Review review) public {

    }
}
