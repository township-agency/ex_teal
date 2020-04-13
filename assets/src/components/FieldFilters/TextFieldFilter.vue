<template>
  <div class="text-field-filter inline-flex">
    <dropdown class="field-filter-dropdown">
      <dropdown-trigger
        slot-scope="{ toggle }"
        :handle-click="toggle"
        :class="{'field-filter-trigger': true, 'field-filter-operator': true, 'no-operand': !hasOperand}"
      >
        {{ filter.operator }}
      </dropdown-trigger>
      <dropdown-menu slot="menu" width="150">
        <p
          v-for="o in operators"
          :key="o"
        >
          <a @click="selectOperator(o)">
            {{ o }}
          </a>
        </p>
      </dropdown-menu>
    </dropdown>
    <input
      v-if="hasOperand"
      type="text"
      :value="filter.operand"
      class="form-control field-filter-operand-input"
      @input="setOperand"
    >
  </div>
</template>
<script>
const operators = [ '=', '!=', '>', 'contains', 'does not contain', 'is empty', 'not empty' ];
const noOperand = [ 'is empty', 'not empty' ];
export default {
  props: {
    filter: {
      required: true,
      type: Object
    }
  },
  data () {
    return {
      operators: operators,
    }
  },

  computed: {
    hasOperand () {
      return !noOperand.includes(this.filter.operator);
    }
  },
  
  created () {
    if (!this.filter.operator || !this.operators.includes(this.filter.operator)) {
      this.$emit('change', { ...this.filter, operator: this.operators[0], operand: null } );
    }
  },

  methods: {
    selectOperator (o) {
      this.$emit('change', { ...this.filter, operator: o, operand: '' });
    },

    setOperand (e) {
      this.$emit('change', { ...this.filter, operand: e.target.value });
    }
  }
}
</script>