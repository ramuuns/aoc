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

  def part1(lines), do: count_lines(lines, {%{}, 0}, :part1)

  def part2(lines), do: count_lines(lines, {%{}, 0}, :all)

  def count_lines([], {_, count}, _), do: count

  def count_lines([{{x, y1}, {x, y2}} | rest], grid, mode),
    do: count_lines(rest, add_to_grid(grid, make_line(x, y1..y2 |> Enum.to_list(), :x, [])), mode)

  def count_lines([{{x1, y}, {x2, y}} | rest], grid, mode),
    do: count_lines(rest, add_to_grid(grid, make_line(y, x1..x2 |> Enum.to_list(), :y, [])), mode)

  def count_lines([_ | rest], grid, :part1), do: count_lines(rest, grid, :part1)

  def count_lines([{{x1, y1}, {x2, y2}} | rest], grid, :all),
    do:
      count_lines(
        rest,
        add_to_grid(
          grid,
          make_line(x1..x2 |> Enum.to_list(), y1..y2 |> Enum.to_list(), :diag, [])
        ),
        :all
      )

  def make_line(_, [], _, acc), do: acc
  def make_line(x, [y | rest], :x, acc), do: make_line(x, rest, :x, [{x, y} | acc])
  def make_line(y, [x | rest], :y, acc), do: make_line(y, rest, :y, [{x, y} | acc])

  def make_line([x | xrest], [y | yrest], :diag, acc),
    do: make_line(xrest, yrest, :diag, [{x, y} | acc])

  def add_to_grid(grid, []), do: grid

  def add_to_grid({grid, cnt}, [point | rest]) when is_map_key(grid, point) do
    current = grid |> Map.get(point)

    add_to_grid(
      {grid |> Map.put(point, current + 1),
       if current == 1 do
         cnt + 1
       else
         cnt
       end},
      rest
    )
  end

  def add_to_grid({grid, cnt}, [point | rest]),
    do: add_to_grid({grid |> Map.put(point, 1), cnt}, rest)
end

Day5.run(:test)
Day5.run(:actual)
