defmodule Day17 do
  Code.compile_file("priority_queue.ex")

  def run(mode) do
    data = read_input(mode)

    [{1, data}, {2, data}]
    |> Task.async_stream(
      fn
        {1, data} -> {1, data |> part1(mode)}
        {2, data} -> {2, data |> part2}
      end,
      timeout: :infinity
    )
    |> Enum.reduce({0, 0}, fn
      {_, {1, res}}, {_, p2} -> {res, p2}
      {_, {2, res}}, {p1, _} -> {p1, res}
    end)
  end

  def read_input(:test) do
    "2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-17")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data |> make_grid(%{}, 0)
  end

  def make_grid([], grid, y), do: {grid, y - 1}
  def make_grid([row | rest], grid, y), do: make_grid(rest, row |> make_row(grid, y, 0), y + 1)

  def make_row("", grid, _, _), do: grid

  def make_row(<<c::utf8, rest::binary>>, grid, y, x),
    do: make_row(rest, grid |> Map.put({y, x}, c - ?0), y, x + 1)

  def part1({grid, max_yx}, _) do
    path_with_min_heat_loss(
      PriorityQueue.new()
      |> PriorityQueue.add(0, {{1, 0}, Map.get(grid, {1, 0}), {1, 0}, 1})
      |> PriorityQueue.add(0, {{0, 1}, Map.get(grid, {0, 1}), {0, 1}, 1}),
      grid,
      %{},
      {max_yx, max_yx},
      0,
      3
    )
  end

  def path_with_min_heat_loss(
        pq,
        grid,
        grid_min,
        {maxy, maxx} = tgt,
        min,
        max
      ) do
    {{{y, x}, heat_loss, dir, moves_this_dir}, pq} = pq |> PriorityQueue.pop_next()

    if {y, x} == tgt do
      heat_loss
    else
      # k = map_key({y, x}, dir, moves_this_dir)
      # is_member = Map.has_key?(grid_min, k)

      # if is_member do
      #  path_with_min_heat_loss(pq, grid, grid_min, tgt, min, max)
      # else
      #  grid_min = Map.put(grid_min, k, 1)

      next =
        [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]
        |> do_filter([], dir, y, x, moves_this_dir, min, max, maxy, maxx)

      {pq, grid_min} =
        next
        |> Enum.reduce({pq, grid_min}, fn
          {ndy, ndx} = nd, {pq, grid_min} ->
            p = {y + ndy, x + ndx}

            mc =
              if nd == dir do
                moves_this_dir + 1
              else
                1
              end

            hl = heat_loss + Map.get(grid, p)

            k = map_key(p, nd, mc)

            if not Map.has_key?(grid_min, k) or hl < Map.get(grid_min, k) do
              dist = md(p, tgt)

              heur =
                if dist > 20 do
                  dist * 2
                else
                  0
                end

              {
                pq
                |> PriorityQueue.add(
                  hl + heur,
                  {p, hl, nd, mc}
                ),
                grid_min |> Map.put(k, hl)
              }
            else
              {pq, grid_min}
            end
        end)

      path_with_min_heat_loss(pq, grid, grid_min, tgt, min, max)
      # end
    end
  end

  def md({y, x}, {y1, x1}) do
    abs(y - y1) + abs(x - x1)
  end

  def part2({grid, max_yx}) do
    path_with_min_heat_loss(
      PriorityQueue.new()
      |> PriorityQueue.add(0, {{1, 0}, Map.get(grid, {1, 0}), {1, 0}, 1})
      |> PriorityQueue.add(0, {{0, 1}, Map.get(grid, {0, 1}), {0, 1}, 1}),
      grid,
      %{},
      {max_yx, max_yx},
      4,
      10
    )
  end

  def do_filter([], ret, _, _, _, _, _, _, _, _), do: ret

  def do_filter([{ndy, ndx} | rest], ret, {dy, dx}, y, x, moves_this_dir, min, max, maxy, maxx)
      when ndy == -dy and ndx == -dx,
      do: do_filter(rest, ret, {dy, dx}, y, x, moves_this_dir, min, max, maxy, maxx)

  def do_filter([dir | rest], ret, dir, y, x, moves_this_dir, min, max, maxy, maxx)
      when moves_this_dir + 1 > max,
      do: do_filter(rest, ret, dir, y, x, moves_this_dir, min, max, maxy, maxx)

  def do_filter([nd | rest], ret, dir, y, x, moves_this_dir, min, max, maxy, maxx)
      when dir != nd and moves_this_dir < min,
      do: do_filter(rest, ret, dir, y, x, moves_this_dir, min, max, maxy, maxx)

  def do_filter([{0, -1} | rest], ret, dir, y, 0, moves_this_dir, min, max, maxy, maxx),
    do: do_filter(rest, ret, dir, y, 0, moves_this_dir, min, max, maxy, maxx)

  def do_filter([{-1, 0} | rest], ret, dir, 0, x, moves_this_dir, min, max, maxy, maxx),
    do: do_filter(rest, ret, dir, 0, x, moves_this_dir, min, max, maxy, maxx)

  def do_filter([{1, 0} | rest], ret, dir, y, x, moves_this_dir, min, max, y, maxx),
    do: do_filter(rest, ret, dir, y, x, moves_this_dir, min, max, y, maxx)

  def do_filter([{0, 1} | rest], ret, dir, y, x, moves_this_dir, min, max, maxy, x),
    do: do_filter(rest, ret, dir, y, x, moves_this_dir, min, max, maxy, x)

  def do_filter([nd | rest], ret, dir, y, x, moves_this_dir, min, max, maxy, maxx),
    do: do_filter(rest, [nd | ret], dir, y, x, moves_this_dir, min, max, maxy, maxx)

  def map_key({y, x}, {1, 0}, c), do: c + y * 10 + x * 10000
  def map_key({y, x}, {-1, 0}, c), do: c - y * 10 + x * 10000
  def map_key({y, x}, {0, 1}, c), do: c + y * 10 - x * 10000
  def map_key({y, x}, {0, -1}, c), do: c - y * 10 - x * 10000
end
