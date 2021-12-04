defmodule Day4 do
  def run(mode) do
    data = read_input(mode)

    start = :erlang.system_time(:microsecond)
    data |> part1() |> IO.puts()
    data |> part2() |> IO.puts()
    finish = :erlang.system_time(:microsecond)
    "took #{finish - start}us" |> IO.puts()
  end

  def read_input(:test) do
    "7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-04")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data([numbers | boards]) do
    {
      numbers |> String.split(","),
      boards |> prepare_boards([], 0)
    }
  end

  def default_row_or_col() do
    0..4 |> Enum.reduce(%{}, fn n, acc -> acc |> Map.put(n, 5) end)
  end

  def prepare_boards(["" | rest], boards, _),
    do:
      prepare_boards(
        rest,
        [%{num_coords: %{}, rows: default_row_or_col(), cols: default_row_or_col()} | boards],
        0
      )

  def prepare_boards([numbers | rest], [board | boards], row) do
    board =
      numbers
      |> String.split(" ")
      |> Enum.filter(fn n -> n != "" end)
      |> add_to_board(board, 0, row)

    prepare_boards(rest, [board | boards], row + 1)
  end

  def prepare_boards([], boards, _), do: boards

  def add_to_board([], board, _, _), do: board

  def add_to_board([num | rest], %{num_coords: num_coords} = board, col, row),
    do:
      add_to_board(
        rest,
        %{board | num_coords: num_coords |> Map.put(num, {row, col})},
        col + 1,
        row
      )

  def part1({numbers, boards}) do
    {winning_board, num} = draw_next_number_until_bingo(numbers, boards)
    num = String.to_integer(num)

    unmarked_sum =
      winning_board.num_coords
      |> Map.keys()
      |> Enum.reduce(0, fn n, acc -> acc + String.to_integer(n) end)

    num * unmarked_sum
  end

  def draw_next_number_until_bingo([num | rest_of_nums], boards) do
    {boards, has_bingo?, bingo_board} = check_for_bingo(boards, num, {[], false, nil})

    if has_bingo? do
      {bingo_board, num}
    else
      draw_next_number_until_bingo(rest_of_nums, boards)
    end
  end

  def check_for_bingo([], _, acc), do: acc

  def check_for_bingo([board | rest_of_boards], num, {boards, had_bingo, winning_board}) do
    {board, has_bingo?} =
      if Map.has_key?(board.num_coords, num) do
        {{row, col}, num_coords} = Map.pop!(board.num_coords, num)
        rw = board.rows[row] - 1
        cl = board.cols[col] - 1
        has_bingo? = rw == 0 or cl == 0

        {%{
           num_coords: num_coords,
           rows: board.rows |> Map.put(row, rw),
           cols: board.cols |> Map.put(col, cl)
         }, has_bingo?}
      else
        {board, false}
      end

    if has_bingo? do
      check_for_bingo(rest_of_boards, num, {boards, true, board})
    else
      check_for_bingo(rest_of_boards, num, {[board | boards], had_bingo, winning_board})
    end
  end

  def part2({numbers, boards}) do
    {losing_board, num} = draw_next_number_until_last_bingo(numbers, boards)
    num = String.to_integer(num)

    unmarked_sum =
      losing_board.num_coords
      |> Map.keys()
      |> Enum.reduce(0, fn n, acc -> acc + String.to_integer(n) end)

    num * unmarked_sum
  end

  def draw_next_number_until_last_bingo([num | rest_of_nums], boards) do
    {boards, has_bingo?, bingo_board} = check_for_bingo(boards, num, {[], false, nil})

    if has_bingo? and Enum.empty?(boards) do
      {bingo_board, num}
    else
      draw_next_number_until_last_bingo(rest_of_nums, boards)
    end
  end
end

Day4.run(:test)
Day4.run(:actual)
