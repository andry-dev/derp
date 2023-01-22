defmodule Derp.Contract do
  use Web3, rpc_endpoint: "http://localhost:9545"

  contract :Derp, contract_address: "0x12f1C2989a7cAa9B59a587d5412B3834b6f09f40", abi_path: Path.expand("../../assets/js/Derp-abi.json", __DIR__)
end
