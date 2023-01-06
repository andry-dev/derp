const Derp = artifacts.require("Derp");
//const ProvableAPI = artifacts.require("provableAPI");
//const OraclizeAPI = artifacts.require("oraclizeAPI")


module.exports = function (deployer) {
  //deployer.deploy(ProvableAPI);
  //deployer.deploy(OraclizeAPI);
  deployer.deploy(Derp);
};
