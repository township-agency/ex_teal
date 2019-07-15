<template>
  <header class="fixed flex z-50 h-16 pin-t pin-x">
    <aside
      class="hidden lg:flex lg:w-full flex-none border-r border-grey bg-white items-center px-4 text-black lg:max-w-sidebar"
    >
      <img
        v-if="config.logo"
        :src="config.logo"
        :alt="config.title"
        class="max-h-full py-1"
      >
      <div v-else>
        {{ config.title }}
      </div>
    </aside>
    <nav
      class="flex items-center justify-between flex-grow border-b border-grey bg-grey-lightest px-5"
    >
      <div class="search w-1/2">
        <GlobalSearch />
      </div>
      <dropdown
        v-if="config.currentUser"
        class="ml-auto h-9 flex items-center"
        style="right: 20px"
      >
        <dropdown-trigger
          slot-scope="{ toggle }"
          :handle-click="toggle"
          class="h-9 flex items-center"
        >
          <img
            v-if="config.currentUser.gravatar"
            :src="config.currentUser.gravatar"
            class="rounded-full w-8 h-8 mr-3"
          >

          <span class="text-90"> {{ config.currentUser.name }} </span>
        </dropdown-trigger>

        <dropdown-menu
          slot="menu"
          width="200"
          direction="rtl"
        >
          <ul class="list-reset">
            <li>
              <a
                href="/auth/logout"
                class="block no-underline text-90 hover:bg-30 p-3"
              >
                Logout
              </a>
            </li>
          </ul>
        </dropdown-menu>
      </dropdown>
    </nav>
  </header>
</template>

<script>
import GlobalSearch from './GlobalSearch';
export default {
  name: 'LayoutTopNav',
  components: {
    GlobalSearch
  },
  props: {
    config: {
      type: Object,
      default () {
        return {
          title: '',
          logo: '',
          currentUser: false
        };
      }
    }
  }
};
</script>
