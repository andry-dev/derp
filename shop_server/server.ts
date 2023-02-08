const server = Deno.listen({ port: 8080 });

const products = [
  {
    id: 1,
    name: "Frigobar",
  },
  {
    id: 2,
    name: "Pineapple Speed",
  },
  {
    id: 3,
    name: "Imposter (sus)",
  },
  {
    id: 4,
    name: "MPS",
  },
  {
    id: 6,
    name: "ETH is a Token",
  },
];

const transactions = [
  {
    address: 0x1234,
    user_id: 1234,
    product_id: 1,
    date: new Date("2022-11-12T00:15:30.000Z"),
  },
  {
    address: 0x1234,
    user_id: 1234,
    product_id: 2,
    date: new Date("2022-12-29T00:12:00.000Z"),
  },
  {
    address: 0x1234,
    user_id: 1234,
    product_id: 3,
    date: new Date("2023-01-12T00:15:30.000Z"),
  },
  {
    address: 0x8FDaF496929f1d659a52289d2B4Fb484aaD0b08D,
    product_id: 2,
  },
  {
    address: 0x56BBccE3e1B496915f32c5485448d110cd61249cn,
    product_id: 5,
  },
  {
    address: 0x8FDaF496929f1d659a52289d2B4Fb484aaD0b08D,
    product_id: 3,
  },
  {
    address: 0x3a1f0b9d86006d003887e86ecb9ca35d1ae42fcdn,
    product_id: 10,
  },
  {
    address: 0x3a1f0b9d86006d003887e86ecb9ca35d1ae42fcdn,
    product_id: 6,
  },
];

const server_url = "http://localhost:8080";
const productQueryRoute = new URLPattern({
  pathname: "/check/:product",
});
const addressQueryRoute = new URLPattern({
  pathname: "/check",
});
const productInfoRoute = new URLPattern({
  pathname: "/info/:product",
});

console.log(products);
console.log(transactions);

for await (const conn of server) {
  // In order to not be blocking, we need to handle each connection individually
  // without awaiting the function
  serveHttp(conn);
}

async function serveBoughtProducts(requestEvent: Deno.RequestEvent) {
  const requestJSON = await requestEvent.request.json();

  const boughtProducts = transactions.filter((t) => {
    return t.address === Number(requestJSON.address);
  });

  // const boughtToday = boughtProducts.filter((p) => {
  //   const todayStart = new Date(Date.now());
  //   todayStart.setHours(0, 0, 0);
  //   const todayEnd = new Date(Date.now());
  //   todayEnd.setHours(23, 59, 59);
  //   return todayStart <= p.date && p.date <= todayEnd;
  // });

  // const body = {
  //   store_id: 1,
  //   products: boughtToday,
  // };

  const body = {
    boughtProducts: boughtProducts,
  };

  requestEvent.respondWith(
    Response.json(body, {
      status: 200,
      headers: new Headers({
        "Access-Control-Allow-Origin": "*",
      }),
    }),
  );
}

async function checkBoughtProduct(
  requestEvent: Deno.RequestEvent,
  product: number,
) {
  if (!requestEvent.request.body) {
    return requestEvent.respondWith(
      Response.json({ error: "Not a JSON request!" }, { status: 400 }),
    );
  }
  const requestJson = await requestEvent.request.json();

  const boughtProducts = transactions.filter((t) => {
    return t.address === BigInt(requestJson.address) &&
      t.product_id === product;
  });

  const body = {
    bought: boughtProducts.length > 0,
  };

  return requestEvent.respondWith(
    Response.json(body, {
      status: 200,
      headers: new Headers({
        "Access-Control-Allow-Origin": "*",
      }),
    }),
  );
}

async function getAllBoughtProducts(
  requestEvent: Deno.RequestEvent,
) {
  const reqBody = await requestEvent.request.json();

  const body = {
    data: transactions.filter((t) => {
      return t.address === BigInt(reqBody.address);
    }).map((t) => {
      return t.product_id;
    }),
  };

  return requestEvent.respondWith(
    Response.json(body, {
      status: 200,
      headers: new Headers({
        "Access-Control-Allow-Origin": "*",
      }),
    }),
  );
}

function getProductInfo(
  requestEvent: Deno.RequestEvent,
  productId: number,
) {
  const product = products.filter((p) => {
    return p.id === productId;
  });

  let data = {};

  if (product.length > 0) {
    const p = product[0];
    data = {
      name: p.name,
      url: `http://localhost:8080/p/${p.id}`,
    };
  }

  const body = {
    data: data,
  };

  return requestEvent.respondWith(
    Response.json(body, {
      status: 200,
      headers: new Headers({
        "Access-Control-Allow-Origin": "*",
      }),
    }),
  );
}

async function serveHttp(conn: Deno.Conn) {
  // This "upgrades" a network connection into an HTTP connection.
  const httpConn = Deno.serveHttp(conn);
  // Each request sent over the HTTP connection will be yielded as an async
  // iterator from the HTTP connection.
  for await (const requestEvent of httpConn) {
    console.log(requestEvent.request.url);

    let match = productQueryRoute.exec(requestEvent.request.url);
    if (match) {
      const groups = match.pathname.groups;
      checkBoughtProduct(requestEvent, Number(groups.product));
    } else if ((match = addressQueryRoute.exec(requestEvent.request.url))) {
      getAllBoughtProducts(requestEvent);
    } else if ((match = productInfoRoute.exec(requestEvent.request.url))) {
      getProductInfo(requestEvent, Number(match.pathname.groups.product));
    } else if (requestEvent.request.url === server_url) {
      serveBoughtProducts(requestEvent);
    } else {
      requestEvent.respondWith(
        Response.json({}, { status: 400 }),
      );
    }
  }
}
