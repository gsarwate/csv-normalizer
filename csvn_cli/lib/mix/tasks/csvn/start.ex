defmodule Mix.Tasks.Csvn.Start do
  use Mix.Task

  def run(_), do: CsvnCli.CLI.Main.normalize()
end
