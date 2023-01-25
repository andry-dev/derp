defmodule Derp.Oracle.EventHandler do
  use Supervisor
  require Logger

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_init_arg) do
    contract_abi = ExW3.Abi.load_abi("assets/js/Derp-abi.json")
    ExW3.Contract.start_link()
    ExW3.Contract.register(:Derp, abi: contract_abi)
    ExW3.Contract.at(:Derp, Application.fetch_env!(:derp, :contract_address))

    children = [
      __MODULE__.ReviewTokenRequest,
      # Derp.Oracle.AllReviewTokenRequest,
      __MODULE__.RefreshProductRequest
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

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

    def handle_changes(changes) do
      Logger.info("Got ReviewToken request!\n\t #{inspect(changes)}")

      Enum.map(changes, fn c ->
        address = Map.get(c, "address")
        product = Map.get(c, "data") |> Map.get("product")

        Logger.info("Refreshing review tokens for #{address}")

        case Derp.Oracle.refresh_reviews_for_user(address, product) do
          {:ok, bought?} -> {:ok, address, product, bought?}
          error -> error
        end
      end)
      |> Enum.each(fn
        {:ok, address, product, true} -> reward_review_token(address, product)
        {:ok, address, product, false} -> Logger.info("Product #{product} not bought by #{address}.")
      end)
    end

    defp reward_review_token(address, product) do
      options = %{
        #from: Application.fetch_env!(:derp, :server_address, Enum.at(ExW3.accounts, 0)),

        from: Enum.at(ExW3.accounts, 0),
        gas: 100_000
      }

      {:ok, int_address} = ExW3.Utils.hex_to_integer(address)

      {store_id, local_product_id} = Derp.Oracle.decode_product_id(product)

      case ExW3.Contract.send(:Derp, :rewardReviewToken, [int_address, product], options) do
        {:ok, result} ->
          Logger.info("Rewarded user #{address} for product #{product} (#{store_id}, #{local_product_id})")
          {:ok, result}
      end
    end
  end


  defmodule AllReviewTokenRequest do
    use Task, restart: :permanent
  end

  defmodule RefreshProductRequest do
    use Task, restart: :permanent

    def start_link(_arg) do
    {:ok, product_req_filter} = ExW3.Contract.filter(:Derp, "ProductRefreshRequested")

      state = [
        filter_id: product_req_filter
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
      Logger.info("Got ProductRefresh request!\n\t #{inspect(changes)}")
    end
  end
end
