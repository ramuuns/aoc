defmodule Day5 do

  def run(mode) do
    start = :erlang.system_time(:microsecond)

    data = read_input(mode)

    data |> part1() |> IO.puts()
    data |> part2() |> IO.puts()
    finish = :erlang.system_time(:microsecond)
    "took #{finish - start}μs" |> IO.puts()
  end

  def read_input(:test) do
    "0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-05")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data), do: prepare_data(data, [])
  def prepare_data([], acc), do: acc

  def prepare_data([row | rest], acc) do
    line = row |> parse_line()
    rest |> prepare_data([line | acc])
  end

  def parse_line(line) do
    line
    |> String.split(" -> ")
    |> Enum.map(fn
      coords ->
        coords
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
    end)
    |> List.to_tuple()
  end

  def part1(lines), do: count_lines({%{}, %{}, 0}, lines, :part1)

  def part2(lines), do: count_lines({%{}, %{}, 0}, lines, :all)

  def count_lines({_, _, count}, [], _), do: count

  def count_lines(grid_acc, [{{x, y1}, {x, y2}} | rest], mode),
    do:
      grid_acc
      |> add_to_grid(make_line(x, y1..y2 |> Enum.to_list(), :x, []))
      |> count_lines(rest, mode)

  def count_lines(grid_acc, [{{x1, y}, {x2, y}} | rest], mode),
    do:
      grid_acc
      |> add_to_grid(make_line(y, x1..x2 |> Enum.to_list(), :y, []))
      |> count_lines(rest, mode)

  def count_lines(grid_acc, [_ | rest], :part1), do: count_lines(grid_acc, rest, :part1)

  def count_lines(grid_acc, [{{x1, y1}, {x2, y2}} | rest], :all),
    do:
      grid_acc
      |> add_to_grid(make_line(x1..x2 |> Enum.to_list(), y1..y2 |> Enum.to_list(), :diag, []))
      |> count_lines(rest, :all)

  #  have the points be represented as a single integer, which will make the map insert/check faster (than if it's a tuple)

  def make_line(_, [], _, acc), do: acc
  def make_line(x, [y | rest], :x, acc), do: make_line(x, rest, :x, [x * 1000 + y | acc])
  def make_line(y, [x | rest], :y, acc), do: make_line(y, rest, :y, [x * 1000 + y | acc])

  def make_line([x | xrest], [y | yrest], :diag, acc),
    do: make_line(xrest, yrest, :diag, [x * 1000 + y | acc])

  #  the two map solution is slower than if there's an if there's just one map and we check the value in
  # and increment the counter if the value == 1, but looks a bit more elegant as it lets us outsource the
  # checking if we should add to the counter in a guard and makes the functions themselves shorter

  def add_to_grid(acc, []), do: acc

  def add_to_grid({_, at_least_two, _} = acc, [point | rest])
      when is_map_key(at_least_two, point),
      do: add_to_grid(acc, rest)

  def add_to_grid({at_least_one, at_least_two, cnt}, [point | rest])
      when is_map_key(at_least_one, point),
      do: add_to_grid({at_least_one, at_least_two |> Map.put(point, 1), cnt + 1}, rest)

  def add_to_grid({at_least_one, at_least_two, cnt}, [point | rest]),
    do: add_to_grid({at_least_one |> Map.put(point, 1), at_least_two, cnt}, rest)
end

Day5.run(:test)
Day5.run(:actual)
