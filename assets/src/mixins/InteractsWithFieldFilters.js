import _ from 'lodash';

const InteractsWithFieldFilters = {
  methods: {
    /**
     * Initialize the current field filter values from the decoded query string.
     */
    initializeFieldFilterValuesFromQueryString () {
      this.clearAllFieldFilters();
      if (this.encodedFieldFilters) {
        this.currentFieldFilters = JSON.parse(atob(this.encodedFieldFilters));
      } else if (this.resourceInformation && this.resourceInformation.default_filters && this.initialLoading){
        this.currentFieldFilters = this.resourceInformation.default_filters;
        this.updateQueryString({
          [this.pageParameter]: 1,
          [this.fieldFilterParameter]: btoa(JSON.stringify(this.currentFieldFilters))
        });
      }
    },

    /**
     * Reset all of the current field filters.
     */
    clearAllFieldFilters () {
      this.currentFieldFilters = [];
    },

    /**
     * Handle a field filter state change.
     */
    fieldFilterChanged () {
      if (this.currentFieldFilters.length === 0) {
        const query = Object.assign({}, this.$route.query);
        query[this.pageParameter] = 1;
        delete query[this.fieldFilterParameter];
        this.$router.replace({ query });
        this.showFilters = false;
      } else {
        this.updateQueryString({
          [this.pageParameter]: 1,
          [this.fieldFilterParameter]: btoa(JSON.stringify(this.currentFieldFilters))
        });
      }
    },

    updateFieldFilter (filter, index) {
      this.currentFieldFilters = this.currentFieldFilters.map((item, i) => i === index ? filter : item);
      this.fieldFilterChanged();
    },

    addNewFilter () {
      const lastFilter =  this.currentFieldFilters[this.currentFieldFilters.length - 1];
      if (lastFilter) {
        this.currentFieldFilters.push(lastFilter);
      } else if (this.fieldFilters.length > 0) {
        this.currentFieldFilters = [ { field: this.fieldFilters[0].field, operator: this.fieldFilters[0].operators[0].op, operand: null } ];
      }
      this.fieldFilterChanged();
    },

    deleteFieldFilter (index) {
      if (this.currentFieldFilters.length === 1) {
        this.currentFieldFilters = [];
      } else {
        this.$delete(this.currentFieldFilters, index);
      }
      this.fieldFilterChanged();
    }
  },

  computed: {
    /**
     * Get the encoded filters from the query string.
     */
    encodedFieldFilters () {
      return this.$route.query[this.fieldFilterParameter] || '';
    }
  }
};

export default InteractsWithFieldFilters;