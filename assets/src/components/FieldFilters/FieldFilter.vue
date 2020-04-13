<template>
  <div class="group relative inline-flex items-center mt-2">
    <dropdown class="field-filter-dropdown">
      <dropdown-trigger
        slot-scope="{ toggle }"
        :handle-click="toggle"
        class="field-filter-trigger field-drop"
      >
        {{ selectedFieldFilterType }}
      </dropdown-trigger>
      <dropdown-menu
        slot="menu"
        width="150"
      >
        <p
          v-for="f in filters"
          :key="f.field"
        >
          <a 
            @click="selectFilter(f)"
          >
            {{ f.field }}
          </a>
        </p>
      </dropdown-menu>
    </dropdown>
    <component
      :is="selectedFieldFilter.as + '-field-filter'"
      v-if="selectedFieldFilter" 
      :filter="filter"
      @change="updateFilter"
    />
    <button
      v-if="canDelete"
      :class="{
        'hidden group-hover:block rounded border border-danger text-danger text-xs h-8 w-8 border-infotransition bg-grey-lightest': true,
        'field-filter-delete-with-and': notLastFilter,
        'field-filter-delete': !notLastFilter
      }"
      @click="deleteFilter"
    >
      <icon type="delete" />
    </button>
    <span
      v-if="notLastFilter"
      class="font-bold w-16 text-center text-xs text-grey font-normal"
    >
      AND
    </span>
  </div>
</template>

<script>
export default {
  props: {
    filter: {
      type: Object,
      required: true
    },
    filters: {
      type: Array,
      required: true
    },
    index: {
      type: Number,
      required: true
    },
    totalFilters: {
      type: Number,
      required: true
    }
  },

  computed: {
    selectedFieldFilterType () {
      console.log(this.filter);
      return this.filter.field;
    },

    selectedFieldFilter () {
      return this.filters.find((f) => f.field == this.filter.field);
    },

    notLastFilter () {
      return this.index !== this.totalFilters - 1;
    },

    canDelete () {
      return this.totalFilters > 1;
    }
  },

  methods: {
    selectFilter (f) {
      this.$emit('fieldFilterUpdated', { ...this.filter, field: f.field }, this.index);
    },
    updateFilter (filter) {
      this.$emit('fieldFilterUpdated', filter, this.index);
    },
    deleteFilter () {
      this.$emit('delete', this.index);
    }
  }
}
</script>