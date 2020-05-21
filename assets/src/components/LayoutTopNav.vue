<template>
  <header class="relative flex items-center h-16 border-b border-grey bg-grey-lightest px-4 sm:px-6 md:px-8">
    <button
      class="hover:bg-grey-lightest md:hidden flex-grow-0 mr-4 z-10"
      @click="openSideNav"
    >
      <icon type="menu" />
    </button>
    <nav
      class="flex items-center justify-between flex-1"
    >
      <div class="search w-1/2">
        <GlobalSearch />
      </div>
      <div>
        <dropdown
          v-if="config.currentUser"
          class="ml-auto h-9 flex items-center"
        >
          <dropdown-trigger
            slot-scope="{ toggle }"
            :handle-click="toggle"
            class="h-9 flex items-center"
          >
            <img
              v-if="config.currentUser.avatar_url"
              :src="config.currentUser.avatar_url"
              class="rounded-full w-8 h-8 mr-3"
            >

            <span class="text-90"> {{ config.currentUser.name }} </span>
          </dropdown-trigger>

          <dropdown-menu
            slot="menu"
            width="200"
            direction="rtl"
          >
            <ul class="layout-top-nav--dropdown">
              <li
                v-for="(dropdown, i) in config.dropdown"
                :key="i"
                v-html="dropdown"
              />
            </ul>
          </dropdown-menu>
        </dropdown>
      </div>
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
  },

  methods: {
    openSideNav () {
      this.$emit('openNav');
    }
  }
};
</script>
