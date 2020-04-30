<template>
  <div class="group relative inline-flex items-center mt-2">
    <dropdown class="field-filter-dropdown">
      <dropdown-trigger
        slot-scope="{ toggle }"
        :handle-click="toggle"
        class="field-filter-trigger field-drop"
      >
        {{ selectedFieldFilterLabel }}
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
            {{ f.label }}
          </a>
        </p>
      </dropdown-menu>
    </dropdown>
    <div
      v-if="hasOperators"
      class="inline-flex"
    >
      <dropdown
        v-if="selectedFieldFilter"
        class="field-filter-dropdown"
      >
        <dropdown-trigger
          slot-scope="{ toggle }"
          :handle-click="toggle"
          :class="{'field-filter-trigger': true, 'field-filter-operator': true, 'no-operand group-hover:rounded-none': !hasOperand}"
        >
          {{ filter.operator }}
        </dropdown-trigger>
        <dropdown-menu
          slot="menu"
          width="150"
        >
          <p
            v-for="o in selectedFieldFilter.operators"
            :key="o.op"
          >
            <a @click="selectOperator(o)">
              {{ o.op }}
            </a>
          </p>
        </dropdown-menu>
      </dropdown>
    </div>
    <component
      :is="selectedFieldFilter.as + '-field-filter'"
      v-if="hasOperand" 
      :filter="filter"
      :field-filter="selectedFieldFilter"
      :resource-name="resourceName"
      @change="updateFilter"
    />
    <button
      :class="{
        'hidden group-hover:block rounded-r border border-danger text-danger text-xs h-8 w-8 bg-grey-lightest': true
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
    },
    resourceName: {
      type: String,
      required: true
    }
  },

  computed: {
    selectedFieldFilterLabel () {
      return this.selectedFieldFilter ? this.selectedFieldFilter.label : null;
    },

    selectedFieldFilterType () {
      return this.filter.field;
    },

    selectedFieldFilter () {
      return this.filters.find((f) => f.field == this.filter.field);
    },

    notLastFilter () {
      return this.index !== this.totalFilters - 1;
    },

    selectedOperator () {
      return this.selectedFieldFilter ? this.selectedFieldFilter.operators.find(o => o.op == this.filter.operator) : false;
    },

    hasOperand () {
      if (!this.selectedOperator) {
        return false;
      }
      return this.selectedOperator.no_operand !== null && !this.selectedOperator.no_operand;
    },

    hasOperators () {
      if (!this.selectedFieldFilter) {
        return false;
      }
      return this.selectedFieldFilter.operators !== [];
    }
  },

  methods: {
    selectFilter (f) {
      this.$emit('fieldFilterUpdated', { ...this.filter, field: f.field, operator: f.operators[0].op, operand: null }, this.index);
    },

    updateFilter (filter) {
      this.$emit('fieldFilterUpdated', filter, this.index);
    },

    deleteFilter () {
      this.$emit('delete', this.index);
    },

    selectOperator (o) {
      if (o.no_operand || this.selectedFieldFilter.operators.find(op => op.op == o.op) === null) {
        this.$emit('fieldFilterUpdated', { ...this.filter, operator: o.op, operand: null, valid: true }, this.index);
        return;
      }
      this.$emit('fieldFilterUpdated', { ...this.filter, operator: o.op }, this.index);
    }
  }
};
</script>