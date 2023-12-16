defmodule Day16 do
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
    ".|...\\....
|.-.\\.....
.....|-...
........|.
..........
.........\\
..../.\\\\..
.-.-/..|..
.|....-|.\\
..//.|...."
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-16")
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
    do: make_row(rest, grid |> Map.put({y, x}, c), y, x + 1)

  def dir_c(:right), do: {0, 1}
  def dir_c(:left), do: {0, -1}
  def dir_c(:up), do: {-1, 0}
  def dir_c(:down), do: {1, 0}

  def new_dir(?/, :right), do: :up
  def new_dir(?/, :left), do: :down
  def new_dir(?/, :up), do: :right
  def new_dir(?/, :down), do: :left

  def new_dir(?\\, :right), do: :down
  def new_dir(?\\, :left), do: :up
  def new_dir(?\\, :up), do: :left
  def new_dir(?\\, :down), do: :right

  def part1({data, _}) do
    beam_path([{0, 0, :right}], data, MapSet.new([{0, 0}]), MapSet.new([{0, 0, :right}]))
    |> MapSet.size()
  end

  def beam_path([], _, visited, _) do
    visited
  end

  def beam_path([{y, x, dir} | rest], grid, visited, seen) do
    c = Map.get(grid, {y, x})

    next =
      cond do
        c == ?. or
          (c == ?- and (dir == :left or dir == :right)) or
            (c == ?| and (dir == :up or dir == :down)) ->
          {dy, dx} = dir_c(dir)
          [{y + dy, x + dx, dir}]

        c == ?/ ->
          next_dir = new_dir(?/, dir)
          {dy, dx} = dir_c(next_dir)
          [{y + dy, x + dx, next_dir}]

        c == ?\\ ->
          next_dir = new_dir(?\\, dir)
          {dy, dx} = dir_c(next_dir)
          [{y + dy, x + dx, next_dir}]

        c == ?| ->
          [{y + 1, x, :down}, {y - 1, x, :up}]

        c == ?- ->
          [{y, x + 1, :right}, {y, x - 1, :left}]

        true ->
          {y, x, dir, <<c>>} |> IO.inspect()
          raise "wtf"
      end
      |> Enum.filter(fn {y, x, _} = p -> Map.has_key?(grid, {y, x}) and p not in seen end)

    visited =
      next |> Enum.reduce(visited, fn {y, x, _}, visited -> visited |> MapSet.put({y, x}) end)

    seen = next |> Enum.reduce(seen, fn pos, seen -> seen |> MapSet.put(pos) end)

    beam_path(next ++ rest, grid, visited, seen)
  end


  def beam_path_pp([], _, visited, seen), do: visited |> MapSet.size()

  def beam_path_pp([{y, x, dir} | rest], grid, visited, seen) do
    next = Map.get(grid, {y, x}) |> Map.get(dir)

    if next == nil do
      beam_path_pp(rest, grid, visited, seen)
    else
      next_new = next |> Enum.filter(fn {coord, _} -> not MapSet.member?(seen, coord) end)
      next_coords = next_new |> Enum.map(fn {coord, _} -> coord end)
      seen = next_coords |> Enum.reduce(seen, fn coord, seen -> seen |> MapSet.put(coord) end)
      nc_list = next_coords ++ rest

      visited =
        next_new
        |> Enum.reduce(
          visited,
          fn {_, coords}, visited ->
            coords |> Enum.reduce(visited, fn c, visited -> visited |> MapSet.put(c) end)
          end
        )

      beam_path_pp(nc_list, grid, visited, seen)
    end
  end

  def part2({data, max_yx}) do
    data_processed = pre_process_map(data |> Map.to_list(), %{}, data)

    0..max_yx
    |> Enum.map(fn xy ->
      [
        beam_path_pp(
          [{xy, 0, :right}],
          data_processed,
          MapSet.new([{xy, 0}]),
          MapSet.new([{xy, 0, :right}])
        ),
        beam_path_pp(
          [{xy, max_yx, :left}],
          data_processed,
          MapSet.new([{xy, max_yx}]),
          MapSet.new([{xy, max_yx, :left}])
        ),
        beam_path_pp(
          [{0, xy, :down}],
          data_processed,
          MapSet.new([{0, xy}]),
          MapSet.new([{0, xy, :down}])
        ),
        beam_path_pp(
          [{max_yx, xy, :up}],
          data_processed,
          MapSet.new([{max_yx, xy}]),
          MapSet.new([{max_yx, xy, :up}])
        )
      ]
      |> Enum.max()
    end)
    |> Enum.max()
  end

  def pre_process_map([], processed, _), do: processed

  def pre_process_map([{{y, x}, ?.} | rest], processed, grid) do
    value =
      [
        {:up, [{{y - 1, x, :up}, [{y - 1, x}]}]},
        {:down, [{{y + 1, x, :down}, [{y + 1, x}]}]},
        {:left, [{{y, x - 1, :left}, [{y, x - 1}]}]},
        {:right, [{{y, x + 1, :right}, [{y, x + 1}]}]}
      ]
      |> Enum.filter(fn {_, [{{y, x, _}, _} | _]} -> Map.has_key?(grid, {y, x}) end)
      |> Enum.into(%{})

    processed = processed |> Map.put({y, x}, value)
    pre_process_map(rest, processed, grid)
  end

  def pre_process_map([{{y, x}, ?-} | rest], processed, grid) do
    lr =
      [
        go_straight({y, x - 1}, :left, grid, []),
        go_straight({y, x + 1}, :right, grid, [])
      ]
      |> Enum.filter(fn
        {{^y, ^x, _}, _} -> false
        _ -> true
      end)

    value =
      [
        {:left, [{{y, x - 1, :left}, [{y, x - 1}]}]},
        {:right, [{{y, x + 1, :right}, [{y, x + 1}]}]},
        {:up, lr},
        {:down, lr}
      ]
      |> Enum.filter(fn {_, [{{y, x, _}, _} | _]} -> Map.has_key?(grid, {y, x}) end)
      |> Enum.into(%{})

    processed = processed |> Map.put({y, x}, value)
    pre_process_map(rest, processed, grid)
  end

  def pre_process_map([{{y, x}, ?|} | rest], processed, grid) do
    ud =
      [
        go_straight({y - 1, x}, :up, grid, []),
        go_straight({y + 1, x}, :down, grid, [])
      ]
      |> Enum.filter(fn
        {{^y, ^x, _}, _} -> false
        _ -> true
      end)

    value =
      [
        {:up, [{{y - 1, x, :up}, [{y - 1, x}]}]},
        {:down, [{{y + 1, x, :down}, [{y + 1, x}]}]},
        {:left, ud},
        {:right, ud}
      ]
      |> Enum.filter(fn {_, [{{y, x, _}, _} | _]} -> Map.has_key?(grid, {y, x}) end)
      |> Enum.into(%{})

    processed = processed |> Map.put({y, x}, value)
    pre_process_map(rest, processed, grid)
  end

  def pre_process_map([{{y, x}, ?/} | rest], processed, grid) do
    value =
      [
        {:up, [go_straight({y, x + 1}, :right, grid, [])]},
        {:down, [go_straight({y, x - 1}, :left, grid, [])]},
        {:left, [go_straight({y + 1, x}, :down, grid, [])]},
        {:right, [go_straight({y - 1, x}, :up, grid, [])]}
      ]
      |> Enum.filter(fn
        {_, [{{^y, ^x, _}, _}]} -> false
        _ -> true
      end)
      |> Enum.into(%{})

    processed = processed |> Map.put({y, x}, value)
    pre_process_map(rest, processed, grid)
  end

  def pre_process_map([{{y, x}, ?\\} | rest], processed, grid) do
    value =
      [
        {:up, [go_straight({y, x - 1}, :left, grid, [])]},
        {:down, [go_straight({y, x + 1}, :right, grid, [])]},
        {:left, [go_straight({y - 1, x}, :up, grid, [])]},
        {:right, [go_straight({y + 1, x}, :down, grid, [])]}
      ]
      |> Enum.filter(fn
        {_, [{{^y, ^x, _}, _}]} -> false
        _ -> true
      end)
      |> Enum.into(%{})

    processed = processed |> Map.put({y, x}, value)
    pre_process_map(rest, processed, grid)
  end

  def go_straight({y, x}, dir, grid, coords) when not is_map_key(grid, {y, x}) do
    {dy, dx} = dir_c(dir)
    {{y - dy, x - dx, dir}, coords}
  end

  def go_straight({y, x}, dir, grid, coords) do
    {dy, dx} = dir_c(dir)
    coords = [{y, x} | coords]
    c = Map.get(grid, {y, x})

    cond do
      c == ?. or
        (c == ?- and (dir == :left or dir == :right)) or
          (c == ?| and (dir == :up or dir == :down)) ->
        go_straight({y + dy, x + dx}, dir, grid, coords)

      true ->
        {{y, x, dir}, coords}
    end
  end

end
