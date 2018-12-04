<template>
  <div id="sidebar">
    <div class="lg:block lg:relative lg:sticky lg:top-16 ">
      <nav id="nav" class="sticky?lg:h-(screen-16)">
        <h3><span>Resources</span></h3>
        <ul class="">
          <li v-for="resource in availableResources" :key="resource.plural">
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
        <div v-for="plugin in pluginsWithNavComponents" :key="plugin.uri">
          <component :is="plugin.navigation_component" />
        </div>
      </nav>
    </div>
  </div>
</template>

<script>
import filter from "lodash/filter";
import identity from "lodash/identity";
export default {
  props: {
    config: {
      type: Object,
      default: function() {
        return {};
      }
    }
  },

  computed: {
    availableResources() {
      return filter(this.config.resources, resource => {
        return !resource.hidden;
      });
    },

    pluginsWithNavComponents() {
      return filter(this.config.plugins, plugin => {
        return identity(plugin.navigation_component);
      });
    }
  }
};
</script>

<style>
#sidebar {
  @apply .hidden .fixed .z-50 .bg-white .border-r .border-grey .w-full;
  top: 4rem;
}

@screen lg {
  #sidebar {
    @apply .max-w-sidebar .fixed .pin-l .pt-0 .w-1/4 .block .overflow-y-scroll .h-screen;
  }
}

@screen xl {
  #sidebar {
    @apply .w-1/5;
  }
}

#nav {
  @apply .pt-6 .overflow-y-auto .text-base;
}

@screen lg {
  #nav {
    @apply .text-sm;
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
