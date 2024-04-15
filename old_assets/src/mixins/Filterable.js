import each from 'lodash/each';
import get from 'lodash/get';
import find from 'lodash/find';

export const Filterable = {
  data () {
    return {
      filters: [],
      currentFilters: []
    };
  },

  methods: {
    /**
     * Initialize the current filter values from the decoded query string.
     */
    initializeFilterValuesFromQueryString () {
      this.clearAllFilters();

      if (this.encodedFilters) {
        this.currentFilters = JSON.parse(atob(this.encodedFilters));

        this.syncFilterValues();
      }
    },

    /**
     * Reset all of the current filters.
     */
    clearAllFilters () {
      this.currentFilters = [];

      each(this.filters, filter => {
        filter.current_value = '';
      });
    },

    /**
     * Sync the current filter values with the decoded filter query string values.
     */
    syncFilterValues () {
      each(this.filters, filter => {
        filter.current_value = get(
          find(this.currentFilters, decoded => {
            return filter.key == decoded.key;
          }),
          'value',
          filter.current_value
        );
      });
    },

    /**
     * Handle a filter state change.
     */
    filterChanged () {
      this.updateQueryString({
        [this.pageParameter]: 1,
        [this.filterParameter]: btoa(JSON.stringify(this.currentFilters))
      });
    }
  },

  computed: {
    /**
     * Get the encoded filters from the query string.
     */
    encodedFilters () {
      return this.$route.query[this.filterParameter] || '';
    }
  }
};
