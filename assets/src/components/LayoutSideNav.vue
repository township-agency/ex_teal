<template>
  <div>
    <h3 class="text-xl">
      <span>Dashboards</span>
    </h3>
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
    <div
      v-for="(resources, group) in groupedResources"
      :key="group"
    >
      <h3 class="text-xl my-2 text-xs text-70 font-normal px-4">
        <span>{{ group }}</span>
      </h3>
      <ul class="mb-6 text-lg">
        <li
          v-for="resource in resources"
          :key="resource.uri"
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
    </div>
    
    <div
      v-for="plugin in pluginsWithNavComponents"
      :key="plugin.uri"
    >
      <component :is="plugin.navigation_component" />
    </div>
  </div>
</template>

<script>
import filter from 'lodash/filter';
import identity from 'lodash/identity';
import groupBy from 'lodash/groupBy';

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

    groupedResources () {
      const grouped = groupBy(this.availableResources, resource => resource.group || 'Resources');
      const groups = this.config.nav_groups;
      return Object.entries(grouped)
        .sort((a, b) => {
          return groups.indexOf(a[0]) <= groups.indexOf(b[0]) ? -1 : 1;
        })
        .reduce((acc, pair) => {
          acc[pair[0]] = pair[1];
          return acc;
        }, {});
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
  },

  methods: {
    groupLabelFor (group) {
      return group !== 'null' ? group : 'Resources';
    }
  }
};
</script>