import Vue from 'vue';
import App from './App.vue';
import PortalVue from 'portal-vue';
import Toasted from 'vue-toasted';

import router from '@/router';
import axios from '@/util/axios';

Vue.use(Toasted, {
  theme: 'nova',
  position: 'bottom-right',
  duration: 6000
});

Vue.use(PortalVue);

export default class ExTeal {
  constructor (config) {
    this.bus = new Vue();
    this.bootingCallbacks = [];
    this.config = config;
  }

  /**
   * Register a callback to be called before ExTeal starts. This is used to bootstrap
   * addons, tools, custom fields, or anything else ExTeal needs
   */
  booting (callback) {
    this.bootingCallbacks.push(callback);
  }

  /**
   * Execute all of the booting callbacks.
   */
  boot () {
    this.bootingCallbacks.forEach(callback => callback(Vue, router));

    this.bootingCallbacks = [];
  }

  /**
   * Start the ExTeal app by calling each of the tool's callbacks and then creating
   * the underlying Vue instance.
   */
  beamMeUp () {
    const _this = this;

    this.boot();

    this.app = new Vue({
      router,
      mounted: function () {
        this.$loading = this.$refs.loading;

        _this.$on('error', message => {
          this.$toasted.show(message, { type: 'error' });
        });
      },

      render (createElement) {
        return createElement(App, {
          props: {
            configLoaded: true,
            config: config
          }
        });
      }
    }).$mount('#app');
  }

  /**
   * Return an axios instance configured to make requests to ExTeal's API
   * and handle certain response codes.
   */
  request (options) {
    if (options !== undefined) {
      return axios(options);
    }

    return axios;
  }

  /**
   * Register a listener on ExTeal's built-in event bus
   */
  $on (...args) {
    this.bus.$on(...args);
  }

  /**
   * Register a one-time listener on the event bus
   */
  $once (...args) {
    this.bus.$once(...args);
  }

  /**
   * De-register a listener on the event bus
   */
  $off (...args) {
    this.bus.$off(...args);
  }

  /**
   * Emit an event on the event bus
   */
  $emit (...args) {
    this.bus.$emit(...args);
  }
}
