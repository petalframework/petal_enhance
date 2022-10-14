defmodule PetalEnhanceWeb.UI do
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  import PetalComponents.Button

  @doc """
  Renders markdown beautifully using Tailwind Typography classes.

      <.pretty_markdown content="# My markdown" />
  """
  def pretty_markdown(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:extra_assigns, fn ->
        assigns_to_attributes(assigns, ~w(
          class
        )a)
      end)

    ~H"""
    <div
      {@extra_assigns}
      class={
        [
          "prose dark:prose-invert prose-img:rounded-xl prose-img:mx-auto prose-a:text-primary-600 prose-a:dark:text-primary-300",
          @class
        ]
      }
    >
      <.markdown content={@content} />
    </div>
    """
  end

  @doc """
  Renders markdown to html.
  """
  def markdown(assigns) do
    ~H"""
    <%= PetalEnhance.MarkdownRenderer.to_html(@content) |> Phoenix.HTML.raw() %>
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

  def modal(assigns) do
    ~H"""
    <div id={@id} phx-mounted={@show && show_modal(@id)} class="relative z-50 hidden">
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
              phx-mounted={@show && show_modal(@id)}
              phx-window-keydown={hide_modal(@on_cancel, @id)}
              phx-key="escape"
              phx-click-away={hide_modal(@on_cancel, @id)}
              class="relative hidden transition bg-white shadow-lg rounded-2xl p-14 shadow-zinc-700/10 ring-1 ring-zinc-700/10"
            >
              <div class="absolute top-6 right-5">
                <button
                  phx-click={hide_modal(@on_cancel, @id)}
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
                    phx-click={hide_modal(@on_cancel, @id)}
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

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.pop_focus()
  end

  def notification(assigns) do
    ~H"""
    <%= if @content do %>
      <div
        phx-value-key={@type}
        id={"flash-#{@type}-#{Timex.to_gregorian_microseconds(Timex.now())}"}
        phx-hook="ClearFlashHook"
        x-data="{
          progress: false,
          show: true,
          timers: [],
          clearFlash() {
            this.show = false;
            $dispatch('clear-flash');
          },
          clearTimers() {
            this.timers.forEach(clearTimeout);
          },
          startTimers() {
            this.timers.push(
              setTimeout(() => {
                this.progress = true;
              }, 50)
            );

            this.timers.push(
              setTimeout(() => {
                this.clearFlash();
              }, 9900)
            );
          }
        }"
        x-init="startTimers()"
        @click="clearFlash()"
        x-show="show"
        class={
          "#{notification_css(@type)} transition duration-300 opacity-100 fixed bottom-0 right-0 z-[9999] w-5/6 max-w-sm m-4 rounded-lg shadow-lg pointer-events-auto text-white sm:w-full"
        }
      >
        <div class="overflow-hidden rounded-lg shadow-xs">
          <div
            class={"#{progress_css(@type)} h-2 progress ease-linear w-0"}
            style="transition-property:width; transition-duration: 10s"
            x-bind:style="progress && {width: '100%'}"
          >
          </div>
          <div class="flex items-start p-4">
            <div class="flex-shrink-0">
              <%= if @type == "success" do %>
                <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path
                    path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                  >
                  </path>
                </svg>
              <% end %>

              <%= if @type == "info" do %>
                <svg class="w-6 h-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
              <% end %>

              <%= if @type == "warning" do %>
                <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
              <% end %>

              <%= if @type == "error" do %>
                <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
              <% end %>
            </div>
            <div class="ml-3 w-0 flex-1 pt-0.5">
              <div class="text-sm font-medium leading-5 text-white">
                <div class="whitespace-pre-line"><%= @content %></div>
              </div>
            </div>
            <div class="flex flex-shrink-0 ml-4">
              <button class="inline-flex text-white transition duration-150 ease-in-out focus:outline-none focus:text-gray-300">
                <svg class="w-5 h-5" viewBox="0 0 20 20" fill="currentColor">
                  <path
                    fill-rule="evenodd"
                    d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                    clip-rule="evenodd"
                  >
                  </path>
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  def notification_css(type) do
    case type do
      :success -> "bg-green-600"
      :info -> "bg-blue-600"
      :warning -> "bg-yellow-600"
      :error -> "bg-red-600"
    end
  end

  def progress_css(type) do
    case type do
      :success -> "bg-green-800 opacity-100 "
      :info -> "bg-blue-800 opacity-100 "
      :warning -> "bg-yellow-800 opacity-100 "
      :error -> "bg-red-800 opacity-100 "
    end
  end
end
