defmodule Nomadex.Job do
  @moduledoc """
  Description of Nomad's job. More information available at
  <https://www.nomadproject.io/docs/job-specification/index.html>
  """

  defstruct [
    :id,
    :name,
    :datacenters,
    :payload,
    type: :service,
    priority: 50,
    meta: %{},
    constraints: [],
    all_at_once: false,
    task_groups: [],
  ]

  @type t :: %__MODULE__{
    id: String.t,
    name: String.t,
    datacenters: [String.t, ...],
    payload: iodata() | nil,
    type: :batch | :service | :system,
    meta: Nomadex.meta,
    constraints: list(),
    all_at_once: boolean(),
    task_groups: [Nomadex.TaskGroup.t, ...]
  }

  def new(name, datacenters, type \\ :service)
  def new(name, datacenters, type) when is_list(datacenters) do
    %__MODULE__{name: name, datacenters: datacenters, type: type}
  end
  def new(name, datacenter, type), do: new(name, [datacenter], type)

  @doc """
  Add `Nomadex.TaskGroup` to job specification
  """
  @spec add_task_group(t(), Nomadex.TaskGroup.t) :: t()
  def add_task_group(%__MODULE__{task_groups: groups} = job,
                     %Nomadex.TaskGroup{} = group) do
    %{job | task_groups: [group | groups]}
  end
end

defimpl Poison.Encoder, for: Nomadex.Job do
  def encode(job, opts) do
    payload = if job.payload do
      job.payload |> IO.iodata_to_binary() |> Base.encode64()
    else
      nil
    end

    %{
      "Datacenters" => job.datacenters,
      "Payload" => payload,
      "Type" => job.type |> to_string(),
      "Priority" => job.priority,
      "Meta" => job.meta,
      "Constraints" => job.constraints,
      "AllAtOnce" => job.all_at_once,
      "TaskGroups" => job.task_groups,
      "Name" => job.name,
      "ID" => job.id || job.name
    }
    |> Poison.Encoder.Map.encode(opts)
  end
end
