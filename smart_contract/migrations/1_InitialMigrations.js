// vim: ts=2 sw=2
const Derp = artifacts.require("Derp");
//const ProvableAPI = artifacts.require("provableAPI");
//const OraclizeAPI = artifacts.require("oraclizeAPI")


module.exports = async function (deployer) {
  await deployer.deploy(Derp);

  const instance = await Derp.deployed();
  const contract = instance.contract;

  const accounts = await web3.eth.getAccounts();
  const reviewer = accounts[1];
  const server = accounts[2];

  await contract.methods.refreshProducts().send({from: server});

  // JS needs BigInt for 64-bit integers
  const productId = (0n << 32n) | 1n;
  console.log(productId);
  await contract.methods.obtainReviewToken(reviewer, productId).send({from: server});

  const tokens = await contract.methods.getReviewTokens().call({from: reviewer});
  console.log(`Reviewer has ${tokens} tokens`);

  const products = await contract.methods.getProduct(productId).call({from: reviewer});
  console.log(products);

  // const reviewHash = 1234;
  // await contract.methods.makeReview(productId, reviewHash).send({from: reviewer});
};

