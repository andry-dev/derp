defmodule Derp.Oracle.EventHandler do
  use Supervisor
  require Logger

  # Start process supervisor tree to check if we get new requests
  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_init_arg) do
    # Load contract and initialize it

    contract_abi = ExW3.Abi.load_abi("assets/js/Derp-abi.json")
    ExW3.Contract.start_link()
    ExW3.Contract.register(:Derp, abi: contract_abi)
    ExW3.Contract.at(:Derp, Application.fetch_env!(:derp, :contract_address))

    children = [
      __MODULE__.ReviewTokenRequest,
      __MODULE__.AllReviewTokenRequest
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  # Process that checks for review token requests for a specific set of products.
  defmodule ReviewTokenRequest do
    use Task, restart: :permanent

    def start_link(_arg) do
      {:ok, review_token_req_filter} = ExW3.Contract.filter(:Derp, "ReviewTokenRequested")

      state = [
        filter_id: review_token_req_filter
      ]

      Task.start_link(__MODULE__, :run, [state])
    end

    def run(state) do
      filter_id = state[:filter_id]
      {:ok, changes} = ExW3.Contract.get_filter_changes(filter_id)
      handle_changes(changes)
      :timer.sleep(1000)
      run(state)
    end

    def handle_changes([]) do
    end

    # If we have some changes from the event filter then we try to refresh the
    # review tokens for the user.
    def handle_changes(changes) do
      Logger.info("Got ReviewToken request!\n\t #{inspect(changes)}")

      Enum.map(changes, fn c ->
        address = c["address"]
        product = c["data"]["product"]

        Logger.info("Refreshing review tokens for #{address}")

        Derp.Oracle.refresh_reviews_for_user(address, product)
      end)
    end
  end

  defmodule AllReviewTokenRequest do
    use Task, restart: :permanent

    def start_link(_arg) do
      {:ok, filter_id} = ExW3.Contract.filter(:Derp, "AllReviewTokensRequested")

      state = [
        filter_id: filter_id
      ]

      Task.start_link(__MODULE__, :run, [state])
    end

    def run(state) do
      filter_id = state[:filter_id]
      {:ok, changes} = ExW3.Contract.get_filter_changes(filter_id)
      handle_changes(changes)
      :timer.sleep(1000)
      run(state)
    end

    def handle_changes([]) do
    end

    def handle_changes(changes) do
      Enum.each(changes, fn c ->
        address =
          ExW3.Address.from_bytes(c["data"]["account"])
          |> ExW3.Address.to_hex()
          |> IO.inspect()

        Derp.Oracle.refresh_reviews_for_user(address, [])
      end)
    end
  end
end
