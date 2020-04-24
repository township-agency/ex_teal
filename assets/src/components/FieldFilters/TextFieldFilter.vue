<template>
  <div class="text-field-filter inline-flex">
    <input
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
<<<<<<< HEAD
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

=======
  
>>>>>>> 55a029f... Text, Number, and Boolean Filters
  methods: {
    setOperand (e) {
      this.$emit('change', { ...this.filter, operand: e.target.value, valid: true });
    }
  }
<<<<<<< HEAD
}
=======
};
>>>>>>> 55a029f... Text, Number, and Boolean Filters
</script>