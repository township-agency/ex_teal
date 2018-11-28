<template>
  <span
    :dusk="'sort-' + uriKey"
    class="cursor-pointer inline-flex items-center"
    @click.prevent="handleClick"
  >
    <slot />

    <svg
      class="ml-2"
      xmlns="http://www.w3.org/2000/svg"
      width="8"
      height="14"
      viewBox="0 0 8 14"
    >
      <g
        id="sortable-icon"
        fill="none"
        fill-rule="evenodd"
      >
        <path
          id="Path-2-Copy-3"
          :class="descClass"
          d="M1.70710678 4.70710678c-.39052429.39052429-1.02368927.39052429-1.41421356 0-.3905243-.39052429-.3905243-1.02368927 0-1.41421356l3-3c.39052429-.3905243 1.02368927-.3905243 1.41421356 0l3 3c.39052429.39052429.39052429 1.02368927 0 1.41421356-.39052429.39052429-1.02368927.39052429-1.41421356 0L4 2.41421356 1.70710678 4.70710678z"
        />
        <path
          id="Combined-Shape-Copy-3"
          :class="ascClass"
          fill-rule="nonzero"
          d="M6.29289322 9.29289322c.39052429-.39052429 1.02368927-.39052429 1.41421356 0 .39052429.39052429.39052429 1.02368928 0 1.41421358l-3 3c-.39052429.3905243-1.02368927.3905243-1.41421356 0l-3-3c-.3905243-.3905243-.3905243-1.02368929 0-1.41421358.3905243-.39052429 1.02368927-.39052429 1.41421356 0L4 11.5857864l2.29289322-2.29289318z"
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
