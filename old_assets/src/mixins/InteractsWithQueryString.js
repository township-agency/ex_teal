import defaults from 'lodash/defaults';

export const InteractsWithQueryString = {
  methods: {
    updateQueryString (value) {
      this.$router.push({ query: defaults(value, this.$route.query) });
    }
  }
};
