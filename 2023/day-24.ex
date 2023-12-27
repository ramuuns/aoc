defmodule Day24 do
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
    "19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-24")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data |> Enum.map(&make_hailstone/1)
  end

  def make_hailstone(str) do
    [[x, y, z], [dx, dy, dz]] =
      String.split(str, ~r"\s+@\s+", trim: true)
      |> Enum.map(fn s ->
        s |> String.split(~r",\s+", trim: true) |> Enum.map(&String.to_integer/1)
      end)

    {{x, y, z}, {dx, dy, dz}}
  end

  def part1([_ | rest] = data, mode) do
    range =
      if mode == :test do
        {7, 27}
      else
        {200_000_000_000_000, 400_000_000_000_000}
      end

    count_intersects_xy(data, rest, range, 0)
  end

  def count_intersects_xy(_, [], _, res), do: res

  def count_intersects_xy([line | rest], [_ | rem] = all, range, res) do
    count_intersects_xy(rest, rem, range, res + count_intersects_xy_one(all, line, range, 0))
  end

  def count_intersects_xy_one([], _, _, res), do: res

  def count_intersects_xy_one([line | rest], this_line, range, cnt) do
    count_intersects_xy_one(
      rest,
      this_line,
      range,
      cnt + does_intersect_xy(line, this_line, range)
    )
  end

  def does_intersect_xy(
        {{x1, y1, _}, {vx1, vy1, _}},
        {{x2, y2, _}, {vx2, vy2, _}},
        {minxy, maxxy}
      ) do
    k1 = vy1 / vx1
    k2 = vy2 / vx2
    c1 = y1 - k1 * x1
    c2 = y2 - k2 * x2

    if k1 == k2 do
      0
    else
      int_x = (c2 - c1) / (k1 - k2)
      int_y = k1 * int_x + c1

      x1_in_future =
        if vx1 > 0 do
          int_x > x1
        else
          int_x < x1
        end

      x2_in_future =
        if vx2 > 0 do
          int_x > x2
        else
          int_x < x2
        end

      if x1_in_future and x2_in_future and minxy <= int_x and minxy <= int_y and int_x <= maxxy and
           int_y <= maxxy do
        1
      else
        0
      end
    end
  end

  def part2(data) do
    min_x =
      data
      |> Enum.map(fn {{x, _, _}, _} -> x end)
      |> Enum.min()

    max_x =
      data
      |> Enum.map(fn {{x, _, _}, _} -> x end)
      |> Enum.max()

    min_slope =
      data
      |> Enum.map(fn {_, {dx, _, _}} -> dx end)
      |> Enum.min()

    max_slope =
      data
      |> Enum.map(fn {_, {dx, _, _}} -> dx end)
      |> Enum.max()

    x_candidates =
      data
      |> Enum.map(fn {{x, _, _}, {dx, _, _}} -> {x, dx} end)
      |> Enum.with_index()
      |> Enum.sort()
      |> find_candidates(min_x, max_x, min_slope, max_slope)

    min_y =
      data
      |> Enum.map(fn {{_, y, _}, _} -> y end)
      |> Enum.min()

    max_y =
      data
      |> Enum.map(fn {{_, y, _}, _} -> y end)
      |> Enum.max()

    min_slope =
      data
      |> Enum.map(fn {_, {_, dy, _}} -> dy end)
      |> Enum.min()

    max_slope =
      data
      |> Enum.map(fn {_, {_, dy, _}} -> dy end)
      |> Enum.max()

    y_candidates =
      data
      |> Enum.map(fn {{_, y, _}, {_, dy, _}} -> {y, dy} end)
      |> Enum.with_index()
      |> Enum.sort()
      |> find_candidates(min_y, max_y, min_slope, max_slope)

    min_z =
      data
      |> Enum.map(fn {{_, _, z}, _} -> z end)
      |> Enum.min()

    max_z =
      data
      |> Enum.map(fn {{_, _, z}, _} -> z end)
      |> Enum.max()

    min_slope =
      data
      |> Enum.map(fn {_, {_, _, dz}} -> dz end)
      |> Enum.min()

    max_slope =
      data
      |> Enum.map(fn {_, {_, _, dz}} -> dz end)
      |> Enum.max()

    z_candidates =
      data
      |> Enum.map(fn {{_, _, z}, {_, _, dz}} -> {z, dz} end)
      |> Enum.with_index()
      |> Enum.sort()
      |> find_candidates(min_z, max_z, min_slope, max_slope)

    [{{x, _}, _}] =
      x_candidates
      |> Enum.filter(fn {_, int_x} ->
        Enum.any?(y_candidates, fn {_, int_y} -> comp_sets(int_x, int_y) end) and
          Enum.any?(z_candidates, fn {_, int_z} -> comp_sets(int_x, int_z) end)
      end)

    [{{y, _}, _} | _] =
      y_candidates
      |> Enum.filter(fn {_, int_x} ->
        Enum.any?(x_candidates, fn {_, int_y} -> comp_sets(int_x, int_y) end) and
          Enum.any?(z_candidates, fn {_, int_z} -> comp_sets(int_x, int_z) end)
      end)

    [{{z, _}, _} | _] =
      z_candidates
      |> Enum.filter(fn {_, int_x} ->
        Enum.any?(y_candidates, fn {_, int_y} -> comp_sets(int_x, int_y) end) and
          Enum.any?(x_candidates, fn {_, int_z} -> comp_sets(int_x, int_z) end)
      end)

    x + y + z
  end

  def comp_sets(a, a), do: true
  def comp_sets(a, b), do: MapSet.subset?(a, b) or MapSet.subset?(b, a)

  def find_candidates(lines, _min_x, max_x, min_slope, max_slope) do
    check_each_slope(
      (min_slope * 10)..(abs(max_slope) * 10) |> Enum.to_list(),
      0,
      2 * max_x,
      lines,
      []
    )
  end

  def check_each_slope([], _, _, _, ret), do: ret

  def check_each_slope([slope | rest], min_x, max_x, lines, ret) do
    # "checking slope #{slope} (#{ rest |> Enum.count() } slopes remaining after this one)" |> IO.inspect() 

    case crt_me_baby(lines, slope, nil) do
      nil ->
        check_each_slope(rest, min_x, max_x, lines, ret)

      {r, mod} ->
        low_x = min_x - rem(min_x, mod) + r

        low_x =
          if low_x < min_x do
            low_x + mod
          else
            low_x
          end

        high_x = max_x - rem(max_x, mod) + r

        high_x =
          if high_x > max_x do
            high_x - mod
          else
            high_x
          end

        ret =
          if low_x <= high_x do
            0..div(high_x - low_x, mod)
            |> Enum.reduce(
              ret,
              fn m, ret ->
                case intersects_with_all(lines, low_x + m * mod, slope, MapSet.new()) do
                  false ->
                    ret

                  int ->
                    [int | ret]
                end
              end
            )
          else
            ret
          end

        check_each_slope(rest, min_x, max_x, lines, ret)
    end
  end

  def crt_me_baby([], _, ret), do: ret

  def crt_me_baby([{{_, dx}, _} | lines], dx, ret), do: crt_me_baby(lines, dx, ret)

  def crt_me_baby([{{x, dx}, _} | lines], slope, nil) do
    mod = abs(slope - dx)
    r = rem(x + mod, mod)
    crt_me_baby(lines, slope, {r, mod})
  end

  def crt_me_baby([{{x, dx}, _} | lines], slope, {r, r_mod}) do
    this_mod = abs(slope - dx)
    this_r = rem(x + this_mod, this_mod)

    if r_mod == this_mod do
      if this_r == r do
        crt_me_baby(lines, slope, {r, r_mod})
      else
        nil
      end
    else
      case Integer.extended_gcd(r_mod, this_mod) do
        {1, b_r, b_this} ->
          comb_mod = this_mod * r_mod

          comb_r =
            rem(
              rem(b_r * r_mod * this_r + b_this * this_mod * r + comb_mod, comb_mod) + comb_mod,
              comb_mod
            )

          crt_me_baby(lines, slope, {comb_r, comb_mod})

        {gcd, u, v} ->
          # This part is straight up lifted from a perl (XS) implementation that I found on CPan
          # where my requirement was that I can deal with things that aren't coprimes, so the
          # variable naming isn't amazing (tho this is also how those variables are named on Wikipedia so (shrug)
          if rem(r + gcd, gcd) == rem(this_r + gcd, gcd) do
            s = abs(div(this_mod, gcd))
            t = abs(div(r_mod, gcd))

            # this somewhat relies on "s" being the smaller value (so that if gcd(a,b) == a, the hope is that s == 1
            lcm = r_mod * s

            u =
              if u < 0 do
                u + lcm
              else
                u
              end

            v =
              if v < 0 do
                v + lcm
              else
                v
              end

            vs = rem(v * s, lcm)
            ut = rem(u * t, lcm)

            comb_r = rem(rem(vs * r, lcm) + rem(ut * this_r, lcm), lcm)

            ret = {comb_r, lcm}

            crt_me_baby(lines, slope, ret)
          else
            nil
          end
      end
    end
  end

  def intersects_with_all([], x, dx, ret), do: {{x, dx}, ret}

  def intersects_with_all([{{lx, ldx}, idx} | rest], x, dx, ret) do
    case does_intersect_in_int_coordinates({lx, ldx}, {x, dx}) do
      false -> false
      0 -> intersects_with_all(rest, x, dx, ret)
      t -> intersects_with_all(rest, x, dx, ret |> MapSet.put({idx, t}))
    end
  end

  def does_intersect_in_int_coordinates(a, a) do
    0
  end

  def does_intersect_in_int_coordinates({_, dx}, {_, dx}) do
    false
  end

  def does_intersect_in_int_coordinates({x1, dx1}, {x2, dx2}) do
    c = abs(div(x1 - x2, dx1 - dx2))

    if x1 + c * dx1 == x2 + c * dx2 do
      c
    else
      false
    end
  end
end
