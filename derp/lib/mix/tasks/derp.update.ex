defmodule Mix.Tasks.Derp.Update do
  use Mix.Task
  alias JSON

  @shortdoc "Updates the contract ABI"

  @moduledoc """

  """

  @impl Mix.Task
  def run(_args) do
    smart_contract_dir = "../smart_contract"

    contract =
      File.read!(smart_contract_dir <> "/build/contracts/Derp.json")
      |> Jason.decode!()

    first_network = 
      contract["networks"]
      |> Map.keys()
      |> Enum.at(0)

    network_info =
      contract["networks"][first_network]

    extractedAbi = 
      contract
      |> Map.get("abi")
      |> Jason.encode!

    File.write!("assets/js/Derp-abi.json", extractedAbi)

    File.write!("assets/js/Derp-info.json", Jason.encode!(network_info))
    IO.puts("Saved new contract!")
  end
end
