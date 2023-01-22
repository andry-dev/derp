// vim: ts=2 sw=2
const Derp = artifacts.require("Derp");
//const ProvableAPI = artifacts.require("provableAPI");
//const OraclizeAPI = artifacts.require("oraclizeAPI")

module.exports = async function (deployer) {
  await deployer.deploy(Derp);

  const instance = await Derp.deployed();
  const contract = instance.contract;

  const accounts = await web3.eth.getAccounts();
  const server = accounts[0];
  console.log(`Server account is ${server}`);
  const reviewer = accounts[1];
  console.log(`Reviewer account is ${reviewer}`);
  const upvoter = accounts[3];
  console.log(`Upvoter account is ${upvoter}`);

  await contract.methods.addProducts([
    (0n << 32n) | 1n,
    (1n << 32n) | 1n,
  ]).send({ from: server });

  const productId = (1n << 32n) | 1n;

  // JS needs BigInt for 64-bit integers
  await contract.methods.rewardReviewToken(reviewer, productId).send({
    from: server,
  });

  const tokens = await contract.methods.getReviewTokens().call({
    from: reviewer,
  });
  console.log(`Reviewer has ${tokens} tokens`);

  const product = await contract.methods.getProduct(productId).call({
    from: reviewer,
  });
  console.log(product);

  const reviewHash = 0x1234;
  //unless 1mln of gas is specified this fails
  //might need to check config
  await contract.methods.makeReview(productId, reviewHash).send({
    from: reviewer,
    gas: 1000000,
  });

  //check whether review exists
  const result = await contract.methods.reviewExists(reviewHash).call({
    from: reviewer,
  });
  console.log(result);

  //redeem fake tokens for upvoter
  await contract.methods.rewardReviewToken(upvoter, productId).send({
    from: server,
  });
  await contract.methods.upvoteReview(reviewHash).send({ from: upvoter });
  const upv_token = await contract.methods.getProfileTokens().call({
    from: reviewer,
  });
  console.log(`Reviewer has ${upv_token} profile tokens`);
};
