defmodule SamMedia.Support.EnumsHelper do
  defmacro enum(name, do: block) do
    enum_values =
      case block do
        {_, _, values} when is_list(values) ->
          values

        _ ->
          quote do
            {:error, "please provide Map with %{key: value} for enum"}
          end
      end

    quote do
      def unquote(:"#{name}")() do
        unquote(enum_values)
      end
    end
  end
end
