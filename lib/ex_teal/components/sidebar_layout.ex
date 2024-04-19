defmodule ExTeal.Components.SidebarLayout do
  @moduledoc """
  A responsive layout with a left sidebar (main menu), as well as a drop down menu up the top right (user menu).

  Generates Menu content from the `menu/1` function in the manifest.
  """
  use ExTeal.Web, :live_component

  def sidebar_layout(assigns) do
    ~H"""
    <div
      class="flex h-screen overflow-hidden dark:bg-gray-900"
      x-data="{sidebarOpen: false, collapsedOnly: false, isCollapsible: true, isCollapsed: $persist(false)}"
    >
      <div
        class="transition-transform relative z-40"
        x-bind:class="isCollapsed ? 'w-min lg:w-min' : 'lg:w-64'"
      >
        <div
          x-show="sidebarOpen"
          x-transition:enter="transition-opacity ease-linear duration-300"
          x-transition:enter-start="opacity-0"
          x-transition:enter-end="opacity-100"
          x-transition:leave="transition-opacity ease-linear duration-300"
          x-transition:leave-start="opacity-100"
          x-transition:leave-end="opacity-0"
          class="fixed inset-0 bg-gray-900/80"
        >
        </div>
        <button
          class="absolute transition-colors -right-[12px] z-50 top-[51px] bg-white hover:bg-gray-50 dark:hover:bg-gray-900 dark:bg-gray-800 text-gray-700 hover:text-gray-900 dark:hover:text-gray-50 dark:text-gray-100 lg:flex hidden border border-gray-200 dark:border-gray-700 rounded-md w-[25px] h-[25px] justify-center items-center"
          x-bind:class="isCollapsed ? 'mb-1 mx-auto' : 'mb-0 ml-0.5'"
          @click="isCollapsed = !isCollapsed"
          x-cloak
        >
          <span class="sr-only">
            Collapse sidebar
          </span>
          <div class="flex flex-row -space-x-[4px] m-1">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="w-3 h-3 fill-current"
              aria-hidden="true"
              fill="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                fill-rule="evenodd"
                d="M7.72 12.53a.75.75 0 0 1 0-1.06l7.5-7.5a.75.75 0 1 1 1.06 1.06L9.31 12l6.97 6.97a.75.75 0 1 1-1.06 1.06l-7.5-7.5Z"
                clip-rule="evenodd"
              />
            </svg>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="w-3 h-3 fill-current"
              aria-hidden="true"
              fill="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                fill-rule="evenodd"
                d="M16.28 11.47a.75.75 0 0 1 0 1.06l-7.5 7.5a.75.75 0 0 1-1.06-1.06L14.69 12 7.72 5.03a.75.75 0 0 1 1.06-1.06l7.5 7.5Z"
                clip-rule="evenodd"
              />
            </svg>
          </div>
        </button>

        <div
          id="sidebar"
          class="absolute top-0 left-0 z-40 flex-shrink-0 h-screen p-4 overflow-y-auto transition-transform duration-200 ease-in-out transform border-r lg:static lg:left-auto lg:top-auto lg:translate-x-0 lg:overflow-y-auto no-scrollbar bg-white dark:bg-gray-900 border-gray-200 dark:border-gray-700"
          x-bind:class="
            {
              'w-64': sidebarOpen &amp;&amp; !isCollapsed,
              '-translate-x-full': !sidebarOpen,
              'translate-x-0': sidebarOpen,
              'w-min': isCollapsed,
            }
          "
          @click.away="sidebarOpen = false"
          @keydown.escape.window="sidebarOpen = false"
          x-cloak
        >
          <div
            x-bind:class="isCollapsible && isCollapsed ? 'flex-col-reverse lg:flex-row' : 'pr-3'"
            class="flex justify-between mb-8 sm:px-2"
          >
            <button
              x-bind:class="isCollapsible && isCollapsed ? 'mx-auto' : ''"
              class="text-gray-500 lg:hidden hover:text-gray-400"
              @click.stop="sidebarOpen = !sidebarOpen"
              aria-controls="sidebar"
              x-bind:aria-expanded="sidebarOpen"
            >
              <span class="sr-only">
                Close sidebar
              </span>
              <svg class="w-6 h-6 fill-current" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path d="M10.7 18.7l1.4-1.4L7.8 13H20v-2H7.8l4.3-4.3-1.4-1.4L4 12z"></path>
              </svg>
            </button>

            <a
              href="/app"
              data-phx-link="redirect"
              data-phx-link-state="push"
              class="block"
              x-show="!isCollapsed"
            >
              <img
                class="h-8 transition-transform duration-300 ease-out transform hover:scale-105 block dark:hidden"
                src="/assets/images/logo_dark.svg"
                alt="Petal"
              />
              <img
                class="h-8 transition-transform duration-300 ease-out transform hover:scale-105 hidden dark:block"
                src="/assets/images/logo_light.svg"
                alt="Petal"
              />
            </a>

            <a
              href="/app"
              data-phx-link="redirect"
              data-phx-link-state="push"
              class="block"
              x-show="isCollapsed"
              x-bind:class="isCollapsible &amp;&amp; isCollapsed ? &#39;mb-4 lg:mb-0&#39; : &#39;&#39;"
            >
              <img
                class="h-9 w-9 block dark:hidden"
                src="/teal/assets/images/logo_icon_dark.svg?vsn=d"
                alt="Petal"
              />
              <img
                class="h-9 w-9 hidden dark:block"
                src="/teal/assets/images/logo_icon_light.svg?vsn=d"
                alt="Petal"
              />
            </a>
          </div>
          <div>
            <nav>
              <div class="divide-y divide-gray-300">
                <div class="space-y-1">
                  <a
                    href="/app"
                    data-phx-link="redirect"
                    data-phx-link-state="push"
                    id="menu_item_dashboard_anchor"
                    class="flex items-center text-sm font-semibold leading-none px-3 py-2 transition duration-200 rounded-md group text-primary-700 dark:text-primary-400 bg-gray-50 dark:bg-gray-800 gap-0 w-min"
                    x-bind:class="isCollapsed ? 'gap-0 w-min' : 'gap-3 w-full'"
                    phx-hook="TippyHook"
                    data-tippy-content="Dashboard"
                    data-tippy-placement="right"
                    x-bind:data-disable-tippy-on-mount="!isCollapsed"
                    x-effect="isCollapsed ? $el?._tippy?.enable() : $el?._tippy?.disable()"
                  >
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      class="w-5 h-5 flex-shrink-0"
                      aria-hidden="true"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                      stroke-width="1.5"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M2.25 7.125C2.25 6.504 2.754 6 3.375 6h6c.621 0 1.125.504 1.125 1.125v3.75c0 .621-.504 1.125-1.125 1.125h-6a1.125 1.125 0 0 1-1.125-1.125v-3.75ZM14.25 8.625c0-.621.504-1.125 1.125-1.125h5.25c.621 0 1.125.504 1.125 1.125v8.25c0 .621-.504 1.125-1.125 1.125h-5.25a1.125 1.125 0 0 1-1.125-1.125v-8.25ZM3.75 16.125c0-.621.504-1.125 1.125-1.125h5.25c.621 0 1.125.504 1.125 1.125v2.25c0 .621-.504 1.125-1.125 1.125h-5.25a1.125 1.125 0 0 1-1.125-1.125v-2.25Z"
                      >
                      </path>
                    </svg>

                    <div
                      class="hidden"
                      x-bind:class="isCollapsible &amp;&amp; isCollapsed ? 'hidden' : 'flex-1'"
                    >
                      Dashboard
                    </div>
                  </a>
                  <a
                    href="/app/orgs"
                    data-phx-link="redirect"
                    data-phx-link-state="push"
                    id="menu_item_organizations_anchor"
                    class="flex items-center text-sm font-semibold leading-none px-3 py-2 transition duration-200 rounded-md group text-gray-700 hover:bg-gray-50 dark:text-gray-200 hover:text-gray-900 dark:hover:text-white dark:hover:bg-gray-700 gap-0 w-min"
                    x-bind:class="isCollapsed ? 'gap-0 w-min' : 'gap-3 w-full'"
                    phx-hook="TippyHook"
                    data-tippy-content="Organizations"
                    data-tippy-placement="right"
                    x-bind:data-disable-tippy-on-mount="!isCollapsed"
                    x-effect="isCollapsed ? $el?._tippy?.enable() : $el?._tippy?.disable()"
                  >
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      class="w-5 h-5 flex-shrink-0"
                      aria-hidden="true"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                      stroke-width="1.5"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M3.75 21h16.5M4.5 3h15M5.25 3v18m13.5-18v18M9 6.75h1.5m-1.5 3h1.5m-1.5 3h1.5m3-6H15m-1.5 3H15m-1.5 3H15M9 21v-3.375c0-.621.504-1.125 1.125-1.125h3.75c.621 0 1.125.504 1.125 1.125V21"
                      >
                      </path>
                    </svg>

                    <div
                      class="hidden"
                      x-bind:class="isCollapsible &amp;&amp; isCollapsed ? 'hidden' : 'flex-1'"
                    >
                      Organizations
                    </div>
                  </a>
                </div>
              </div>
            </nav>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
