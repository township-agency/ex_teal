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
      this.currentFieldFilters.push(lastFilter); 
    },

    deleteFieldFilter (index) {
      this.$delete(this.currentFieldFilters, index);
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