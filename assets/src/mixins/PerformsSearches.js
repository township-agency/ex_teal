import debounce from 'lodash/debounce';

export const PerformsSearches = {
  data: () => ({
    search: '',
    selectedResource: '',
    availableResources: []
  }),

  methods: {
    selectResource (resource) {
      this.selectedResource = resource;
    },

    handleSearchCleared () {
      this.availableResources = [];
    },

    clearSelection () {
      this.selectedResource = '';
      this.availableResources = [];
    },

    performSearch (search) {
      this.search = search;

      const trimmedSearch = search.trim();
      if (trimmedSearch == '') {
        this.clearSelection();
        return;
      }

      this.debouncer(() => {
        this.selectedResource = '';
        this.getAvailableResources(trimmedSearch);
      }, 500);
    },

    debouncer: debounce(callback => callback(), 500)
  }
};