# csv-normalizer - Normalizer for CSV(comma-separated values) files
A tool that reads a CSV formatted file on `stdin` and emits a normalized CSV formatted file.

Normalized, in this case, means:

* The entire CSV file is in the UTF-8 character set.
* The Timestamp column will be formatted in ISO-8601 format.
* The Timestamp column is in US/Pacific time and it is converted into US/Eastern.
* All ZIP codes woud be formatted as 5 digits. If there are less than 5 digits, adds 0 as the prefix.
* All name columns would be converted to uppercase.
* The Address column would be passed through as is, except for Unicode validation.
* The columns `FooDuration` and `BarDuration` which are in HH:MM:SS.MS
  format (where MS is milliseconds); They are converted in to a floating point seconds format.
* The value of TotalDuration is calculated as the sum of FooDuration and BarDuration.
* The column "Notes" is free form text input by end-users. If there are invalid UTF-8 characters, 
  it replaces them with the Unicode Replacement Character.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. 

### Prerequisites

To run this tool you need to istall Elixir on your local machine. The instructions to install Elixir can be found [here](https://elixir-lang.org/install.html). This code was built and tested using Elixir 1.8.1 and Erlang/OTP 21

### Installing

Clone this repository

```
git clone https://github.com/gsarwate/csv-normalizer.git
```

The root of the repository (csv-normalizer) has following sub-directories.
* csvn_cli - Cline command line interface to normalizer. This interface uses `Elixir mix` to run the client
* csvn_service - The service component/library that provides functionality to normalize CSV file
* test_data - This directory contains sample csv data files that can be used for testing

Build the project to run/test locally

```
$ cd csv-normalizer/cvsn_cli
$ mix deps.get
$ cd csv-normalizer/csvn-service
$ mix deps.get
```

To run the application

```
$ cd csv-normalizer/cvsn_cli
$ mix csvn.start
```
Follow the prompts and choose input CSV file to normalize. The file path can be absolute or relative to current directory (csvn_cli) 

## Running the tests

The tests can be run as following:
```
$ cd csv-normalizer/csvn-service
$ mix test 
```

## Built With

* [Elixir](https://elixir-lang.org/) - The language
* [Erlang/OTP](https://www.erlang.org/) - The language and the platform
* [NimbleCSV](https://github.com/plataformatec/nimble_csv) - A simple and extremely fast CSV parsing/dumping library for Elixir
* [Timex](https://github.com/bitwalker/timex) - A complete date/time library for Elixir

## Authors

* **Ganesh Sarwate** - *Initial work* - [gsarwate](https://github.com/gsarwate)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Elixir/Erlang community for creating such a great language, platform, and amazing libraries
