<template>
  <div class="belongs-to-field-filter inline-flex">
    <search-input
      v-if="isSearchable"
      :value="selectedResource"
      :data="availableResources"
      :is-searching="isSearching"
      track-by="id"
      search-by="display"
      class="block appearance-none w-64 bg-primary-10 text-sm field-filter-operand-input group-hover:rounded-none"
      @input="performSearch"
      @clear="clearSelection"
      @selected="selectResource"
    >
      <div
        v-if="selectedResource"
        slot="default"
        class="flex items-center"
      >
        <div
          v-if="selectedResource.thumbnail"
          class="mr-3"
        >
          <img
            :src="selectedResource.thumbnail"
            class="w-4 h-4 rounded block"
          >
        </div>
        <div class="flex">
          <p class="text-gray-darkest">
            {{ selectedResource.title }}
          </p>
        </div>
      </div>

      <div
        slot="option"
        slot-scope="{ option }"
        class="flex items-center"
      >
        <div
          v-if="option.thumbnail"
          class="mr-3"
        >
          <img
            :src="option.thumbnail"
            class="w-8 h-8 rounded block"
          >
        </div>
        <div>
          <p class="text-gray-darkest">
            {{ option.title }}
          </p>
          <p
            v-if="option.subtitle"
            class="text-xs mt-1 text-gray-darker"
          >
            {{ option.subtitle }}
          </p>
        </div>
      </div>
    </search-input>
    <select
      v-else
      class="block appearance-none text-primary-dark bg-primary-10 leading-tight form-control field-filter-operand-input group-hover:rounded-none"
      @change="selectResourceFromSelectControl"
    >
      <option
        value=""
        disabled="disabled"
        selected
      >
        Choose {{ fieldFilter.label }}
      </option>

      <option
        v-for="resource in availableResources"
        :key="resource.id"
        :value="resource.id"
        :selected="selectedResourceId == resource.id"
      >
        {{ resource.title }}
      </option>
    </select>
  </div>
</template>
<script>
import { PerformsSearches } from 'ex-teal-js';

export default {
  mixins: [ PerformsSearches ],
  props: {
    filter: {
      required: true,
      type: Object
    },
    fieldFilter: {
      required: true,
      type: Object
    },
    resourceName: {
      required: true,
      type: String
    }
  },

  data: () => ({
    availableResources: [],
    initializingWithExistingResource: false,
    selectedResource: null,
    selectedResourceId: null,
    search: '',
    isSearching: false
  }),

  computed: {
    /**
     * Determine if the related resources is searchable
     */
    isSearchable () {
      return this.fieldFilter.searchable;
    },

    /**
     * Get the query params for getting available resources
     */
    queryParams () {
      return {
        params: {
          current: this.selectedResourceId,
          search: this.search
        }
      };
    },
  },

  watch: {
    fieldFilter (oldFilter, newFilter) {
      if (oldFilter.field !== newFilter.field) {
        this.availableResources = [];
        this.selectedResource = null;
        this.selectedResourceId = null;
        this.search = '';
        this.initializeComponent();
      }
    }
  },

  /**
   * Mount the component.
   */
  mounted () {
    this.initializeComponent();
  },

  
  methods: {
    setOperand (e) {
      this.$emit('change', { ...this.filter, operand: e.target.value, valid: true });
    },

    initializeComponent () {
      if (this.filter.operand && !this.isSearchable) {
        this.selectedResourceId = this.filter.operand;
        this.initializingWithExistingResource = false;
        this.getAvailableResources().then(() => this.selectInitialResource());
      } else if (this.filter.operand && this.isSearchable) {
        this.selectedResourceId = this.filter.operand;
        this.getAvailableResources().then(() => this.selectInitialResource());
      } else {
        this.getAvailableResources();
      }
    },

    fetchAvailableResources (resourceName, attribute, params) {
      return ExTeal.request().get(
        `/api/${resourceName}/relatable/${attribute}`,
        params
      );
    },

    /**
     * Select a resource using the <select> control
     */
    selectResourceFromSelectControl (e) {
      this.selectedResourceId = e.target.value;
      this.$emit('change', { ...this.filter, operand: e.target.value, valid: true });
      this.selectInitialResource();
    },

    selectResource (resource) {
      this.$emit('change', { ...this.filter, operand: resource.id, valid: true });
      this.selectedResource = resource;
    },

    /**
     * Get the resources that may be related to this resource.
     */
    getAvailableResources () {
      return this.fetchAvailableResources(
        this.resourceName,
        this.fieldFilter.field,
        this.queryParams
      ).then(({ data: { data: resources } }) => {
        this.initializingWithExistingResource = false;
        this.availableResources = resources;
        this.isSearching = false;
      });
    },

    performSearch (search) {
      this.search = search;

      const trimmedSearch = search.trim();
      if (trimmedSearch == '') {
        return;
      }
      this.isSearching = true;
      this.debouncer(() => {
        this.getAvailableResources(trimmedSearch);
      }, 500);
    },

    /**
     * Select the initial selected resource
     */
    selectInitialResource () {
      this.selectedResource = this.availableResources.find(
        r => r.id == this.selectedResourceId
      );
    },
  }
};
</script>