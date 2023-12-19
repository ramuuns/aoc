defmodule Day19 do
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
    "px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-19")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data |> into_rules_and_parts(%{}, [], :rules)
  end

  def into_rules_and_parts([], rules, parts, _), do: {rules, parts}

  def into_rules_and_parts(["" | rest], rules, parts, :rules),
    do: into_rules_and_parts(rest, rules, parts, :parts)

  def into_rules_and_parts([part | rest], rules, parts, :parts) do
    [_ | part] = Regex.run(~r"x=(\d+),m=(\d+),a=(\d+),s=(\d+)", part)
    [x, m, a, s] = part |> Enum.map(&String.to_integer/1)
    into_rules_and_parts(rest, rules, [{x, m, a, s} | parts], :parts)
  end

  def into_rules_and_parts([rule | rest], rules, parts, :rules) do
    [_, name, the_rules] = Regex.run(~r"([a-z]+){([^}]+)}", rule)
    value = the_rules |> String.split(",", trim: true) |> Enum.map(&to_rule/1)
    into_rules_and_parts(rest, rules |> Map.put(name |> String.to_atom(), value), parts, :rules)
  end

  def to_rule("A"), do: :accept
  def to_rule("R"), do: :reject

  def to_rule(rule) do
    if String.contains?(rule, ":") do
      [condition, value] = String.split(rule, ":", trim: true)

      value =
        case value do
          "A" -> :accept
          "R" -> :reject
          _ -> value |> String.to_atom()
        end

      func = fn {x, m, a, s} ->
        {res, _} = Code.eval_string(condition, x: x, m: m, a: a, s: s)
        res
      end

      func2 =
        case condition do
          "x>" <> val ->
            val = val |> String.to_integer()

            fn {x, m, a, s} ->
              {xt, xf} = filter_into(x, fn x -> x > val end, [], [])

              {
                {xt, m, a, s},
                {xf, m, a, s}
              }
            end

          "x<" <> val ->
            val = val |> String.to_integer()

            fn {x, m, a, s} ->
              {xt, xf} = filter_into(x, fn x -> x < val end, [], [])

              {
                {xt, m, a, s},
                {xf, m, a, s}
              }
            end

          "m>" <> val ->
            val = val |> String.to_integer()

            fn {x, m, a, s} ->
              {mt, mf} = filter_into(m, fn m -> m > val end, [], [])

              {
                {x, mt, a, s},
                {x, mf, a, s}
              }
            end

          "m<" <> val ->
            val = val |> String.to_integer()

            fn {x, m, a, s} ->
              {mt, mf} = filter_into(m, fn m -> m < val end, [], [])

              {
                {x, mt, a, s},
                {x, mf, a, s}
              }
            end

          "a>" <> val ->
            val = val |> String.to_integer()

            fn {x, m, a, s} ->
              {at, af} = filter_into(a, fn a -> a > val end, [], [])

              {
                {x, m, at, s},
                {x, m, af, s}
              }
            end

          "a<" <> val ->
            val = val |> String.to_integer()

            fn {x, m, a, s} ->
              {at, af} = filter_into(a, fn a -> a < val end, [], [])

              {
                {x, m, at, s},
                {x, m, af, s}
              }
            end

          "s>" <> val ->
            val = val |> String.to_integer()

            fn {x, m, a, s} ->
              {st, sf} = filter_into(s, fn s -> s > val end, [], [])

              {
                {x, m, a, st},
                {x, m, a, sf}
              }
            end

          "s<" <> val ->
            val = val |> String.to_integer()

            fn {x, m, a, s} ->
              {st, sf} = filter_into(s, fn s -> s < val end, [], [])

              {
                {x, m, a, st},
                {x, m, a, sf}
              }
            end
        end

      {func, value, func2}
    else
      rule |> String.to_atom()
    end
  end

  def filter_into([], _, t, f), do: {t, f}

  def filter_into([num | rest], func, t, f) do
    if func.(num) do
      filter_into(rest, func, [num | t], f)
    else
      filter_into(rest, func, t, [num | f])
    end
  end

  def part1({rules, parts}) do
    parts
    |> Enum.map(fn {x, m, a, s} = part ->
      if run_rules(part, rules, :in) == :accept do
        x + m + a + s
      else
        0
      end
    end)
    |> Enum.sum()
  end

  def run_rules(part, rules, rule) do
    res =
      rules[rule]
      |> apply_rule(part)

    case res do
      :accept -> res
      :reject -> res
      _ -> run_rules(part, rules, res)
    end
  end

  def apply_rule([rule], _part), do: rule

  def apply_rule([{condition, value, _} | rest], part) do
    if condition.(part) do
      value
    else
      apply_rule(rest, part)
    end
  end

  def part2({rules, _parts}) do
    {1..4000 |> Enum.to_list(), 1..4000 |> Enum.to_list(), 1..4000 |> Enum.to_list(),
     1..4000 |> Enum.to_list()}
    |> count_accepted(rules, :in)
  end

  def count_accepted({x, m, a, s}, rules, :accept) do
    Enum.count(x) * Enum.count(m) * Enum.count(a) * Enum.count(s)
  end

  def count_accepted(_, rules, :reject), do: 0

  def count_accepted(xmas, rules, r) do
    rules[r]
    |> filter_apply(xmas, rules)
  end

  def filter_apply([rule], xmas, rules) do
    count_accepted(xmas, rules, rule)
  end

  def filter_apply([{_, if_true, filter} | rest], xmas, rules) do
    {when_true, when_false} = filter.(xmas)
    filter_apply(rest, when_false, rules) + count_accepted(when_true, rules, if_true)
  end
end
