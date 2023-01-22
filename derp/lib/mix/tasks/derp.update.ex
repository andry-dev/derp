defmodule Mix.Tasks.Derp.Update do
  use Mix.Task
  alias JSON

  @shortdoc "Updates the contract ABI"

  @moduledoc """

  """

  @impl Mix.Task
  def run(_args) do
    extractedAbi = File.read!("../smart_contract/build/contracts/Derp.json")
    |> JSON.decode!() 
    |> Map.get("abi")
    |> JSON.encode!

    File.write!("assets/js/Derp-abi.json", extractedAbi)
    IO.puts("Saved new contract!")
  end
end
