defmodule PetalEnhanceWeb.DashboardLive do
  use PetalEnhanceWeb, :live_view
  alias PetalEnhance.RecipesApi
  alias PetalEnhance.Utils
  alias PetalEnhanceWeb.Components.RecipeUI

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        category: nil,
        loading_recipes: true,
        recipe: nil,
        api_error: nil
      )
      |> assign_recipes_and_categories()

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    if connected?(socket) do
      {:noreply, apply_action(socket, socket.assigns.live_action, params)}
    else
      {:noreply, socket}
    end
  end

  defp apply_action(socket, :index, _) do
    socket
    |> reset_assigns()
    |> assign(:recipe, nil)
    |> assign(:page_title, "Recipes")
  end

  defp apply_action(socket, :category, %{"category" => category}) do
    RecipesApi.log_event(%{event: "api.recipes.list_by_category", category: category})

    socket
    |> reset_assigns()
    |> assign(:recipe, nil)
    |> assign(:page_title, "Recipes: #{Phoenix.Naming.humanize(category)}")
  end

  defp apply_action(socket, :show, %{"id" => recipe_id}) do
    RecipesApi.log_event(%{recipe_id: recipe_id, event: "api.recipes.view"})

    socket =
      socket
      |> reset_assigns()
      |> load_and_assign_full_recipe(recipe_id)

    socket
    |> assign(:page_title, socket.assigns.recipe.name)
  end

  defp apply_action(socket, :diff, %{"id" => recipe_id}) do
    RecipesApi.log_event(%{recipe_id: recipe_id, event: "api.recipes.view_diff"})

    socket =
      socket
      |> reset_assigns()
      |> load_and_assign_full_recipe(recipe_id)

    socket
    |> assign(:page_title, socket.assigns.recipe.name)
  end

  defp apply_action(socket, :apply, %{"id" => recipe_id}) do
    socket =
      socket
      |> reset_assigns()
      |> load_and_assign_full_recipe(recipe_id)

    socket
    |> assign(:page_title, socket.assigns.recipe.name)
  end

  @impl true
  def handle_event("check_patch", _, socket) do
    recipe = socket.assigns.recipe
    RecipesApi.log_event(%{event: "api.recipes.check_works_locally", recipe_id: recipe.id})
    dir = System.tmp_dir!()
    tmp_file = Path.join(dir, "recipe_#{recipe.id}.patch")
    File.write!(tmp_file, recipe.patch)

    cb = fn resp ->
      Process.send(self(), {:blah, resp}, [])
    end

    result = Mix.Shell.cmd("git apply --check #{tmp_file}", [], cb)

    File.rm!(tmp_file)

    state =
      case result do
        0 ->
          :ready_to_apply

        _ ->
          :does_not_apply
      end

    recipe = Map.merge(recipe, %{git_patch_check_state: state})
    socket = replace_recipe(socket, recipe)

    {:noreply, socket}
  end

  @impl true
  def handle_event("apply", _, socket) do
    recipe = socket.assigns.recipe
    RecipesApi.log_event(%{event: "api.recipes.apply", recipe_id: recipe.id})
    dir = System.tmp_dir!()
    tmp_file = Path.join(dir, "recipe_#{recipe.id}.patch")
    File.write!(tmp_file, recipe.patch)
    result = Mix.shell().cmd("git apply #{tmp_file}")
    File.rm!(tmp_file)

    socket =
      if result == 0 do
        put_flash(
          socket,
          :info,
          "Patch applied. You may need to restart your server or reset your database with `mix ecto.reset`."
        )
      else
        put_flash(
          socket,
          :error,
          "Something went wrong. Check the logs. You may have to manually apply by looking at the diffs."
        )
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: Routes.petal_enhance_path(socket, :index))}
  end

  @impl true
  def handle_info({:blah, result}, socket) do
    IO.inspect(result)
    recipe = socket.assigns.recipe
    current_result = recipe[:git_patch_check_result] || ""
    recipe = Map.merge(recipe, %{git_patch_check_result: current_result <> result})
    socket = replace_recipe(socket, recipe)
    {:noreply, socket}
  end

  defp reset_assigns(socket) do
    assign(socket,
      category: nil
    )
  end

  defp assign_recipes_and_categories(socket, current_category \\ nil) do
    socket = maybe_fetch_data(socket)
    current_category = current_category || socket.assigns.default_category

    socket
    |> assign(current_category: current_category)
    |> assign(filtered_recipes: filter_recipes(socket.assigns.recipes, current_category))
  end

  defp filter_recipes(nil, _), do: []
  defp filter_recipes(recipes, nil), do: recipes
  defp filter_recipes(recipes, category), do: Enum.filter(recipes, &(&1.category == category))

  defp load_and_assign_full_recipe(socket, recipe_id) do
    recipe = get_recipe(socket.assigns.recipes || [], recipe_id)

    if recipe_fully_loaded?(recipe) do
      assign(socket, recipe: recipe)
    else
      recipe_full = get_full_recipe(socket.assigns.recipes, recipe_id)
      replace_recipe(socket, recipe_full)
    end
  end

  defp replace_recipe(socket, recipe) do
    recipes_updated = Utils.replace_object_in_list(socket.assigns.recipes, recipe)

    filtered_recipes_updated =
      Utils.replace_object_in_list(socket.assigns.filtered_recipes, recipe)

    assign(socket,
      recipe: recipe,
      recipes: recipes_updated,
      filtered_recipes: filtered_recipes_updated
    )
  end

  defp recipe_fully_loaded?(recipe), do: recipe && recipe[:patch]

  defp get_recipe(all_recipes, recipe_id) do
    recipe_id =
      if is_binary(recipe_id) do
        String.to_integer(recipe_id)
      else
        recipe_id
      end

    Enum.find(all_recipes, &(&1.id == recipe_id))
  end

  defp get_full_recipe(all_recipes, recipe_id) do
    recipe_id =
      if is_binary(recipe_id) do
        String.to_integer(recipe_id)
      else
        recipe_id
      end

    recipe = Enum.find(all_recipes, &(&1.id == recipe_id))

    if recipe_fully_loaded?(recipe) do
      recipe
    else
      {:ok, recipe} = RecipesApi.get(recipe_id)
      recipe
    end
  end

  defp maybe_fetch_data(socket) do
    cond do
      is_list(socket.assigns[:recipes]) ->
        socket

      connected?(socket) ->
        case RecipesApi.all() do
          {:ok, data} ->
            assign(socket,
              recipes: data.recipes,
              categories: data.categories,
              default_category: data.default_category,
              api_error: nil,
              loading_recipes: false
            )

          {:error, error} ->
            assign(socket, %{
              recipes: nil,
              categories: [],
              default_category: nil,
              api_error: error
            })
        end

      true ->
        assign(socket, %{
          recipes: [],
          categories: [],
          default_category: nil
        })
    end
  end
end
