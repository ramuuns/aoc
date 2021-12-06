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

  def prepare_data([], acc),
    do: [acc["0"], acc["1"], acc["2"], acc["3"], acc["4"], acc["5"], acc["6"], acc["7"], acc["8"]]

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

  def part1(fish_list), do: simulate_next_day(fish_list, 80)
  def part2(fish_list), do: simulate_next_day(fish_list, 256)

  def simulate_next_day(fish_list, 0), do: fish_list |> Enum.sum()

  def simulate_next_day([zero | fish_list], d) do
    fish_list
    |> do_one_day(zero, 0, [])
    |> simulate_next_day(d - 1)
  end

  def do_one_day([], zero, _, next_day), do: [zero | next_day] |> Enum.reverse()
  def do_one_day([h | t], zero, 6, next_day), do: do_one_day(t, zero, 7, [h + zero | next_day])
  def do_one_day([h | t], zero, n, next_day), do: do_one_day(t, zero, n + 1, [h | next_day])
end

Day6.run(:test)
Day6.run(:actual)
