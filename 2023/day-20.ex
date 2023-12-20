defmodule Day20 do
  def run(mode) do
    data = read_input(mode)

    [{1, data}, {2, data}]
    |> Task.async_stream(
      fn
        {1, data} -> {1, data |> part1}
        {2, data} -> {2, data |> part2(mode)}
      end,
      timeout: :infinity
    )
    |> Enum.reduce({0, 0}, fn
      {_, {1, res}}, {_, p2} -> {res, p2}
      {_, {2, res}}, {p1, _} -> {p1, res}
    end)
  end

  def read_input(:test) do
    "broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-20")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data
    |> Enum.map(&parse_type/1)
    |> setup_inverter_memory()
    |> Enum.into(%{})
  end

  def parse_type("broadcaster -> " <> dest) do
    {:broadcaster,
     %{
       type: :broadcaster,
       dest: dest |> String.split(", ", trim: true) |> Enum.map(&String.to_atom/1)
     }}
  end

  def parse_type("%" <> spec) do
    [name, dest] = String.split(spec, " -> ", trim: true)

    {name |> String.to_atom(),
     %{
       type: :flip_flop,
       state: 0,
       dest: dest |> String.split(", ", trim: true) |> Enum.map(&String.to_atom/1)
     }}
  end

  def parse_type("&" <> spec) do
    [name, dest] = String.split(spec, " -> ", trim: true)

    {name |> String.to_atom(),
     %{
       type: :inverter,
       state: %{},
       dest: dest |> String.split(", ", trim: true) |> Enum.map(&String.to_atom/1)
     }}
  end

  def setup_inverter_memory(nodes) do
    nodes
    |> Enum.map(fn
      {name, %{type: :inverter} = node} ->
        {name,
         %{
           node
           | state:
               nodes
               |> Enum.filter(fn {_src_name, %{dest: dest}} ->
                 dest |> Enum.any?(fn d -> d == name end)
               end)
               |> Enum.map(fn {src_name, _} -> {src_name, 0} end)
               |> Enum.into(%{})
         }}

      node ->
        node
    end)
  end

  def part1(data) do
    {high, low} = push_button(data, %{}, 1000, {0, 0})
    high * low
  end

  def push_button(_, _, 0, ret), do: ret

  def push_button(state, state_cache, times, {high_count, low_count})
      when is_map_key(state_cache, state) do
    {{h, l}, next_state} = Map.get(state_cache, state)
    push_button(next_state, state_cache, times - 1, {high_count + h, low_count + l})
  end

  def push_button(state, state_cache, times, {high_count, low_count}) do
    {{h, l}, next_state, _} =
      process_signal([{:button, :broadcaster, 0}], [], state, {0, 0}, %{}, 0)

    state_cache =
      state_cache |> Map.put(state, {{h, l}, next_state})

    push_button(next_state, state_cache, times - 1, {high_count + h, low_count + l})
  end

  def process_signal([], [], state, count, ti, _), do: {count, state, ti}

  def process_signal([], tail, state, count, ti, bpc),
    do: process_signal(tail |> Enum.reverse(), [], state, count, ti, bpc)

  def process_signal([{src, dest, signal} | rest], tail, state, {high, low}, ti, bpc)
      when is_map_key(state, dest) do
    {high, low} =
      if signal == 0 do
        {high, low + 1}
      else
        {high + 1, low}
      end

    {state, next, ti} =
      case state[dest] do
        %{type: :broadcaster, dest: next_dest} ->
          {state, next_dest |> Enum.map(fn d -> {:broadcaster, d, signal} end), ti}

        %{type: :flip_flop, dest: next_dest, state: ff_state} = ff ->
          if signal == 0 do
            next_ff_state = rem(ff_state + 1, 2)

            {state |> Map.put(dest, %{ff | state: next_ff_state}),
             next_dest |> Enum.map(fn d -> {dest, d, next_ff_state} end), ti}
          else
            {state, [], ti}
          end

        %{type: :inverter, dest: next_dest, state: inv_state} = inv ->
          inv_state = inv_state |> Map.put(src, signal)

          to_send =
            if Map.values(inv_state) |> Enum.all?(fn s -> s == 1 end) do
              0
            else
              1
            end

          ti =
            if to_send == 0 and Map.has_key?(ti, dest) and ti[dest] == 0 do
              Map.put(ti, dest, bpc)
            else
              ti
            end

          {state |> Map.put(dest, %{inv | state: inv_state}),
           next_dest |> Enum.map(fn d -> {dest, d, to_send} end), ti}
      end

    process_signal(rest, (next |> Enum.reverse()) ++ tail, state, {high, low}, ti, bpc)
  end

  def process_signal([{_, :rx, signal} | rest], tail, state, {high, low}, ti, bpc) do
    {high, low} =
      if signal == 0 do
        {high, low + 1}
      else
        {high + 1, low}
      end

    process_signal(rest, tail, state, {high, low}, ti, bpc)
  end

  def part2(_, :test) do
    1
  end

  def part2(data, _) do
    push_button_until_single_low_rx(data, 1, %{ll: 0, rc: 0, gv: 0, qf: 0})
  end

  def push_button_until_single_low_rx(state, button_press_count, target_inverters) do
    {_, next_state, target_inverters} =
      process_signal(
        [{:button, :broadcaster, 0}],
        [],
        state,
        {0, 0},
        target_inverters,
        button_press_count
      )

    if target_inverters |> Map.values() |> Enum.all?(fn v -> v != 0 end) do
      target_inverters |> Map.values() |> Enum.product()
    else
      push_button_until_single_low_rx(next_state, button_press_count + 1, target_inverters)
    end
  end
end
