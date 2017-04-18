defmodule Nomadex do
  @moduledoc """
  Documentation for Nomadex.
  """

  use Tesla

  @type meta :: %{optional(bitstring()) => bitstring()}

  @api_version Application.get_env(:nomadex, __MODULE__)
               |> Keyword.get(:api_key, "/v1")

  plug Tesla.Middleware.BaseUrlFromConfig, otp_app: :nomadex, module: __MODULE__
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.DebugLogger

  def nodes_list, do: get(@api_version <> "/nodes").body

  def force_gc, do: put(@api_version <> "/system/gc", %{})

  @doc """
  Schedule new Nomad job.
  """
  @spec schedule_job(Nomadex.Job.t) :: {:ok, Tesla.Env.t}
  def schedule_job(%Nomadex.Job{} = job) do
    case post(@api_version <> "/jobs", job) do
      %{status: status} = response when status in 200..299 -> {:ok, response}
      response -> {:error, response}
    end
  end
end
