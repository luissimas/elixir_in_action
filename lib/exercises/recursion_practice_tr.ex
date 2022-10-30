defmodule RecursionPracticeTR do
  def sum(list), do: sum_tr(list, 0)

  defp sum_tr([], acc), do: acc
  defp sum_tr([head | tail], acc), do: sum_tr(tail, acc + head)

  def list_len(list), do: list_len_tr(list, 0)

  defp list_len_tr([], acc), do: acc
  defp list_len_tr([_head | tail], acc), do: list_len_tr(tail, acc + 1)

  def range(from, to) do
    case range_tr(from, to, []) do
      {:error, _} = error -> error
      result -> result
    end
  end

  defp range_tr(num, num, acc), do: [num | acc]
  defp range_tr(from, to, acc) when from < to, do: range_tr(from, to - 1, [to | acc])
  defp range_tr(_, _, _), do: {:error, "End of range must be greater or equal to start"}

  def positive(list), do: positive_tr(list, [])

  def positive_tr([], acc), do: Enum.reverse(acc)
  def positive_tr([head | tail], acc) when head <= 0, do: positive_tr(tail, acc)
  def positive_tr([head | tail], acc), do: positive_tr(tail, [head | acc])
end
