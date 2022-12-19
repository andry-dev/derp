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
        bool _initialized;
    }

    address private owner;

    mapping(address => uint256) private reviewTokens;
    mapping(address => uint256) private profileTokens;

    Product[] private products;
    mapping(bytes => Review) private reviews;

    constructor() {
        owner = msg.sender;
    }

    // Reviewer is msg.sender
    function makeReview(uint256 productId, bytes calldata reviewHash)
        public
        returns (bool)
    {
        // Oracle?
        bool boughtItem = true;
        if (!boughtItem) {
            return false;
        }

        require(products[productId]._initialized);

        Review memory r = Review({reviewer: msg.sender, _initialized: true});

        reviews[reviewHash] = r;
        products[productId].reviewHashes.push(reviewHash);

        reviewTokens[msg.sender] -= 1;
        profileTokens[msg.sender] += 1;

        return true;
    }

    /*
        const hash = ipfs.upload(reviewText)

        contract.makeReview(product, hash).send().then(response => {
            if response {
                post('fantasticoserver', ...);
            }
        });
    */

    function reviewExists(bytes calldata reviewHash)
        public
        view
        returns (bool)
    {
        return reviews[reviewHash]._initialized;
    }

    // contract.reviewExists(hash).call().then((response) => {
    //    if response {
    //    }
    // })

    function getProduct(uint256 productId)
        public
        view
        returns (Product calldata)
    {
        require(products[productId]._initialized);

        return products[productId];
    }

    function rateReview(Review review) public {}
}
