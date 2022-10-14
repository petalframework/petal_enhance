defmodule PetalEnhance.Utils do
  @doc """
  Convert map string keys to :atom keys
  """
  def atomize_keys(nil), do: nil

  # Structs don't do enumerable and anyway the keys are already
  # atoms
  def atomize_keys(struct = %{__struct__: _}) do
    struct
  end

  def atomize_keys(map = %{}) do
    map
    |> Enum.map(fn {k, v} -> {String.to_atom(k), atomize_keys(v)} end)
    |> Enum.into(%{})
  end

  # Walk the list and atomize the keys of
  # of any map members
  def atomize_keys([head | rest]) do
    [atomize_keys(head) | atomize_keys(rest)]
  end

  def atomize_keys(not_a_map) do
    not_a_map
  end

  # For updating a database object in a list of database objects.
  # The object must have an ID and exist in the list
  # eg. users = Util.replace_object_in_list(users, updated_user)
  def replace_object_in_list(list, object) do
    put_in(
      list,
      [Access.filter(&(&1.id == object.id))],
      object
    )
  end
end
