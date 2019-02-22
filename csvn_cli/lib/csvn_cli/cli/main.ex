defmodule CsvnCli.CLI.Main do
  alias Mix.Shell.IO, as: Shell

  def normalize() do
    welcome_message()
    Shell.prompt("Press Enter to continue")

    input_file = file_choice() |> Path.expand(".")

    process(input_file, validate_input_file(input_file))
  end

  defp welcome_message() do
    Shell.info("== CSV Normalizer CLI ==")
    Shell.info("Normalize CSV file")
  end

  defp file_choice() do
    Shell.cmd("clear")

    Shell.prompt("Choose CSV file to normalize:\n -->")
    |> String.trim()
    |> validate_input()
  end

  defp validate_input(_file_name = "") do
    Shell.info("File name is required")
    exit(:shutdown)
  end

  defp validate_input(filename), do: filename

  defp validate_input_file(file_name), do: File.exists?(file_name)

  defp process(_, _file_exists = false) do
    Shell.error("File does not exist")
    exit(:shutdown)
  end

  defp process(file_name, _file_exists = true) do
    Shell.info("Normalizing #{file_name} ...")
    CsvnService.normalize_file(file_name)
  end
end
