import { IPFS } from "https://deno.land/x/ipfs/mod.ts";
import Web3 from "https://deno.land/x/web3/mod.ts";
const contractAbi = await import("./smart_contract/build/contracts/Derp.json", {
  assert: { type: "json" },
});

const ipfs = new IPFS({});

const web3 = new Web3("http://localhost:9545");
const contract = new web3.eth.Contract(
  contractAbi.default.abi,
  contractAbi.default.networks[5777].address,
);

const serverAddress = (await web3.eth.getAccounts())[0];

const itemsToAdd = [
  {
    name: "Electric Creation",
    desc: "",
    price: 0,
    type: "PI",
    url:
      "https://e-cdn-images.dzcdn.net/images/cover/883348e91d506211ab48d1faa8e20898/264x264-000000-80-0-0.jpg",
  },
];

for (const item of itemsToAdd) {
  // const response = await ipfs.add(JSON.stringify(item));
  // const itemHash = response.path;
  //
  const body = new FormData();

  const file = JSON.stringify(item);

  body.append(
    "file",
    new Blob([file], { type: "text/plain" }),
    `Token ${item.name}.json`,
  );

  const json = await ipfs.add(body);
  const bytes32ItemHash = web3.utils.fromAscii(json.Hash);
  contract.methods.addProfileItem(
    bytes32ItemHash,
    item.price,
  ).send({ gas: 200_000, from: serverAddress });
}
