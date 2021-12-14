defmodule Runner do
  def pad_number(num, pad) do
    num |> Integer.to_string() |> String.pad_leading(pad)
  end

  def run(["all"]) do
    start = :erlang.system_time(:millisecond)
    IO.puts("running all")

    days =
      File.ls!()
      |> Enum.filter(fn
        "day-" <> _ -> true
        _ -> false
      end)
      |> Enum.map(fn "day-" <> file = module ->
        {file |> String.split(".") |> hd() |> String.to_integer(), module}
      end)
      |> Task.async_stream(fn {day, module} ->
        Code.compile_file(module)

        [:test, :actual]
        |> Task.async_stream(fn mode ->
          {mode, apply(String.to_existing_atom("Elixir.Day#{day}"), :run, [mode])}
        end)
        |> Enum.map(fn {:ok, res} -> res end)
        |> then(fn results -> {day, results} end)
      end)
      |> Enum.map(fn {:ok, res} -> res end)
      |> Enum.sort_by(fn {day, _} -> day end)
      |> then(fn data ->
        IO.puts(
          "| Day | #{"test" |> String.pad_trailing(14 * 2 + 3)} | #{"actual" |> String.pad_trailing(14 * 2 + 3)} |"
        )

        IO.puts(
          "|     | #{"part 1" |> String.pad_trailing(14)} | #{"part 2" |> String.pad_trailing(14)} | #{"part 1" |> String.pad_trailing(14)} | #{"part 2" |> String.pad_trailing(14)} |"
        )

        data
      end)
      |> Enum.reduce(0, fn
        {day, [{:test, {testp1, testp2}}, {:actual, {actualp1, actualp2}}]}, days ->
          IO.puts(
            "| #{day |> pad_number(3)} | #{testp1 |> pad_number(14)} | #{testp2 |> pad_number(14)} | #{actualp1 |> pad_number(14)} | #{actualp2 |> pad_number(14)} |"
          )

          days + 1
      end)

    finish = :erlang.system_time(:millisecond)
    IO.puts("Took #{finish - start}ms (avg: #{div(finish - start, days)}ms per day)")
  end

  def run(args) do
    {day, runmode} =
      case args do
        [day] -> {String.to_integer(day), nil}
        [day, runmode] -> {String.to_integer(day), String.to_atom(runmode)}
      end

    zero_padded_day =
      if day > 9 do
        "#{day}"
      else
        "0#{day}"
      end

    filename = "day-#{zero_padded_day}.ex"

    if File.exists?(filename) do
      Code.compile_file(filename)
      start = :erlang.system_time(:microsecond)

      res =
        [:test, :actual]
        |> Enum.filter(fn mode -> runmode == nil || runmode == mode end)
        |> Task.async_stream(fn mode ->
          {mode, apply(String.to_existing_atom("Elixir.Day#{day}"), :run, [mode])}
        end, timeout: :infinity)
        |> Enum.map(fn {:ok, res} -> res end)

      IO.puts("Day #{day}\n")

      res
      |> Enum.each(fn {mode, {p1, p2}} ->
        if mode == :test do
          IO.puts("Test:")
        else
          IO.puts("\nActual:")
        end

        IO.puts("Part 1: #{p1}")
        IO.puts("Part 2: #{p2}")
      end)

      finish = :erlang.system_time(:microsecond)
      IO.puts("Took #{finish - start}μs")
    else
      IO.puts("this day (#{day}) ain't a thing")
    end
  end
end

Runner.run(System.argv())
