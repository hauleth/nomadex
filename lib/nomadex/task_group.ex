defmodule Nomadex.TaskGroup do
  @moduledoc """
  Describe task group of Nomad's job. More information available at
  <https://www.nomadproject.io/docs/job-specification/group.html>
  """

  defstruct [
    :name,
    constraints: [],
    meta: %{},
    tasks: []
  ]

  @type t :: %__MODULE__{
    constraints: list(),
    meta: Nomadex.meta,
    tasks: [Nomadex.Task.t, ...]
  }

  def new(name), do: %__MODULE__{name: name}

  @doc """
  Add `Nomadex.Task` to task group
  """
  @spec add_task(t(), Nomad.Task.t) :: t()
  def add_task(%__MODULE__{tasks: tasks} = group, %Nomadex.Task{} = task) do
    %{group | tasks: [task | tasks]}
  end
end

defimpl Poison.Encoder, for: Nomadex.TaskGroup do
  def encode(group, opts) do
    %{
      "Constraints" => group.constraints,
      "Count" => length(group.tasks),
      "Meta" => group.meta,
      "Tasks" => group.tasks,
      "Name" => group.name
    }
    |> Poison.Encoder.Map.encode(opts)
  end
end
