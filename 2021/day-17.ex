defmodule Day17 do
  use Bitwise

  def run(mode) do
    data = read_input(mode)

    {
      data |> part1(),
      data |> part2()
    }
  end

  def read_input(:test) do
    "target area: x=20..30, y=-10..-5"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-17")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(["target area:" <> input]) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(fn
      " x=" <> xc ->
        xc
        |> String.split("..")
        |> Enum.map(&String.to_integer/1)
        |> then(fn [minx, maxx] -> {:x, {minx, maxx}} end)

      " y=" <> yc ->
        yc
        |> String.split("..")
        |> Enum.map(&String.to_integer/1)
        |> then(fn [miny, maxy] -> {:y, {miny, maxy}} end)
    end)
    |> Enum.into(%{})
  end

  def part1(%{x: {minx, maxx}, y: {miny, maxy}}) do
    x_candidates = 1..maxx |> Enum.to_list() |> find_xes({minx, maxx}, [])
    y_candidates = 0..miny |> Enum.to_list() |> find_ys({miny, maxy}, [])
    [_, y] = y_candidates |> Enum.sort_by(& &1, :desc) |> find_best_speed(x_candidates)
    y * (1 + div(y, 2))
  end

  def part2(%{x: {minx, maxx}, y: {miny, maxy}}) do
    x_candidates = 1..maxx |> Enum.to_list() |> find_xes({minx, maxx}, [])

    y_candidates = 0..miny |> Enum.to_list() |> find_ys({miny, maxy}, []) |> Enum.uniq()

    find_all(y_candidates, x_candidates)
    |> Enum.uniq()
    |> Enum.count()
  end

  def find_xes([], _, cand), do: cand

  def find_xes([x | rest], {minx, maxx}, cand) do
    case checkx(x, x - 1, {minx, maxx}, 1) do
      {true, steps, stays, max_steps} ->
        find_xes(rest, {minx, maxx}, [{x, steps, stays, max_steps} | cand])

      _ ->
        find_xes(rest, {minx, maxx}, cand)
    end
  end

  def checkx(c, v, {minx, maxx} = tgt, steps) when c >= minx and c <= maxx do
    {stays, max_steps} = check_if_stays(c, v, tgt, steps)
    {true, steps, stays, max_steps}
  end

  def checkx(c, _, {_, maxx}, _) when c > maxx, do: {false, 0}
  def checkx(c, 0, {minx, _}, _) when c < minx, do: {false, 0}
  def checkx(c, v, tgt, steps), do: checkx(c + v, v - 1, tgt, steps + 1)

  def check_if_stays(c, 0, {_, maxx}, _) when c <= maxx, do: {true, 0}
  def check_if_stays(c, _v, {_, maxx}, steps) when c > maxx, do: {false, steps - 1}
  def check_if_stays(c, v, tgt, steps), do: check_if_stays(c + v, v - 1, tgt, steps + 1)

  def find_ys([], _, cand),
    do:
      cand
      |> Enum.flat_map(fn
        {y, min_steps, max_steps} ->
          [
            {y, min_steps, max_steps},
            {-1 - y, min_steps + 1 + 2 * (-1 - y), max_steps + 1 + 2 * (-1 - y)}
          ]
      end)

  def find_ys([y | rest], tgt, cand) do
    case checky(0, y, tgt, 0) do
      {true, min_steps, max_steps} -> find_ys(rest, tgt, [{y, min_steps, max_steps} | cand])
      _ -> find_ys(rest, tgt, cand)
    end
  end

  def checky(c, v, {miny, maxy}, steps) when c >= miny and c <= maxy do
    {true, steps, max_y_steps(c, v, miny, steps)}
  end

  def checky(c, _, {miny, _}, _) when c < miny, do: {false, 0}
  def checky(c, v, tgt, steps), do: checky(c + v, v - 1, tgt, steps + 1)

  def max_y_steps(c, _, miny, steps) when c < miny, do: steps - 1
  def max_y_steps(c, v, miny, steps), do: max_y_steps(c + v, v - 1, miny, steps + 1)

  def find_best_speed([], _), do: [0, 0]

  def find_best_speed([{y, steps, _} | rest], xcandidates) do
    case xcandidates |> check_if_can_x_in_steps(steps) do
      {true, x} -> [x, y]
      _ -> find_best_speed(rest, xcandidates)
    end
  end

  def check_if_can_x_in_steps([], _), do: false

  def check_if_can_x_in_steps([{x, min_steps, false, max_steps} | _], steps)
      when steps >= min_steps and steps <= max_steps,
      do: {true, x}

  def check_if_can_x_in_steps([{x, min_steps, true, _} | _], steps) when steps >= min_steps,
    do: {true, x}

  def check_if_can_x_in_steps([_ | rest], steps), do: check_if_can_x_in_steps(rest, steps)

  def add_to_map([], ret, _, _), do: ret

  def add_to_map([steps | rest], ret, kind, coord) do
    coords_this_steps = ret |> Map.get(steps, %{y: [], x: []})

    coords_this_steps =
      coords_this_steps |> Map.put(kind, [coord | Map.get(coords_this_steps, kind)])

    add_to_map(rest, ret |> Map.put(steps, coords_this_steps), kind, coord)
  end

  def steps_to_coords([], ret), do: ret

  def steps_to_coords([{y, min_steps, max_steps} | rest], ret),
    do: steps_to_coords(rest, min_steps..max_steps |> Enum.to_list() |> add_to_map(ret, :y, y))

  def steps_to_coords([{x, min_steps, false, max_steps} | rest], ret),
    do: steps_to_coords(rest, min_steps..max_steps |> Enum.to_list() |> add_to_map(ret, :x, x))

  def steps_to_coords([{x, min_steps, true, _} | rest], ret),
    do:
      steps_to_coords(
        rest,
        ret |> Map.keys() |> Enum.filter(fn k -> k >= min_steps end) |> add_to_map(ret, :x, x)
      )

  def cart_prod([], _, ret), do: ret
  def cart_prod([a | rest], b, ret), do: cart_prod(rest, b, b |> add_all_to(ret, a))

  def add_all_to([], ret, _), do: ret
  def add_all_to([b | rest], ret, a), do: add_all_to(rest, [{a, b} | ret], a)

  def get_all_coords([], ret), do: ret
  def get_all_coords([{_, %{y: []}} | rest], ret), do: get_all_coords(rest, ret)
  def get_all_coords([{_, %{x: []}} | rest], ret), do: get_all_coords(rest, ret)

  def get_all_coords([{_, %{x: xes, y: ys}} | rest], ret),
    do: get_all_coords(rest, cart_prod(xes, ys, ret))

  # this here's the _second_ approach, where we build a map of %{ nr_of_steps: %{ x: [list, of, x, with this, step], y: [list, of, y, in, this, step]  }}
  # and then look at all the steps that have nonempty x and y lists and do a carteasian product of the two lists

  def find_all(ys, xs) do
    xs
    |> steps_to_coords(ys |> steps_to_coords(%{}))
    |> Enum.to_list()
    |> get_all_coords([])
  end

  #  ok so the stuff below was the first approach, where we basically do a x*y loop to check 
  # if given the nr of steps to get to a particular y, we can get an x in those particular steps

  def find_all([], _, ret), do: ret

  def find_all([{y, min_steps, max_steps} | resty], xcandidates, ret),
    do:
      find_all(
        resty,
        xcandidates,
        min_steps..max_steps
        |> Enum.to_list()
        |> find_all_x_in_steps(xcandidates, xcandidates, ret, y)
      )

  def find_all_x_in_steps([], _, _, ret, _), do: ret

  def find_all_x_in_steps([_ | steps], [], xc, ret, y),
    do: find_all_x_in_steps(steps, xc, xc, ret, y)

  def find_all_x_in_steps(
        [steps | _] = allsteps,
        [{x, min_steps, false, max_steps} | rest],
        xc,
        ret,
        y
      )
      when steps >= min_steps and steps <= max_steps,
      do: find_all_x_in_steps(allsteps, rest, xc, [{x, y} | ret], y)

  def find_all_x_in_steps([steps | _] = allsteps, [{x, min_steps, true, _} | rest], xc, ret, y)
      when steps >= min_steps,
      do: find_all_x_in_steps(allsteps, rest, xc, [{x, y} | ret], y)

  def find_all_x_in_steps(allsteps, [_ | rest], xc, ret, y),
    do: find_all_x_in_steps(allsteps, rest, xc, ret, y)
end
