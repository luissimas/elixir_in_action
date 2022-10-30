defmodule RecursionPractice do
  def list_len([]), do: 0
  def list_len([_head | tail]), do: 1 + list_len(tail)

  def range(from, to) when from > to do
    {:error, "End of range must be greater or equal to start"}
  end

  def range(num, num), do: [num]
  def range(from, to), do: [from | range(from + 1, to)]

  def positive([]), do: []
  def positive([head | tail]) when head > 0, do: [head | positive(tail)]
  def positive([_head | tail]), do: positive(tail)
end
