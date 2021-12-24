defmodule Day24 do
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
    "inp w
add z w
mod z 2
div w 2
add y w
mod y 2
div w 2
add x w
mod x 2
div w 2
mod w 2"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-24")
    |> Enum.map(fn n -> n |> String.trim_trailing() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data
    |> Enum.map(fn
      "inp " <> var ->
        {:inp, String.to_atom(var)}

      instr ->
        instr
        |> String.split(" ", trim: true)
        |> Enum.reduce({nil, nil, nil}, fn
          cmd, {nil, nil, nil} ->
            {String.to_atom(cmd), nil, nil}

          var, {inst, nil, nil} ->
            {inst, String.to_atom(var), nil}

          var, {inst, dst, nil} when var in ["x", "y", "z", "w"] ->
            {inst, dst, String.to_atom(var)}

          var, {inst, dst, nil} ->
            {inst, dst, String.to_integer(var)}
        end)
    end)
  end

  def part1(program) do
    subprograms = program |> split_to_subprograms([], [])

    {_, good_input, _} =
      run_until_z_is_zero(subprograms, 0, [], 0, %{0 => MapSet.new()}, :biggest)

    good_input |> Enum.reverse() |> Enum.join("") |> String.to_integer()
  end

  def split_to_subprograms([], program, subprograms),
    do: [program |> Enum.reverse() | subprograms] |> Enum.reverse()

  def split_to_subprograms([{:inp, _} = inp | rest], [], []),
    do: split_to_subprograms(rest, [inp], [])

  def split_to_subprograms([{:inp, _} = inp | rest], prev, all),
    do: split_to_subprograms(rest, [inp], [prev |> Enum.reverse() | all])

  def split_to_subprograms([cmd | rest], this, all),
    do: split_to_subprograms(rest, [cmd | this], all)

  def run_until_z_is_zero([], z, input, _, seen, _), do: {z, input, seen}

  def run_until_z_is_zero([subprogram | rest], z, input, level, seen, mode) do
    reduce_step =
      if mode == :biggest do
        [9, 8, 7, 6, 5, 4, 3, 2, 1]
      else
        [1, 2, 3, 4, 5, 6, 7, 8, 9]
      end
      |> Enum.reduce({nil, seen}, fn
        n, {nil, seen} ->
          next_z = execute_program_with_input(subprogram, [n], %{x: 0, y: 0, z: z, w: 0})

          if seen |> Map.get(level) |> MapSet.member?(next_z) do
            {nil, seen}
          else
            {res, passed_input, seen} =
              run_until_z_is_zero(
                rest,
                next_z,
                [n | input],
                level + 1,
                if Map.has_key?(seen, level + 1) do
                  seen
                else
                  seen |> Map.put(level + 1, MapSet.new())
                end,
                mode
              )

            if res == 0 do
              {passed_input, seen}
            else
              {nil, seen |> Map.put(level, seen |> Map.get(level) |> MapSet.put(next_z))}
            end
          end

        _, ret ->
          ret
      end)

    case reduce_step do
      {nil, seen} -> {1, [], seen}
      {good_input, seen} -> {0, good_input, seen}
    end
  end

  def part2(program) do
    subprograms = program |> split_to_subprograms([], [])

    {_, good_input, _} =
      run_until_z_is_zero(subprograms, 0, [], 0, %{0 => MapSet.new()}, :smallest)

    good_input |> Enum.reverse() |> Enum.join("") |> String.to_integer()
  end

  def execute_program_with_input([], _, %{z: z}), do: z

  def execute_program_with_input([{:inp, n} | rest], [input | rest_input], state),
    do: execute_program_with_input(rest, rest_input, state |> Map.put(n, input))

  # |> IO.inspect(label: "inp #{n}    "))
  def execute_program_with_input([instr | rest], input, state),
    do: execute_program_with_input(rest, input, state |> apply_instr(instr))

  # |> IO.inspect(label: "#{ Atom.to_string(elem(instr, 0)) } #{ Atom.to_string(elem(instr, 1)) } "))

  def apply_instr(state, {:add, tgt, src}) when is_atom(src),
    do: state |> Map.put(tgt, Map.get(state, src) + Map.get(state, tgt))

  def apply_instr(state, {:add, tgt, num}), do: state |> Map.put(tgt, Map.get(state, tgt) + num)

  def apply_instr(state, {:mul, tgt, src}) when is_atom(src),
    do: state |> Map.put(tgt, Map.get(state, src) * Map.get(state, tgt))

  def apply_instr(state, {:mul, tgt, num}), do: state |> Map.put(tgt, Map.get(state, tgt) * num)

  def apply_instr(state, {:div, tgt, src}) when is_atom(src),
    do: state |> Map.put(tgt, div(Map.get(state, tgt), Map.get(state, src)))

  def apply_instr(state, {:div, tgt, num}),
    do: state |> Map.put(tgt, div(Map.get(state, tgt), num))

  def apply_instr(state, {:mod, tgt, src}) when is_atom(src),
    do: state |> Map.put(tgt, rem(Map.get(state, tgt), Map.get(state, src)))

  def apply_instr(state, {:mod, tgt, num}),
    do: state |> Map.put(tgt, rem(Map.get(state, tgt), num))

  def apply_instr(state, {:eql, tgt, src}) when is_atom(src),
    do: state |> Map.put(tgt, if(Map.get(state, tgt) == Map.get(state, src), do: 1, else: 0))

  def apply_instr(state, {:eql, tgt, num}),
    do: state |> Map.put(tgt, if(Map.get(state, tgt) == num, do: 1, else: 0))
end
