defmodule MonadCompiler do
  def compile(program) do
    {res, _} =
      "fn x, y, z, w, input -> #{program |> Enum.reverse() |> compile_step_by_step("z")} end"
      |> Code.eval_string()

    res
  end

  def to_string(program) do
    "fn x, y, z, w, input -> #{program |> Enum.reverse() |> compile_step_by_step("z")} end"
  end

  defp compile_step_by_step([], program), do: program

  defp compile_step_by_step([{:add, to, what} | rest], program),
    do:
      compile_step_by_step(
        rest,
        program
        |> String.replace(Atom.to_string(to), "(#{to} + #{what})")
      )

  defp compile_step_by_step([{:mul, to, 0} | rest], program),
    do:
      compile_step_by_step(
        rest,
        program
        |> String.replace(Atom.to_string(to), "0")
      )


  defp compile_step_by_step([{:mul, to, what} | rest], program),
    do:
      compile_step_by_step(
        rest,
        program
        |> String.replace(Atom.to_string(to), "(#{to} * #{what})")
      )

  defp compile_step_by_step([{:div, to, 1} | rest], program),
    do:
      compile_step_by_step(
        rest,
        program)

  defp compile_step_by_step([{:div, to, what} | rest], program),
    do:
      compile_step_by_step(
        rest,
        program
        |> String.replace(Atom.to_string(to), "div(#{to}, #{what})")
      )

  defp compile_step_by_step([{:mod, to, what} | rest], program),
    do:
      compile_step_by_step(
        rest,
        program
        |> String.replace(Atom.to_string(to), "rem(#{to}, #{what})")
      )

  defp compile_step_by_step([{:eql, to, what} | rest], program),
    do:
      compile_step_by_step(
        rest,
        program
        |> String.replace(Atom.to_string(to), "if(#{to} == #{what}, do: 1, else: 0)")
      )

  defp compile_step_by_step([{:inp, what} | rest], program),
    do:
      compile_step_by_step(
        rest,
        program |> String.replace(Atom.to_string(what), "input")
      )
end
