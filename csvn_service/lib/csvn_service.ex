defmodule CsvnService do
  defdelegate normalize_file(file_name), to: CsvnService.CsvFileNormalizer
end
