defmodule Day15 do
  Code.compile_file("priority_queue.ex")

  def run(mode) do
    data = read_input(mode)

    {
      data |> part1(),
      data |> part2()
    }
  end

  def read_input(:test) do
    "1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-15")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data), do: prepare_data(data, %{}, 0, 0)

  def prepare_data([], grid, y, x), do: {grid, y - 1, x}

  def prepare_data([row | rest], grid, y, _) do
    {grid, x} = prepare_row(row |> String.split("", trim: true), grid, y, 0)
    prepare_data(rest, grid, y + 1, x)
  end

  def prepare_row([], grid, _, x), do: {grid, x - 1}

  def prepare_row([i | rest], grid, y, x),
    do: prepare_row(rest, grid |> Map.put({x, y}, String.to_integer(i)), y, x + 1)

  def part1({grid, tgty, tgtx}) do
    a_star_this_sucker(
      PriorityQueue.new() |> PriorityQueue.add(0, {0, {0, 0}}),
      grid,
      MapSet.new(),
      {tgtx, tgty},
      false,
      {tgtx + 1, tgty + 1}
    )
  end

  def part2({grid, tgty, tgtx}) do
    a_star_this_sucker(
      PriorityQueue.new() |> PriorityQueue.add(0, {0, {0, 0}}),
      grid,
      MapSet.new(),
      {(tgtx + 1) * 5 - 1, (tgty + 1) * 5 - 1},
      true,
      {tgtx + 1, tgty + 1}
    )
  end

  def a_star_this_sucker(
        pq,
        grid,
        seen,
        {tgtx, tgty} = tgt,
        expand?,
        {orig_sizex, orig_sizey} = size
      ) do
    {{weight, {x, y} = coord}, pq} = pq |> PriorityQueue.pop_next()

    cond do
      MapSet.member?(seen, coord) ->
        a_star_this_sucker(pq, grid, seen, tgt, expand?, size)

      x == tgtx and y == tgty ->
        weight

      true ->
        grid =
          if expand? do
            [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
            |> Enum.reduce(grid, fn
              c, grid when is_map_key(grid, c) ->
                grid

              {-1, _}, grid ->
                grid

              {_, -1}, grid ->
                grid

              {x, _}, grid when x == tgtx + 1 ->
                grid

              {_, y}, grid when y == tgty + 1 ->
                grid

              {x, y} = c, grid ->
                grid
                |> Map.put(
                  c,
                  rem(
                    grid[{rem(x, orig_sizex), rem(y, orig_sizey)}] + div(x, orig_sizex) +
                      div(y, orig_sizey) - 1,
                    9
                  ) + 1
                )
            end)
          else
            grid
          end

        [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
        |> Enum.filter(fn c -> grid |> Map.has_key?(c) end)
        |> Enum.reduce(pq, fn
          {x, y} = c, pq ->
            pq
            |> PriorityQueue.add(
              weight + grid[c] - (tgtx - x) - (tgty - y),
              {weight + grid[c], c}
            )
        end)
        |> a_star_this_sucker(grid, seen |> MapSet.put(coord), tgt, expand?, size)
    end
  end

  def five_x_this_grid(grid, {sizex, sizey}) do
    og_grid = grid

    0..4
    |> Enum.reduce(
      grid,
      fn y, grid ->
        0..4
        |> Enum.reduce(
          grid,
          fn x, grid ->
            og_grid
            |> Enum.reduce(grid, fn {{gx, gy}, i}, grid ->
              grid |> Map.put({gx + sizex * x, gy + sizey * y}, rem(i - 1 + x + y, 9) + 1)
            end)
          end
        )
      end
    )
  end
end
