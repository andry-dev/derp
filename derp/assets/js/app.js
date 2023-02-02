// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "bootstrap";
// import "../css/app.css";

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

import Alpine from "alpinejs";
window.Alpine = Alpine;

import contractAbi from "./Derp-abi.json";
import contractInfo from "./Derp-info.json";

import { create } from "ipfs-http-client";

// connect to the default API address http://localhost:5001
window.ipfs = create({ url: "http://127.0.0.1:5001/api/v0" });

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute(
  "content",
);
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()

window.liveSocket = liveSocket;

import Web3 from "web3";

const ethEnabled = async () => {
  if (window.ethereum) {
    await window.ethereum.request({ method: "eth_requestAccounts" });
    window.web3 = new Web3(window.ethereum);
    window.contract = new window.web3.eth.Contract(contractAbi);
    window.contract.options.from = window.ethereum.selectedAddress;
    window.contract.options.address = contractInfo.address;

    return true;
  }
  return false;
};

window.ethEnabled = ethEnabled;
window.queryProductInfo = async function (store, localProductId) {
  switch (Number(store)) {
    case 0: {
      const response = await fetch(
        `http://localhost:8080/info/${localProductId}`,
      );
      const respJson = await response.json();
      console.log(respJson);

      return respJson.data;
    }
    default:
      return { name: "<Unknown>", url: "" };
  }
};

window.catFromIpfs = async function (cid, convert = false) {
  let asciiAddress = cid;

  if (!convert) {
    asciiAddress = web3.utils.hexToAscii(cid);
  }

  //console.log(asciiAddress)
  const stream = await ipfs.cat(asciiAddress);

  const decoder = new TextDecoder();
  let data = "";

  for await (const chunk of stream) {
    // chunks of data are returned as a Uint8Array, convert it back to a string
    data += decoder.decode(chunk, { stream: true });
  }

  return data;
};

Alpine.start();
