<template>
  <div class="border-t bg-gray-lightest flex justify-end">
    <nav
      v-if="resources.length > 0"
    >
      <span class="text-gray-darker mr-2">Per Page:</span>
      <select-control
        label="value"
        :selected="perPage"        
        class="form-control form-select form-sm"
        :options="options"
        @change="selectPerPage"
      />
      <!-- Previous Link -->
      <button
        :disabled="!hasPreviousPages"
        :class="{
          'text-primary dim': hasPreviousPages,
          'text-gray-darker opacity-50': !hasPreviousPages
        }"
        class="btn btn-link py-3 px-4"
        rel="prev"
        @click.prevent="selectPreviousPage()"
      >
        Previous
      </button>

      <!-- Next Link -->
      <button
        :disabled="!hasMorePages"
        :class="{
          'text-primary dim': hasMorePages,
          'text-gray-darker opacity-50': !hasMorePages
        }"
        class="ml-auto btn btn-link py-3 px-4"
        rel="next"
        @click.prevent="selectNextPage()"
      >
        Next
      </button>
    </nav>
  </div>
</template>

<script>
export default {
  props: {
    resourceName: {
      type: String,
      required: true
    },
    resources: {
      type: Array,
      default () {
        return [];
      }
    },
    resourceResponse: {
      type: Object,
      default () {
        return {};
      }
    },
    currentPage: {
      type: Number,
      default: 1
    },
    perPage: {
      type: Number,
      default: 25
    }
  },

  data: () => ({
    options: [
      { value: 10 },
      { value: 25 },
      { value: 50 },
      { value: 100 }
    ]
  }),

  computed: {
    /**
     * Determine if prior pages are available.
     */
    hasPreviousPages: function () {
      return Boolean(this.resourceResponse && this.currentPage > 1);
    },

    /**
     * Determine if more pages are available.
     */
    hasMorePages: function () {
      return Boolean(
        this.resourceResponse &&
          this.resourceResponse.meta.total > this.currentPage
      );
    },
    currentAsString () {
      return `${this.perPage}`;
    }
  },

  methods: {
    /**
     * Select the previous page.
     */
    selectPreviousPage () {
      this.$emit('previous');
    },

    /**
     * Select the next page.
     */
    selectNextPage () {
      this.$emit('next');
    },

    selectPerPage (e) {
      this.$emit('perPageChanged', parseInt(e.target.value));
    }
  }
};
</script>
