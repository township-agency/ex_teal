<template>
  <div
    id="app"
    class="h-screen flex overflow-hidden bg-grey-lightest"
  >
    <!-- Off-canvas menu for mobile -->
    <div
      v-show="navOpen"
      class="md:hidden"
    >
      <div class="fixed inset-0 flex z-40">
        <!-- Off-canvas mobile menu overlay -->
        <transition
          enter-active-class="transition-opacity ease-linear duration-300"
          enter-class="opacity-0"
          enter-to-class="opacity-100"
          leave-active-class="transition-opacity ease-linear duration-300"
          leave-class="opacity-100"
          leave-to-class="opacity-0"
          @after-leave="menuClosed"
        >
          <div
            v-show="mobileNav"
            class="fixed inset-0"
          >
            <div class="absolute inset-0 bg-grey opacity-75" />
          </div>
        </transition>

        <transition
          enter-active-class="transition ease-in-out duration-300 transform"
          enter-class="-translate-x-full"
          enter-to-class="translate-x-0"
          leave-active-class="transition ease-in-out duration-300 transform"
          leave-class="translate-x-0"
          leave-to-class="-translate-x-full"
        >
          <div
            v-if="mobileNav"
            class="relative z-40 flex-1 flex-col max-w-sidebar w-full pt-5 pb-4 bg-white"
          >
            <div class="absolute top-0 right-0 -mr-16 p-1">
              <button
                class="flex items-center justify-center h-12 w-12 rounded-full focus:outline-none focus:bg-gray-600"
                aria-label="Close sidebar"
                @click="closeMobileNav"
              >
                <svg
                  class="h-6 w-6 text-white"
                  stroke="currentColor"
                  fill="none"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </button>
            </div>
            <div class="flex-shrink-0 flex items-center px-4 h-8">
              <img
                v-if="config.logo"
                :src="config.logo"
                :alt="config.title"
                class="max-h-full w-auto"
              >
            </div>
            <div class="mt-5 flex-1 overflow-y-auto mb-5 absolute top-16 bottom-0">
              <nav class="layout-side-nav--nav">
                <LayoutSideNav :config="config" />
              </nav>
            </div>
          </div>
        </transition>
        <div
          v-if="mobileNav"
          class="flex-shrink-0 w-16 z-0"
        />
      </div>
    </div>
    <!--  -->

    <div class="hidden md:flex md:flex-shrink-0">
      <div class="flex flex-col w-sidebar border-r border-grey pt-5 pb-4 bg-white">
        <div class="flex items-center flex-shrink-0 px-4">
          <img
            v-if="config.logo"
            :src="config.logo"
            :alt="config.title"
            class="h-8 w-auto"
          >
        </div>
        <div class="mt-5 h-0 flex-1 flex flex-col overflow-y-auto">
          <nav class="layout-side-nav--nav flex-1 bg-white">
            <LayoutSideNav :config="config" />
          </nav>
        </div>
      </div>
    </div>
    <div class="flex flex-col w-0 flex-1 overflow-hidden">
      <LayoutTopNav
        :config="config"
        @openNav="openMobileNav"
      />

      <main
        class="flex-1 relative z-0 overflow-y-auto py-6 focus:outline-none"
        tabindex="0"
      >
        <div class="mx-auto px-4 sm:px-6 md:px-8">
          <router-view />
        </div>
      </main>
    </div>
    
    <portal-target
      name="modals"
      multiple
    />
  </div>
</template>

<script>
import LayoutTopNav from '@/components/LayoutTopNav';
import LayoutSideNav from '@/components/LayoutSideNav';
import './assets/css/main.css';
import './assets/css/flatpickr.css';
import './assets/css/trix.css';

export default {
  name: 'App',
  components: {
    LayoutTopNav,
    LayoutSideNav
  },
  props: {
    configLoaded: {
      type: Boolean,
      default: false
    },
    config: {
      type: Object,
      default () {
        return {};
      }
    }
  },

  data () {
    return {
      mobileNav: false,
      navOpen: false,
    };
  },

  computed: {
    mobileNavClass () {
      return {
        'fixed inset-0 flex z-50': true,
        // 'z-50': this.mobileNav,
        // 'az-0 opacity-0': !this.mobileNav
      };
    }
  },

  methods: {
    closeMobileNav () {
      this.mobileNav = false;
    },
    openMobileNav () {
      this.mobileNav = true;
      this.navOpen = true;
    },
    menuClosed () {
      this.navOpen = false;
    }
  }
};
</script>
