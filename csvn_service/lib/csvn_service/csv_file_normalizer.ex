defmodule CsvnService.CsvFileNormalizer do
  alias NimbleCSV.RFC4180, as: CSV
  alias Timex
  alias Utils.Strip

  @file_headers [
    "Timestamp",
    "Address",
    "ZIP",
    "FullName",
    "FooDuration",
    "BarDuration",
    "TotalDuration",
    "Notes"
  ]
  @timestamp_format "%-m/%-d/%y %k:%M:%S %p"
  @timezone_shift 3
  @zip_length 5
  @zip_padding "0"

  def normalize_file(file_name) do
    file_path = Path.expand(file_name)
    dir_path = file_path |> Path.dirname()
    output_dir = dir_path <> "/output"

    unless File.exists?(output_dir) do
      IO.puts("Creating directory #{output_dir}")
      File.mkdir!(output_dir)
    end

    output_file =
      output_dir <> "/out_" <> (System.system_time(:second) |> Integer.to_string()) <> ".csv"

    try do
      read_csv_file(file_path)
      |> write_csv_file(output_file)

      IO.puts("Wrote file #{output_file} ...")
    rescue
      e in RuntimeError -> IO.puts("Failed to process file: " <> e.message)
      e in File.Error -> IO.inspect(e)
    end
  end

  defp read_csv_file(file_name) do
    IO.puts("reading file ...")

    File.read!(file_name)
    |> parse_utf()
    |> parse_csv_string()
    |> Enum.map(fn
      [timestamp, address, zip, full_name, foo_duration, bar_duration, _total_duration, notes] ->
        [
          parse_timestamp(timestamp),
          address,
          parse_zip(zip),
          parse_full_name(full_name),
          calculate_duration(foo_duration),
          calculate_duration(bar_duration),
          calculate_total_duration(foo_duration, bar_duration),
          notes
        ]
    end)
  end

  def write_csv_file(data, output_file) do
    data = [@file_headers | data]
    IO.puts("writing file ...")
    File.write!(output_file, data_to_csv(data))
  end

  defp data_to_csv(data) do
    data
    |> CSV.dump_to_iodata()
  end

  def parse_utf(str), do: Strip.strip_utf(str)

  def parse_csv_string(str), do: CSV.parse_string(str)

  def parse_timestamp(timestamp) do
    Timex.parse!(timestamp, @timestamp_format, :strftime)
    |> Timex.shift(hours: @timezone_shift)
    |> NaiveDateTime.to_iso8601()

    # If timezone is needed, convert to DateTime
    # |> Timex.to_datetime("America/New_York")
    # |> DateTime.to_iso8601()
  end

  def parse_zip(zip) do
    String.pad_leading(zip, @zip_length, @zip_padding)
  end

  def parse_full_name(full_name), do: String.upcase(full_name)

  def calculate_duration(duration) do
    [hour, min, sec, ms] = String.split(duration, [":", "."])

    i_hour = String.to_integer(hour) * 3600
    i_min = String.to_integer(min) * 60
    i_sec = String.to_integer(sec)
    i_ms = String.to_integer(ms)

    i_hour + i_min + i_sec + i_ms * 0.001
  end

  def calculate_total_duration(foo_duration, bar_duration),
    do: Float.round(calculate_duration(foo_duration) + calculate_duration(bar_duration), 3)

  # Above rounds the secods calculation to precision of 3,
  # if not needed remove precision parameter
  # do: calculate_duration(foo_duration) + calculate_duration(bar_duration)
end
