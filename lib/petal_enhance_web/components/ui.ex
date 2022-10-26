defmodule PetalEnhanceWeb.UI do
  use Phoenix.Component

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
