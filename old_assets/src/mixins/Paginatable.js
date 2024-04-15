export const Paginatable = {
  methods: {
    selectPreviousPage () {
      this.updateQueryString({ [this.pageParameter]: this.currentPage - 1 });
    },

    selectNextPage () {
      this.updateQueryString({ [this.pageParameter]: this.currentPage + 1 });
    }
  },

  computed: {
    currentPage () {
      return parseInt(this.$route.query[this.pageParameter] || 1);
    }
  }
};