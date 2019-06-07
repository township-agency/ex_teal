<template>
  <div id="app">
    <loading-view
      :loading="!configLoaded"
    >
      <LayoutTopNav
        :config="config"
        :title="config.title"
        :logo="config.logo"
      />
      <LayoutSideNav :config="config" />
      <main :class="layoutClass">
        <div class="lg:flex -mx-6">
          <div
            id="content-wrapper"
            class="w-full"
          >
            <div class="p-5 mx-auto">
              <router-view />
            </div>
          </div>
        </div>
      </main>
    </loading-view>
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

  computed: {
    layoutClass () {
      const auth = this.config.authenticated;
      return `global-wrapper ${auth ? 'auth' : 'guest'}`;
    }
  }
};
</script>
