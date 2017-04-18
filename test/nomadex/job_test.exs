defmodule Nomadex.JobTest do
  use ExUnit.Case

  alias Nomadex.Job

  doctest Nomadex.Job

  # Test Task Groups {{{
  test "Nomadex.Job.add_task_group/2 adds new task group to job spec" do
    task_group = %Nomadex.TaskGroup{}
    job = %Job{}
          |> Job.add_task_group(task_group)

    assert task_group in job.task_groups
  end
  # }}}
end
