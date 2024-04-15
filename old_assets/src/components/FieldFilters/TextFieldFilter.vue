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