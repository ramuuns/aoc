defmodule Day6 do
  def run(mode) do
    start = :erlang.system_time(:microsecond)

    data = read_input(mode)

    data |> part1() |> IO.puts()
    data |> part2() |> IO.puts()
    finish = :erlang.system_time(:microsecond)
    "took #{finish - start}μs" |> IO.puts()
  end

  def read_input(:test) do
    "3,4,3,1,2"
    |> String.split(",")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-06")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> Enum.at(0)
    |> String.split(",")
    |> prepare_data
  end

  def prepare_data(data),
    do:
      prepare_data(data, %{
        "8" => 0,
        "7" => 0,
        "6" => 0,
        "5" => 0,
        "4" => 0,
        "3" => 0,
        "2" => 0,
        "1" => 0,
        "0" => 0
      })

  def prepare_data([], acc), do: acc

  def prepare_data([fish | rest], acc) do
    rest
    |> prepare_data(
      acc
      |> Map.put(
        fish,
        acc[fish] + 1
      )
    )
  end

  def part1(fish_map), do: simulate_next_day(fish_map, 80)
  def part2(fish_map), do: simulate_next_day(fish_map, 256)

  def simulate_next_day(fish_map, 0), do: fish_map |> Map.values() |> Enum.sum()

  def simulate_next_day(fish_map, d) do
    %{
      "8" => fish_map["0"],
      "7" => fish_map["8"],
      "6" => fish_map["7"] + fish_map["0"],
      "5" => fish_map["6"],
      "4" => fish_map["5"],
      "3" => fish_map["4"],
      "2" => fish_map["3"],
      "1" => fish_map["2"],
      "0" => fish_map["1"]
    }
    |> simulate_next_day(d - 1)
  end
end

Day6.run(:test)
Day6.run(:actual)
