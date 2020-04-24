<template>
  <div class="number-field-filter inline-flex">
    <input
      type="number"
      pattern="\d*"
      :value="filter.operand"
      class="form-control field-filter-operand-input group-hover:rounded-none"
      @input="setOperand"
    >
  </div>
</template>
<script>
export default {
  props: {
    filter: {
      required: true,
      type: Object
    }
  },
  
  methods: {
    setOperand (e) {
      this.$emit('change', { ...this.filter, operand: e.target.value, valid: true });
    }
  }
};
</script>