defmodule Nomadex.Task do
  @moduledoc """
  Nomad task definition. More information available at
  <https://www.nomadproject.io/docs/job-specification/task.html>
  """

  defstruct [
    :driver,
    :name,
    user: nil,
    leader: false,
    meta: %{},
    services: nil,
    env: %{},
    constraints: [],
    config: %{},
    artifacts: [],
    payload_file: nil,
  ]

  @type driver :: atom()
  @type t :: %__MODULE__{
    driver: driver(),
    name: String.t,
    user: String.t | nil,
    leader: boolean(),
    meta: Nomadex.meta,
    services: list() | nil,
    env: %{optional(String.t) => String.t},
    constraints: list(),
    config: map(),
    artifacts: list(map()),
    payload_file: bitstring(),
  }

  @doc """
  Create new `Nomadex.Task` with provided driver
  """
  @spec new(driver()) :: t()
  def new(driver), do: %__MODULE__{driver: driver}

  def raw_exec(command, args \\ []) do
    %__MODULE__{
      name: command,
      driver: :raw_exec,
      config: %{
        command: command,
        args: args,
      }
    }
  end

  @doc """
  Add artifact required to run task.

  Options:

  - `:source` - source of the artifact
  - `:dest` - destination of the artifact relative to the task's directory
  - `:opts` - additional options, to be found [here](https://github.com/hashicorp/go-getter/tree/ef5edd3d8f6f482b775199be2f3734fd20e04d4a#protocol-specific-options-1)

  ## Examples

      iex> task = Nomadex.Task.new(:exec)
      ...>        |> Nomadex.Task.add_artifact(source: "http://example.com/task.tgz")
      iex> hd(task.artifacts)
      %{
        "GetterOptions" => %{},
        "GetterSource" => "http://example.com/task.tgz",
        "RelativeDest" => "local/"
      }
  """
  @spec add_artifact(t(), keyword()) :: t()
  def add_artifact(%__MODULE__{artifacts: artifacts} = task, opts) do
    source = Keyword.fetch!(opts, :source)
    dest = Keyword.get(opts, :dest, "local/")
    options = Keyword.get(opts, :opts, %{})

    artifact = %{
      "GetterSource" => source,
      "RelativeDest" => dest,
      "GetterOptions" => options
    }

    %{task | artifacts: [artifact | artifacts]}
  end
end

defimpl Poison.Encoder, for: Nomadex.Task do
  def encode(task, opts) do
    dispatch_payload = if task.payload_file do
      %{"File" => task.payload_file}
    end

    %{
      "Name" => task.name,
      "Artifacts" => task.artifacts,
      "Config" => task.config,
      "Driver" => task.driver |> to_string,
      "DispatchPayload" => dispatch_payload,
      "leader" => task.leader,
      "User" => task.user,
      "Meta" => task.meta,
      "Services" => task.services,
    }
    |> Poison.Encoder.Map.encode(opts)
  end
end
