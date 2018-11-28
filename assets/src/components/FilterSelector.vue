<template>
  <div>
    <filter-select
      v-for="filter in filters"
      :key="filter.key">
      <h3
        slot="default"
        class="small-header">
        {{ filter.title }}
      </h3>

      <select
        slot="select"
        v-model="filter.current_value"
        class="block w-full form-control-sm form-select"
        @change="filterChanged(filter)"
      >
        <option
          value=""
          selected>&mdash;</option>

        <option
          v-for="option in filter.options"
          :value="option.value"
          :key="option.value">
          {{ option.name }}
        </option>
      </select>
    </filter-select>
  </div>
</template>

<script>
import reject from "lodash/reject";
export default {
  props: {
    filters: {
      type: Array,
      default() {
        return [];
      }
    },
    currentFilters: {
      type: Array,
      default() {
        return [];
      }
    }
  },

  mounted() {
    this.current = this.currentFilters;
  },

  methods: {
    filterChanged(filter) {
      this.current = reject(this.current, f => f.key == filter.key);

      if (filter.current_value !== "") {
        this.current.push({
          key: filter.key,
          value: filter.current_value
        });
      }

      this.$emit("update:currentFilters", this.current);
      this.$emit("changed");
    }
  }
};
</script>
