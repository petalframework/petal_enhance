defmodule PetalEnhanceWeb.Components.RecipeUI do
  use PetalEnhanceWeb, :component

  attr :socket, :map, required: true
  attr :router_helpers, :map, required: true
  attr :current_category, :string
  attr :filtered_recipes, :list, default: []

  def grid(assigns) do
    ~H"""
    <%= if @filtered_recipes == [] do %>
      <div class="mt-10">
        No recipes for "<%= @current_category |> Phoenix.Naming.humanize() %>" yet.
      </div>
    <% end %>

    <div class="grid grid-cols-1 col-span-3 mt-10 gap-y-6 gap-x-6 sm:grid-cols-3 sm:gap-y-10 xl:gap-x-8">
      <%= for recipe <- @filtered_recipes do %>
        <.recipe_card recipe={recipe} socket={@socket} router_helpers={@router_helpers} />
      <% end %>
    </div>
    """
  end

  attr :recipe, :map, required: true
  attr :router_helpers, :map, required: true
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
        <div class="flex justify-between mb-3">
          <div class="text-sm font-medium text-primary-500"><%= @recipe.boilerplates_supported |> Enum.join(", ") %></div>
          <div class="text-sm font-medium">Free</div>
        </div>
          <.link
            patch={@router_helpers.petal_enhance_path(@socket, :show, @recipe.id)}
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

      <!-- Clickable tags (eventually) -->
      <div :if={length(@recipe.tags) > 0} class="flex flex-wrap gap-2 p-3 text-sm font-light">
        <%= for tag <- @recipe.tags do %>
          <div class="px-2 py-1 border border-gray-100 rounded dark:border-gray-700">
            <%= tag %>
          </div>
        <% end %>
      </div>

      <!-- Footer -->
      <div class="flex items-center justify-between gap-3 p-3">
        <.recipe_author recipe={@recipe} />

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

  def recipe_author(assigns) do
    ~H"""
    <dd class="flex items-center space-x-3">
      <img
        class="w-8 h-8 rounded-full"
        src={@recipe.creator_avatar}
        alt={@recipe.creator_name}
        id={"recipe-creator-#{@recipe.id}"}
      />

      <dl class="text-xs leading-5 whitespace-no-wrap">
        <dt class="sr-only">Name</dt>
        <dd class="font-semibold text-slate-700"><%= @recipe.creator_name %></dd>
      </dl>
    </dd>
    """
  end

  attr :recipe, :map, required: true
  attr :socket, :map, required: true
  attr :router_helpers, :map, required: true
  attr :live_action, :atom, required: true

  def show_recipe(assigns) do
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
        to={@router_helpers.petal_enhance_path(@socket, :show, @recipe.id)}
      >
        <Heroicons.document_text mini class="w-4 h-4 mr-2" /> Readme
      </.tab>
      <.tab
        underline
        link_type="live_patch"
        is_active={@live_action == :diff}
        to={@router_helpers.petal_enhance_path(@socket, :diff, @recipe.id)}
      >
        <Heroicons.arrows_right_left mini class="w-4 h-4 mr-2" /> Diff
      </.tab>
      <.tab
        underline
        link_type="live_patch"
        is_active={@live_action == :apply}
        to={@router_helpers.petal_enhance_path(@socket, :apply, @recipe.id)}
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
            <div id={"recipe-diff-#{@recipe.id}"} phx-hook="DiffHook" data-diff={@recipe.patch.diff}></div>
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
                    data-content={@recipe.patch.diff}
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

  @doc """
  Renders a modal.
  ## Examples
      <.modal id="confirm-modal">
        Are you sure?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>
  JS commands may be passed to the `:on_cancel` and `on_confirm` attributes
  for the caller to reactor to each button press, for example:
      <.modal id="confirm" on_confirm={JS.push("delete")} on_cancel={JS.navigate(~p"/posts")}>
        Are you sure you?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :on_confirm, JS, default: %JS{}

  slot :inner_block, required: true
  slot :title
  slot :subtitle
  slot :confirm
  slot :cancel

  def recipe_modal(assigns) do
    ~H"""
    <div id={@id} phx-mounted={@show && show_recipe_modal(@id)} class="relative z-50 hidden">
      <div id={"#{@id}-bg"} class="fixed inset-0 transition-opacity bg-zinc-50/90" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex justify-center min-h-full">
          <div class="w-full max-w-6xl p-4 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-mounted={@show && show_recipe_modal(@id)}
              phx-window-keydown={hide_recipe_modal(@on_cancel, @id)}
              phx-key="escape"
              phx-click-away={hide_recipe_modal(@on_cancel, @id)}
              class="relative hidden transition bg-white shadow-lg rounded-2xl p-14 shadow-zinc-700/10 ring-1 ring-zinc-700/10"
            >
              <div class="absolute top-6 right-5">
                <button
                  phx-click={hide_recipe_modal(@on_cancel, @id)}
                  type="button"
                  class="flex-none p-3 -m-3 opacity-20 hover:opacity-40"
                  aria-label="Close"
                >
                  <Heroicons.x_mark solid class="w-5 h-5 stroke-current" />
                </button>
              </div>
              <div id={"#{@id}-content"}>
                <header :if={@title != []}>
                  <h1 id={"#{@id}-title"} class="text-lg font-semibold leading-8 text-zinc-800">
                    <%= render_slot(@title) %>
                  </h1>
                  <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
                    <%= render_slot(@subtitle) %>
                  </p>
                </header>
                <%= render_slot(@inner_block) %>
                <div :if={@confirm != [] or @cancel != []} class="flex items-center gap-5 mb-4 ml-6">
                  <.button
                    :for={confirm <- @confirm}
                    id={"#{@id}-confirm"}
                    phx-click={@on_confirm}
                    phx-disable-with
                    class="px-3 py-2"
                  >
                    <%= render_slot(confirm) %>
                  </.button>
                  <.link
                    :for={cancel <- @cancel}
                    phx-click={hide_recipe_modal(@on_cancel, @id)}
                    class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                  >
                    <%= render_slot(cancel) %>
                  </.link>
                </div>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  ## JS Commands
  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end
  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_recipe_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
  end

  def hide_recipe_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.pop_focus()
  end
end
