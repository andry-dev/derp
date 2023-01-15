defmodule Mix.Tasks.Derp.Update do

  use Mix.Task

  @shortdoc "Updates the contract ABI"

  @moduledoc """

  """

  @impl Mix.Task
  def run(_args) do
    File.copy!("../smart_contract/build/contracts/Derp.json", "assets/js/Derp-abi.json")
  end
  
end
