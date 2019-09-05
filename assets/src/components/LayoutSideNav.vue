<template>
  <div id="sidebar">
    <div class="lg:block lg:relative lg:top-16 w-sidebar">
      <nav
        id="nav"
        class="sticky?lg:h-(screen-16)"
      >
        <h3><span>Dashboards</span></h3>
        <ul>
          <li
            v-for="dashboard in availableDashboards"
            :key="dashboard.uri"
          >
            <router-link
              :to="{
                name: 'dashboard.custom',
                params: {
                  uri: dashboard.uri
                }
              }"
            >
              {{ dashboard.title }}
            </router-link>
          </li>
        </ul>
        <h3><span>Resources</span></h3>
        <ul class="">
          <li
            v-for="resource in availableResources"
            :key="resource.plural"
          >
            <router-link
              :to="{
                name: 'index',
                params: {
                  resourceName: resource.uri
                }
              }"
            >
              {{ resource.title }}
            </router-link>
          </li>
        </ul>
        <div
          v-for="plugin in pluginsWithNavComponents"
          :key="plugin.uri"
        >
          <component :is="plugin.navigation_component" />
        </div>
      </nav>
    </div>
  </div>
</template>

<script>
import filter from 'lodash/filter';
import identity from 'lodash/identity';
export default {
  props: {
    config: {
      type: Object,
      default: function () {
        return {};
      }
    }
  },

  computed: {
    availableResources () {
      return filter(this.config.resources, resource => {
        return !resource.hidden;
      });
    },

    availableDashboards () {
      return filter(this.config.dashboards, dashboard => {
        return !dashboard.hidden;
      });
    },

    pluginsWithNavComponents () {
      return filter(this.config.plugins, plugin => {
        return identity(plugin.navigation_component);
      });
    }
  }
};
</script>

<style>
#sidebar {
  @apply .hidden .z-50 .bg-white .overflow-x-hidden .border-r;
  top: 4rem;
  bottom: 0rem;
}

@screen lg {
  #sidebar {
    @apply .fixed .block;
    @apply .pin-l .pt-0 .overflow-y-auto .w-sidebar .mr-0;
  }
}

#nav {
  @apply .pt-6 .overflow-y-auto .text-base;
}

@screen lg {
  #nav {
    @apply .text-sm .w-sidebar;
  }
}

#nav h3 {
  @apply .px-6 .mb-2 .no-underline .text-xs .text-70 .font-normal;
}

#nav a {
  @apply .px-6 .py-1 .text-base .text-black .no-underline .block;
}

#nav a:hover {
  @apply .text-80;
}

#nav a.router-link-active {
  @apply .bg-primary .text-white;
}

#nav ul {
  @apply .list-reset .mb-8 .text-lg;
}
</style>
