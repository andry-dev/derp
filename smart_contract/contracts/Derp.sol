// SPDX-License-Identifier: GPL-v3

pragma solidity >=0.7.0 <0.9;

contract Derp {
    enum ProductState {
        UNCLAIMED,
        CLAIMED,
        REVIEWED
    }

    // The product for which an user wants to make a review.
    // This is indexed as a combination of the store ID and the product ID
    // local to that store.
    //
    // Example:
    //    store ID = 1,
    //    local product ID = 1,
    //    product ID = 0x100000001
    struct Product {
        bytes[] reviewHashes;
        bool _initialized;
    }

    // A review made by a reviewer.
    // The text of the review is stored on IPFS.
    struct Review {
        address reviewer;
        int64 upvotes;
        bool _initialized;
    }

    // The deployer of the contract.
    // Used to check the authenticity of the reviews.
    address private owner;

    // Mapping for the NFTs used on the website.
    mapping(address => int64) private reviewTokens;
    mapping(address => int64) private profileTokens;

    // Mapping from the uint64 product ID to the stored products.
    mapping(uint64 => Product) private products;

    // Array used to retrieve all the products stored on-chain.
    uint64[] private registeredProducts;

    // Mapping from the IPFS' Content Identifier of the review to the actual
    // review.
    mapping(bytes => Review) private reviews;

    // Mapping used for retrieving the IPFS' CIDs of the reviews made by an
    // address.
    mapping(address => bytes[]) private reviewsFromAddress;

    // Mapping of the products actually claimed by an user.
    // Used to store on-chain the validity of the reviews.
    mapping(address => mapping(uint64 => ProductState)) private productsClaimed;

    //Array used to retrieve all the profile items stored on-chain
    //that can be bought with user tokens
    //This could be expanded in the future with a struct
    bytes[] private profileItems; 

    //Mapping with the price of profile items
    mapping(bytes => int64) private profileItemPrices;

    //Mapping with a list of item profile purchased by a user
    mapping(address => bytes[]) private userProfileItems;

    // Events emitted when an user wants to know if some review tokens can be
    // obtained.
    //
    // ReviewTokensGranted is emitted when the response is affirmative.
    event AllReviewTokensRequested(address account);
    event ReviewTokenRequested(address account, uint64 product);
    event ReviewTokensGranted(address account);

    // Event emitted when an user wants to refresh the products for which they
    // can create a review.
    event ProductRefreshRequested();

    // Constants used by the contract

    int8 public constant REVIEW_COST = 2;
    int8 public constant REVIEW_REWARD = 1;
    int8 public constant UPVOTE_COST = 2;
    int8 public constant UPVOTE_REWARD = 1;
    int8 public constant PER_PURCHASE_TOKENS = 10;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function requestAllReviewTokens() external {
        emit AllReviewTokensRequested(msg.sender);
    }

    function requestReviewToken(uint64 productId) external {
        // Check if the product was already claimed.
        require(
            productsClaimed[msg.sender][productId] == ProductState.UNCLAIMED,
            "Product already claimed"
        );

        emit ReviewTokenRequested(msg.sender, productId);
    }

    function rewardReviewToken(address account, uint64 productId)
        external
        onlyOwner
    {
        productsClaimed[account][productId] = ProductState.CLAIMED;
        reviewTokens[account] += PER_PURCHASE_TOKENS;

        emit ReviewTokensGranted(account);
    }

    function rewardReviewTokens(address account, uint64[] calldata productIds)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < productIds.length; ++i) {
            if (
                productsClaimed[account][productIds[i]] ==
                ProductState.UNCLAIMED
            ) {
                productsClaimed[account][productIds[i]] = ProductState.CLAIMED;
                reviewTokens[account] += PER_PURCHASE_TOKENS;
            }
        }

        emit ReviewTokensGranted(account);
    }

    // Reviewer is msg.sender
    function makeReview(uint64 productId, bytes calldata reviewHash)
        external
        returns (bool)
    {
        require(reviewTokens[msg.sender] >= REVIEW_COST, "Not enough tokens");
        require(!reviews[reviewHash]._initialized, "Review already exists");

        // Stops the user from making reviews of products they have not claimed.
        require(
            productsClaimed[msg.sender][productId] == ProductState.CLAIMED,
            "Product not claimed or already reviewed"
        );

        // Avoids creating a review for a product that doesn't exist.
        require(products[productId]._initialized, "Product doesn't exist");

        Review memory r = Review({
            reviewer: msg.sender,
            upvotes: 1,
            _initialized: true
        });

        reviewsFromAddress[msg.sender].push(reviewHash);

        reviews[reviewHash] = r;
        products[productId].reviewHashes.push(reviewHash);

        reviewTokens[msg.sender] -= REVIEW_COST;
        profileTokens[msg.sender] += REVIEW_REWARD;

        productsClaimed[msg.sender][productId] = ProductState.REVIEWED;

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

    function addProduct(uint64 productId) external onlyOwner {
        require(!products[productId]._initialized, "Product already exists");

        Product memory p = Product({
            _initialized: true,
            reviewHashes: new bytes[](0)
        });

        if (!products[productId]._initialized) {
            registeredProducts.push(productId);
            products[productId] = p;
        }
    }

    function addProducts(uint64[] calldata productIds) external onlyOwner {
        for (uint256 i = 0; i < productIds.length; ++i) {
            Product memory p = Product({
                _initialized: true,
                reviewHashes: new bytes[](0)
            });

            if (!products[productIds[i]]._initialized) {
                registeredProducts.push(productIds[i]);
                products[productIds[i]] = p;
            }
        }
    }

    function buyProfileItem(bytes calldata itemHash) external {
        require(
            profileItemPrices[itemHash] > profileTokens[msg.sender],
            "Not enough tokens"
        );

        profileTokens[msg.sender] -= profileItemPrices[itemHash];
        userProfileItems[msg.sender].push(itemHash); 
    }

    //This function allows to register new NFTS for the profile
    //TODO: It can be called only by the server 
    function addProfileItem(bytes calldata itemHash, int64 price)
        external
    {
        //itemHash is the hash of the css from ipfs
        profileItems.push(itemHash);
        //We also update the price in the mapping
        profileItemPrices[itemHash] = price;
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

    function getProducts() public view returns (uint64[] memory) {
        return registeredProducts;
    }

    function getReviewTokens() public view returns (int64) {
        return reviewTokens[msg.sender];
    }

    function getProfileTokens() public view returns (int64) {
        return profileTokens[msg.sender];
    }

    function getReviews() public view returns (bytes[] memory) {
        return reviewsFromAddress[msg.sender];
    }

    function getProfileItems() public view returns (bytes[] memory){
        return userProfileItems[msg.sender];
    }

    function getBuyableProfileItems() public view returns (bytes[] memory){
        return profileItems;
    }
}
