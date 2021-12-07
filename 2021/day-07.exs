defmodule Day7 do
  def run(mode) do
    start = :erlang.system_time(:microsecond)

    data = read_input(mode)

    data |> part1() |> IO.puts()
    data |> part2() |> IO.puts()
    finish = :erlang.system_time(:microsecond)
    "took #{finish - start}μs" |> IO.puts()
  end

  def read_input(:test) do
    "16,1,2,0,4,2,7,1,2,14"
    |> String.split(",")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-07")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> Enum.at(0)
    |> String.split(",")
    |> prepare_data
  end

  def prepare_data(data),
    do:
      data
      |> Enum.map(&String.to_integer/1)
      |> Enum.frequencies()
      |> Map.to_list()

  def part1(data) do
    {min, max} = find_min_max(data, {nil, nil})
    binsearch_dist(nil, min, max, data, nil, :part1)
  end

  def part2(data) do
    {min, max} = find_min_max(data, {nil, nil})
    binsearch_dist(nil, min, max, data, nil, :part2)
  end

  def binsearch_dist(best, p, p, _, _, _), do: best

  def binsearch_dist(best, min_p, max_p, data, best_pos, part) do
    mid = div(max_p + min_p, 2)

    {a, b} =
      case best_pos do
        nil ->
          {
            find_dist(data, min_p, best, 0, part),
            find_dist(data, max_p, best, 0, part)
          }

        ^min_p ->
          {best, find_dist(data, max_p, best, 0, part)}

        ^max_p ->
          {find_dist(data, min_p, best, 0, part), best}
      end

    cond do
      a < b ->
        a |> binsearch_dist(min_p, mid, data, min_p, part)

      b < a ->
        b |> binsearch_dist(mid, max_p, data, max_p, part)

      mid == min_p ->
        a

      true ->
        a
        |> binsearch_dist(min_p, mid, data, min_p, part)
        |> binsearch_dist(mid, max_p, data, mid, part)
    end
  end

  def find_min_max([], acc), do: acc
  def find_min_max([{i, _} | rest], {nil, nil}), do: find_min_max(rest, {i, i})
  def find_min_max([{i, _} | rest], {min, max}) when i < min, do: find_min_max(rest, {i, max})
  def find_min_max([{i, _} | rest], {min, max}) when i > max, do: find_min_max(rest, {min, i})
  def find_min_max([_ | rest], acc), do: find_min_max(rest, acc)

  def find_dist([], _, nil, cand, _), do: cand
  def find_dist(_, _, min, cand, _) when cand > min, do: min
  def find_dist([], _, _, cand, _), do: cand

  def find_dist([{pos, crabs} | rest], dest, min, cand, :part1),
    do: find_dist(rest, dest, min, cand + abs(dest - pos) * crabs, :part1)

  def find_dist([{pos, crabs} | rest], dest, min, cand, :part2),
    do: find_dist(rest, dest, min, cand + burn(abs(dest - pos)) * crabs, :part2)

  def burn(n), do: div(n * (n - 1), 2)
end

Day7.run(:test)
Day7.run(:actual)
