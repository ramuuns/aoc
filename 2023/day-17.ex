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
      PriorityQueue.new() |> PriorityQueue.add(0, {{0, 0}, 0, [{0, 0}], MapSet.new([{0, 0}])}),
      grid,
      Map.new([{{0, 0}, 0}]),
      {max_yx, max_yx}
    )
  end

  def path_with_min_heat_loss(pq, grid, grid_min, tgt) do
    {{{y, x}, heat_loss, path, seen}, pq} = pq |> PriorityQueue.pop_next()

    if {y, x} == tgt do
      heat_loss
    else
      next =
        [{y + 1, x}, {y - 1, x}, {y, x + 1}, {y, x - 1}]
        |> Enum.filter(fn c -> Map.has_key?(grid, c) and not MapSet.member?(seen, c) end)

      next =
        case path do
          [_, {py, px} | _] ->
            next |> Enum.filter(fn c -> c != {py, px} end)

          _ ->
            next
        end

      next =
        case path do
          [{y, _}, {y, _}, {y, _}, {y, _} | _] -> next |> Enum.filter(fn {ny, _} -> ny != y end)
          [{_, x}, {_, x}, {_, x}, {_, x} | _] -> next |> Enum.filter(fn {_, nx} -> nx != x end)
          _ -> next
        end

      next =
        next
        |> Enum.filter(fn {ny, nx} = p ->
          dir = {y - ny, x - nx}
          mc = pl(p, path)

          Map.get(grid_min, {p, dir, mc}, 1_000_000_000) > heat_loss + Map.get(grid, p)
        end)

      {pq, grid_min} =
        next
        |> Enum.reduce({pq, grid_min}, fn
          {ny, nx} = p, {pq, grid_min} ->
            dir = {y - ny, x - nx}
            mc = pl(p, path)
            hl = heat_loss + Map.get(grid, p)

            {
              pq
              |> PriorityQueue.add(
                hl + 1 * md(p, tgt),
                {p, hl, [p | path], seen |> MapSet.put(p)}
              ),
              grid_min |> Map.put({p, dir, mc}, hl)
            }
        end)

      path_with_min_heat_loss(pq, grid, grid_min, tgt)
    end
  end

  def md({y1, x1}, {y2, x2}) do
    abs(y1 - y2) + abs(x1 - x2)
  end

  def part2({grid, max_yx}) do
    path_with_min_heat_loss_ultra(
      PriorityQueue.new() |> PriorityQueue.add(0, {{0, 0}, 0, [{0, 0}], MapSet.new([{0, 0}])}),
      grid,
      Map.new([{{0, 0}, 0}]),
      {max_yx, max_yx}
    )
  end

  def path_with_min_heat_loss_ultra(pq, grid, grid_min, tgt) do
    {{{y, x}, heat_loss, path, seen}, pq} = pq |> PriorityQueue.pop_next()

    if {y, x} == tgt do
      heat_loss
    else
      next =
        [{y + 1, x}, {y - 1, x}, {y, x + 1}, {y, x - 1}]
        |> Enum.filter(fn c -> Map.has_key?(grid, c) and not MapSet.member?(seen, c) end)

      next =
        case path do
          [_, {py, px} | _] ->
            next |> Enum.filter(fn c -> c != {py, px} end)

          _ ->
            next
        end

      # enforce min 4
      next =
        case path do
          [{y, _}, {y, _}, {y, _}, {y, _}, {y, _} | _] ->
            next

          [{_, x}, {_, x}, {_, x}, {_, x}, {_, x} | _] ->
            next

          [{0, 0}] ->
            next

          [_, {py, px} | _] ->
            next
            |> Enum.filter(fn {ny, nx} ->
              ny - y == y - py and nx - x == x - px
            end)
        end

      # enforce max 10
      next =
        case path do
          [
            {y, _},
            {y, _},
            {y, _},
            {y, _},
            {y, _},
            {y, _},
            {y, _},
            {y, _},
            {y, _},
            {y, _},
            {y, _} | _
          ] ->
            next |> Enum.filter(fn {ny, _} -> ny != y end)

          [
            {_, x},
            {_, x},
            {_, x},
            {_, x},
            {_, x},
            {_, x},
            {_, x},
            {_, x},
            {_, x},
            {_, x},
            {_, x} | _
          ] ->
            next |> Enum.filter(fn {_, nx} -> nx != x end)

          _ ->
            next
        end

      next =
        next
        |> Enum.filter(fn {ny, nx} = p ->
          dir = {y - ny, x - nx}
          mc = pl(p, path)

          Map.get(grid_min, {p, dir, mc}, 1_000_000_000) > heat_loss + Map.get(grid, p)
        end)

      {pq, grid_min} =
        next
        |> Enum.reduce({pq, grid_min}, fn
          {ny, nx} = p, {pq, grid_min} ->
            dir = {y - ny, x - nx}
            mc = pl(p, path)
            hl = heat_loss + Map.get(grid, p)

            {
              pq
              |> PriorityQueue.add(
                hl + 3 * md(p, tgt),
                {p, hl, [p | path], seen |> MapSet.put(p)}
              ),
              grid_min |> Map.put({p, dir, mc}, hl)
            }
        end)

      path_with_min_heat_loss_ultra(pq, grid, grid_min, tgt)
    end
  end

  def pl({ny, nx}, path) do
    case path do
      [{^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _} | _] -> 10
      [{_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx} | _] -> 10
      [{^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _} | _] -> 9
      [{_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx} | _] -> 9
      [{^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _} | _] -> 8
      [{_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx} | _] -> 8
      [{^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _} | _] -> 7
      [{_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx} | _] ->  7
      [{^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _} | _] -> 6
      [{_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx} | _] -> 6
      [{^ny, _}, {^ny, _}, {^ny, _}, {^ny, _}, {^ny, _} | _] -> 5
      [{_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx} | _] -> 5
      [{^ny, _}, {^ny, _}, {^ny, _}, {^ny, _} | _] -> 4
      [{_, ^nx}, {_, ^nx}, {_, ^nx}, {_, ^nx} | _] -> 4
      [{^ny, _}, {^ny, _}, {^ny, _} | _] -> 3
      [{_, ^nx}, {_, ^nx}, {_, ^nx} | _] -> 3
      [{^ny, _}, {^ny, _} | _] -> 2
      [{_, ^nx}, {_, ^nx} | _] -> 2
      [{^ny, _} | _] -> 1
      [{_, ^nx} | _] -> 1
      _ -> 0
    end
  end
end
