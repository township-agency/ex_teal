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
      }
      this.currentFieldFilters.push({ field: null, operator: null, operand: null });
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
      this.updateQueryString({
        [this.pageParameter]: 1,
        [this.fieldFilterParameter]: btoa(JSON.stringify(this.currentFieldFilters))
      });
    },

    updateFieldFilter (filter, index) {
      this.currentFieldFilters = this.currentFieldFilters.map((item, i) => i === index ? filter : item);
    },

    addNewFilter () {
      const lastFilter =  this.currentFieldFilters[this.currentFieldFilters.length - 1];
      if (lastFilter) {
        this.currentFieldFilters.push(lastFilter);         
      } else if (this.fieldFilters.length > 0) {
        this.currentFieldFilters = [ { field: this.fieldFilters[0].field, operator: null, operand: null } ];
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