<template>
  <span
    class="cursor-pointer inline-flex items-center"
    @click.prevent="handleClick"
  >
    <slot />

    <svg
      class="ml-2"
      xmlns="http://www.w3.org/2000/svg"
      width="8"
      height="9"
      viewBox="0 0 8 9"
    >
      <g id="sortable-icon" fill="none" fill-rule="evenodd">
        <path :class="descClass" d="M4,0L0,4H8L4,0z M4,1.4L5.6,3H2.4L4,1.4z" />
        <path
          :class="ascClass"
          fill-rule="nonzero"
          d="M4,9l4-4H0L4,9z M4,7.6L2.4,6h3.1L4,7.6z"
        />
      </g>
    </svg>
  </span>
</template>

<script>
export default {
  props: {
    resourceName: {
      type: String,
      default: ""
    },
    uriKey: {
      type: String,
      default: ""
    }
  },

  computed: {
    /**
     * The CSS class to apply to the ascending arrow icon
     */
    ascClass() {
      if (this.isSorted && this.direction == "desc") {
        return "fill-80";
      }

      return "fill-60";
    },

    /**
     * The CSS class to apply to the descending arrow icon
     */
    descClass() {
      if (this.isSorted && this.direction == "asc") {
        return "fill-80";
      }

      return "fill-60";
    },

    /**
     * Determine whether this column is being sorted
     */
    isSorted() {
      return this.sortColumn == this.uriKey;
    },

    /**
     * The current order query parameter for this resource
     */
    sortKey() {
      return `${this.resourceName}_order`;
    },

    /**
     * The current order query parameter value
     */
    sortColumn() {
      return this.$route.query[this.sortKey];
    },

    /**
     * The current direction query parameter for this resource
     */
    directionKey() {
      return `${this.resourceName}_direction`;
    },

    /**
     * The current direction query parameter value
     */
    direction() {
      return this.$route.query[this.directionKey];
    }
  },

  methods: {
    handleClick() {
      this.$emit("sort", {
        key: this.uriKey,
        direction: this.direction
      });
    }
  }
};
</script>
