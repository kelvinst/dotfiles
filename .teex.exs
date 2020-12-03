defmodule Teex.Util.Escript do
  @moduledoc false

  def extract_modules(script_path, mod_names) when is_list(mod_names) do
    {:ok, data} = :escript.extract('#{script_path}', [])

    mod_names = Enum.map(mod_names, &'Elixir.#{&1}.beam')

    {:ok, modules} = :zip.extract(data[:archive], [:memory, {:file_list, mod_names}])

    modules
  end

  @spec load_module_object_code(maybe_improper_list) :: :ok
  def load_module_object_code(modules) when is_list(modules) do
    Enum.each(modules, fn {name, code} ->
      name = name |> to_string() |> String.replace(".beam", "")
      :code.load_binary(String.to_atom(name), String.to_charlist(name), code)
    end)
  end
end


Mix.path_for(:escripts)
|> Path.join("teex")
|> Teex.Util.Escript.extract_modules(["Teex", "Teex.Types.Library", "Teex.Types.Workspace", "Teex.Types.Error", "Teex.Util", "Teex.Util.Configuration"])
|> Teex.Util.Escript.load_module_object_code()

IO.puts(:stderr, "Teex has been loaded into your IEx session!")
