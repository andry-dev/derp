const server = Deno.listen({ port: 8080 });

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
    address: 0xbcd0bb18140a21ada3c9d7dd494c173e53a3640fn,
    product_id: 2,
  },
];

const server_url = "http://localhost:8080";
const productQueryRoute = new URLPattern({
  pathname: "/check/:product",
});

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

    const match = productQueryRoute.exec(requestEvent.request.url);
    if (match) {
      const groups = match.pathname.groups;
      checkBoughtProduct(requestEvent, Number(groups.product));
    } else if (requestEvent.request.url === server_url) {
      serveBoughtProducts(requestEvent);
    } else {
      requestEvent.respondWith(
        Response.json({}, { status: 400 }),
      );
    }
  }
}
