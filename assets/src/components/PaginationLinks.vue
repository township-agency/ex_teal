<template>
  <div class="border-t  bg-grey-lightest">
    <nav
      v-if="resources.length > 0"
      class="flex"
    >
      <!-- Previous Link -->
      <button
        :disabled="!hasPreviousPages"
        :class="{
          'text-primary dim': hasPreviousPages,
          'text-80 opacity-50': !hasPreviousPages
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
          'text-80 opacity-50': !hasMorePages
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
    }
  },

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
    }
  }
};
</script>
