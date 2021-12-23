defmodule Day23 do
  Code.compile_file("priority_queue.ex")

  def run(mode) do
    data = read_input(mode)

    [{1, data}, {2, data}]
    |> Task.async_stream(
      fn
        {1, data} -> {1, data |> part1}
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
    "#############
#...........#
###B#C#B#D###
  #A#D#C#A#
  #########"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-23")
    |> Enum.map(fn n -> n |> String.trim_trailing() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data
    |> Enum.reduce({{%{}, []}, 0}, fn
      row, {{grid, positions}, y} ->
        {
          row
          |> String.split("", trim: true)
          |> Enum.reduce({{grid, positions}, 0}, fn
            "#", {{grid, positions}, x} ->
              {{grid |> Map.put({x, y}, "#"), positions}, x + 1}

            ".", {{grid, positions}, x} ->
              {{grid |> Map.put({x, y}, "."), positions}, x + 1}

            " ", {{grid, positions}, x} ->
              {{grid, positions}, x + 1}

            c, {{grid, positions}, x} ->
              {{grid |> Map.put({x, y}, c), [{x, y} | positions]}, x + 1}
          end)
          |> then(fn {gp, _} -> gp end),
          y + 1
        }
    end)
    |> then(fn {gp, _} -> gp end)
  end

  def part1({grid, pos}) do
    pos
    |> Enum.reduce({PriorityQueue.new(), %{}}, fn
      p, {pq, seen} ->
        if can_move?(p, grid) do
          make_all_the_moves(pq, p, grid, pos, 0, seen)
        else
          {pq, seen}
        end
    end)
    #      |> print_all_the_pq(4)
    |> find_min_energy(4)
  end

  def print_all_the_pq({pq, _}, maxy) do
    case pq |> PriorityQueue.pop_next() do
      {nil, _} ->
        0

      {{grid, pos, cost}, pq} ->
        print_grid(grid, cost, maxy)
        pos |> IO.inspect()
        {pq, nil} |> print_all_the_pq(maxy)
    end
  end

  def part2({grid, pos}) do
    grid =
      grid
      |> Enum.filter(fn {{_, y}, _} -> y in [3, 4] end)
      |> Enum.reduce(grid, fn {{x, y}, v}, grid -> grid |> Map.put({x, y + 2}, v) end)

    pos =
      pos
      |> Enum.map(fn
        {x, 3} -> {x, 5}
        p -> p
      end)

    pos = [{3, 4}, {3, 3}, {5, 4}, {5, 3}, {7, 4}, {7, 3}, {9, 4}, {9, 3} | pos]

    grid =
      grid
      |> Map.put({3, 3}, "D")
      |> Map.put({3, 4}, "D")
      |> Map.put({5, 3}, "C")
      |> Map.put({5, 4}, "B")
      |> Map.put({7, 3}, "B")
      |> Map.put({7, 4}, "A")
      |> Map.put({9, 3}, "A")
      |> Map.put({9, 4}, "C")

    #    print_grid(grid,0,6)
    pos
    |> Enum.reduce({PriorityQueue.new(), %{}}, fn
      p, {pq, seen} ->
        if can_move?(p, grid) do
          make_all_the_moves(pq, p, grid, pos, 0, seen)
        else
          {pq, seen}
        end
    end)
    #      |> print_all_the_pq(6)
    |> find_min_energy(6)
  end

  def remove_pos(pos, {x, y}), do: pos |> Enum.filter(fn {xx, yy} -> xx != x or yy != y end)

  def make_all_the_moves(pq, p, grid, pos, cost, seen) do
    me = grid[p]

    cond do
      in_hallway?(p, grid) ->
        dx = dest_x(me)

        dy =
          if grid[{dx, 4}] == "#" do
            if grid[{dx, 3}] == ".", do: 3, else: 2
          else
            [5, 4, 3, 2]
            |> Enum.reduce(0, fn
              y, 0 -> if grid[{dx, y}] == ".", do: y, else: 0
              _, y -> y
            end)
          end

        newgrid = grid |> Map.put(p, ".") |> Map.put({dx, dy}, me)
        move_cost = count_moves(p, {dx, dy}) * energy(me)

        case seen |> Map.get(newgrid) do
          c when is_integer(c) and c <= cost + move_cost ->
            {pq, seen}

          _ ->
            {
              pq
              |> PriorityQueue.add(
                move_cost + cost,
                {newgrid, [{dx, dy} | pos |> remove_pos(p)], move_cost + cost}
              ),
              seen |> Map.put(newgrid, move_cost + cost)
            }
        end

      true ->
        [1, 2, 4, 6, 8, 10, 11]
        |> Enum.filter(fn dx -> path_is_clear?(p, {dx, 1}, grid) end)
        |> Enum.reduce({pq, seen}, fn dx, {pq, seen} ->
          newgrid = grid |> Map.put(p, ".") |> Map.put({dx, 1}, me)
          dy = 1
          move_cost = count_moves(p, {dx, dy}) * energy(me)

          case seen |> Map.get(newgrid) do
            c when is_integer(c) and c <= cost + move_cost ->
              {pq, seen}

            _ ->
              {
                pq
                |> PriorityQueue.add(
                  move_cost + cost,
                  {newgrid, [{dx, dy} | pos |> remove_pos(p)], move_cost + cost}
                ),
                seen |> Map.put(newgrid, move_cost + cost)
              }
          end
        end)
    end
  end

  def print_grid(grid, cost, maxy) do
    IO.puts("\nCost so far: #{cost}")

    for y <- 0..maxy do
      line = for x <- 0..12, do: grid[{x, y}] || " "
      IO.puts(line)
    end
  end

  def find_min_energy({pq, seen}, maxy) do
    {{grid, pos, cost}, pq} = pq |> PriorityQueue.pop_next()

    cond do
      is_destination?(grid, pos) ->
        cost

      cost > Map.get(seen, grid) ->
        #       IO.puts("skipping this one") 
        {pq, seen} |> find_min_energy(maxy)

      true ->
        #        print_grid(grid, cost, maxy)
        pos
        |> Enum.reduce({pq, seen}, fn
          p, {pq, seen} ->
            if can_move?(p, grid) do
              #        p |> IO.inspect(label: "can move #{ grid[p] }")
              make_all_the_moves(pq, p, grid, pos, cost, seen)
            else
              #       p |> IO.inspect(label: "cannot move #{ grid[p] }")
              {pq, seen}
            end
        end)
        # |> print_all_the_pq
        |> find_min_energy(maxy)
    end
  end

  def is_destination?(grid, pos) do
    pos
    |> Enum.reduce(true, fn
      {x, y}, is_it? -> is_it? and (y > 1 and in_dest_room?({x, y}, grid))
    end)
  end

  def count_moves({sx, sy}, {dx, dy}) do
    sy - 1 + (dy - 1) + abs(sx - dx)
  end

  def energy("A"), do: 1
  def energy("B"), do: 10
  def energy("C"), do: 100
  def energy("D"), do: 1000

  def can_move?(pos, grid) do
    cond do
      is_surrounded?(pos, grid) -> false
      in_dest_room?(pos, grid) and only_my_kind_here?(pos, grid) -> false
      in_hallway?(pos, grid) -> can_move_to_dest_room?(pos, grid)
      true -> can_move_to_hallway?(pos, grid) or can_move_to_dest_room?(pos, grid)
    end
  end

  def is_surrounded?({x, y}, grid) do
    [grid[{x - 1, y}], grid[{x + 1, y}], grid[{x, y - 1}], grid[{x, y + 1}]]
    |> Enum.any?(fn c -> c == "." end)
    |> Kernel.not()
  end

  def in_dest_room?({x, y}, grid) do
    me = grid[{x, y}]

    (me == "A" and x == 3) or
      (me == "B" and x == 5) or
      (me == "C" and x == 7) or
      (me == "D" and x == 9)
  end

  def only_my_kind_here?({x, y}, grid) do
    me = grid[{x, y}]

    grid[{x, 2}] in [".", me] and
      grid[{x, 3}] in [".", me] and
      grid[{x, 4}] in ["#", ".", me] and
      grid[{x, 5}] in [nil, ".", me]
  end

  def in_hallway?({_, 1}, _), do: true
  def in_hallway?(_, _), do: false

  def can_move_to_dest_room?({x, y}, grid) do
    me = grid[{x, y}]
    dx = dest_x(me)

    grid[{dx, 2}] == "." and
      grid[{dx, 3}] in [".", me] and
      grid[{dx, 4}] in ["#", ".", me] and
      grid[{dx, 5}] in [nil, ".", me] and
      path_is_clear?({x, y}, {dx, 3}, grid)
  end

  def dest_x("A"), do: 3
  def dest_x("B"), do: 5
  def dest_x("C"), do: 7
  def dest_x("D"), do: 9

  def path_is_clear?({sx, _}, {dx, _}, grid) do
    sx..dx
    |> Enum.reduce(true, fn
      x, clear -> clear and (x == sx or grid[{x, 1}] == ".")
    end)
  end

  def can_move_to_hallway?({x, _}, grid) do
    grid[{x - 1, 1}] == "." or grid[{x + 1, 1}] == "."
  end
end
