defmodule CsvFileNormalizerTest do
  use ExUnit.Case
  doctest CsvnService.CsvFileNormalizer

  alias CsvnService.CsvFileNormalizer, as: FileNormalizer

  describe "FileNormalizer.parse_timestamp/1" do
    test "converts AM timestamp to ISO8601 in EST PM time" do
      assert FileNormalizer.parse_timestamp("4/1/11 11:00:00 AM") == "2011-04-01T14:00:00"
    end

    test "converts timestamp on day change" do
      assert FileNormalizer.parse_timestamp("3/12/14 12:00:00 AM") == "2014-03-12T03:00:00"
    end

    test "converts PM timestamp to ISO8601 in EST" do
      assert FileNormalizer.parse_timestamp("2/29/16 12:11:11 PM") == "2016-02-29T15:11:11"
    end

    test "converts timestamp when day changes" do
      assert FileNormalizer.parse_timestamp("10/5/12 10:31:11 PM") == "2012-10-06T01:31:11"
    end

    test "converts timestamp when day and year changes" do
      assert FileNormalizer.parse_timestamp("12/31/16 11:59:59 PM") == "2017-01-01T02:59:59"
    end

    test "converts timestamp when year month and day are same i.e. treats input as mm/dd/yy..." do
      assert FileNormalizer.parse_timestamp("11/11/11 11:11:11 AM") == "2011-11-11T14:11:11"
    end
  end

  describe "FileNormalizer.parse_zip/1" do
    test "zip code should be formatted 5 digits" do
      assert FileNormalizer.parse_zip("94121") == "94121"
    end

    test "zip code is less than five digits, 1-digit should be padded with four zeroes" do
      assert FileNormalizer.parse_zip("1") == "00001"
    end

    test "zip code is less than five digits, 2-digit should be padded with three zeroes" do
      assert FileNormalizer.parse_zip("11") == "00011"
    end

    test "zip code is less than five digits, 4-digit should be padded with one zero" do
      assert FileNormalizer.parse_zip("1231") == "01231"
    end
  end

  describe "FileNormalizer.parse_full_name/1" do
    test "name should be conerted to uppercase" do
      assert FileNormalizer.parse_full_name("Monkey Alberto") == "MONKEY ALBERTO"
    end

    test "non-english name should be conerted to uppercase" do
      assert FileNormalizer.parse_full_name("Superman übertan") == "SUPERMAN ÜBERTAN"
    end

    test "non-english name should be conerted to uppercase (Japanese)" do
      assert FileNormalizer.parse_full_name("株式会社スタジオジブリ") == "株式会社スタジオジブリ"
    end
  end

  describe "Address validations" do
    test "address should be passed through as is" do
      assert FileNormalizer.parse_csv_string("""
             Timestamp, Address, ZIP
             4/1/11 11:00:00 AM,"123 4th St, Anywhere, AA",94121
             """) == [["4/1/11 11:00:00 AM", "123 4th St, Anywhere, AA", "94121"]]
    end
  end

  describe "FileNormalizer.calculate_duration/1" do
    test "foo duration should be coverted to seconds" do
      assert FileNormalizer.calculate_duration("1:23:32.123") == 5012.123
    end

    test "bar duration should be coverted to seconds" do
      assert FileNormalizer.calculate_duration("1:32:33.123") == 5553.123
    end
  end

  describe "FileNormalizer.calculate_total_duration/2" do
    test "total duraion is sum of foo duration and bar duration" do
      assert FileNormalizer.calculate_total_duration("1:23:32.123", "1:32:33:123") == 10565.246
    end
  end
end
