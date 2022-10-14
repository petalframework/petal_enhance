defmodule PetalEnhanceWeb.Components.RecipeUI do
  use PetalEnhanceWeb, :component

  attr :socket, :map, required: true
  attr :categories, :list, required: true
  attr :current_category, :string
  attr :filtered_recipes, :list, default: []

  def grid(assigns) do
    ~H"""
    <%= if @filtered_recipes == [] do %>
      <div class="mt-10">
        No recipes for "<%= @current_category |> Phoenix.Naming.humanize() %>" yet.
      </div>
    <% end %>

    <div class="grid grid-cols-1 col-span-3 mt-10 gap-y-6 gap-x-6 sm:grid-cols-3 sm:gap-y-10 md:grid-cols-4 xl:gap-x-8">
      <%= for recipe <- @filtered_recipes do %>
        <.recipe_card recipe={recipe} socket={@socket} />
      <% end %>
    </div>
    """
  end

  attr :recipe, :map, required: true
  attr :socket, :map, required: true

  def recipe_card(assigns) do
    ~H"""
    <div
      id={"recipe-card-#{@recipe.id}"}
      class="flex flex-col justify-between border rounded-lg border-zinc-900/10"
    >
      <!-- Img + Content is clickable -->
      <div class="relative">
        <div class="relative aspect-[2/1] overflow-hidden rounded-t-lg bg-zinc-100 border-b border-zinc-900/10">
          <%= if @recipe.image_url do %>
            <img class="absolute inset-0 w-full h-full" src={@recipe.image_url} />
          <% else %>
            <div class="flex items-center justify-center w-full h-full text-lg">
              <%= @recipe.name %>
            </div>
          <% end %>
        </div>

        <div class="p-3">
          <.link
            patch={Routes.petal_enhance_path(@socket, :show, @recipe.id)}
            class="block mt-4 font-medium text-slate-900"
          >
            <span class="absolute -inset-px rounded-xl"></span>
            <%= @recipe.name %>
          </.link>

          <div class="mt-1.5 text-sm text-slate-500">
            <div class="line-clamp-3"><%= @recipe.summary %></div>
          </div>
        </div>
      </div>
      <!-- Footer -->
      <div class="flex items-center justify-between gap-3 p-3">
        <img
          class="w-8 h-8 rounded-full"
          data-tippy-content={"Created by " <> @recipe.creator_name}
          phx-hook="TippyHook"
          src={@recipe.creator_avatar}
          alt={@recipe.creator_name}
          id={"recipe-creator-#{@recipe.id}"}
        />

        <div
          id={"recipe-downloads-#{@recipe.id}"}
          class="flex items-center gap-2 text-sm text-zinc-500"
          data-tippy-content="Number of projects that have applied this"
          phx-hook="TippyHook"
        >
          <Heroicons.arrow_down_tray class="w-4 h-4" />
          <div><%= @recipe.downloads %></div>
        </div>
      </div>
    </div>
    """
  end

  attr :recipe, :map, required: true
  attr :socket, :map, required: true
  attr :live_action, :atom, required: true

  def show(assigns) do
    ~H"""
    <.h3><%= @recipe.name %></.h3>

    <div class="mt-1.5 text-slate-500">
      <%= @recipe.summary %>
    </div>

    <.tabs underline class="mt-5">
      <.tab
        underline
        link_type="live_patch"
        is_active={@live_action == :show}
        to={Routes.petal_enhance_path(@socket, :show, @recipe.id)}
      >
        <Heroicons.document_text mini class="w-4 h-4 mr-2" /> Readme
      </.tab>
      <.tab
        underline
        link_type="live_patch"
        is_active={@live_action == :diff}
        to={Routes.petal_enhance_path(@socket, :diff, @recipe.id)}
      >
        <Heroicons.arrows_right_left mini class="w-4 h-4 mr-2" /> Diff
      </.tab>
      <.tab
        underline
        link_type="live_patch"
        is_active={@live_action == :apply}
        to={Routes.petal_enhance_path(@socket, :apply, @recipe.id)}
      >
        <Heroicons.play mini class="w-4 h-4 mr-2" /> Apply
      </.tab>
    </.tabs>

    <div class="min-h-[100px] pt-5 border-b border-r border-l p-5 border-gray-200 dark:border-gray-600">
      <%= case @live_action do %>
        <% :show -> %>
          <div id={"recipe_description_#{@recipe.id}"}>
            <%= if @recipe.readme && @recipe.readme != "" do %>
              <UI.pretty_markdown content={@recipe.readme} />
            <% else %>
              <div class="text-sm">No README provided</div>
            <% end %>
          </div>
        <% :diff -> %>
          <div id={"recipe_diff_#{@recipe.id}"} class="relative">
            <div id={"recipe-diff-#{@recipe.id}"} phx-hook="DiffHook" data-diff={@recipe.patch}></div>
          </div>
        <% :apply -> %>
          <div id={"recipe_description_#{@recipe.id}"}>
            <%= if @recipe[:git_patch_check_state] == nil do %>
              <div class="flex items-center gap-3">
                <.button color="white" phx-click="check_patch" icon>
                  <Heroicons.question_mark_circle mini class="w-4 h-4" /> Check if patch works locally
                </.button>
                <div class="text-sm text-zinc-500">
                  This won't apply the patch, it simply runs `git apply --check` to see if it will work with your files.
                </div>
              </div>
            <% end %>

            <%= if @recipe[:git_patch_check_state] == :ready_to_apply do %>
              <.alert with_icon color="success" label="Patch can be applied" class="mb-3" />

              <.button
                id={"recipe_#{@recipe.id}_apply_patch"}
                size="sm"
                color="success"
                phx-click="apply"
                icon
                phx-value-recipe={@recipe.id}
                data-confirm="This will apply the changes to your git working directory (it won't commit anything). Ensure you have no current changes in your git working directory so you can see exactly what this recipe changes. Also, the server might crash right after this if the recipe happens to modify config files. Continue?"
              >
                <Heroicons.sparkles mini class="w-4 h-4" /> Apply patch
              </.button>
            <% end %>

            <%= if @recipe[:git_patch_check_state] == :does_not_apply do %>
              <.alert with_icon color="danger" label="`git apply --check` failed." class="mb-3" />

              <pre class="w-full p-2 mb-5 overflow-scroll text-sm text-white bg-gray-800 rounded"><%= @recipe[:git_patch_check_result] %></pre>

              <div class="flex justify-between">
                <div class="flex gap-2">
                  <.button color="white" phx-click="check_patch" icon size="sm">
                    <Heroicons.arrow_path mini class="w-4 h-4" /> Check again
                  </.button>

                  <.button
                    size="sm"
                    color="white"
                    icon
                    id={"copy_patch_#{@recipe.id}"}
                    phx-hook="ClipboardHook"
                    data-content={@recipe.patch}
                  >
                    <Heroicons.clipboard_document
                      mini
                      class="hidden w-5 h-5 text-slate-500 hover:text-slate-400 dark:text-slate-400 dark:hover:text-slate-300"
                    />
                    <Heroicons.clipboard_document_check
                      mini
                      class="hidden w-5 h-5 text-green-500 dark:text-green-400"
                    /> Copy patch
                  </.button>
                </div>

                <.button
                  size="sm"
                  color="white"
                  phx-click="apply"
                  icon
                  phx-value-recipe={@recipe.id}
                  data-confirm="This will apply the changes to your git working directory (it won't commit anything). Ensure you have no current changes in your git working directory so you can see exactly what this recipe changes. Also, the server might crash right after this if the recipe happens to modify config files. Continue?"
                >
                  <Heroicons.play mini class="w-4 h-4" /> Apply patch anyway
                </.button>
              </div>
            <% end %>
          </div>
      <% end %>
    </div>

    <div class="flex items-center justify-between gap-3 mt-5">
      <div class="flex items-center gap-2">
        <img class="w-8 h-8 rounded-full" src={@recipe.creator_avatar} alt={@recipe.creator_name} />
        <div class="text-sm text-gray-500">
          <%= "Created by " <> @recipe.creator_name %>
        </div>
      </div>

      <div class="flex items-center gap-2"></div>
    </div>
    """
  end
end
