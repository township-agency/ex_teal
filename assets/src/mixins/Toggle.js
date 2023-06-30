export const Toggle =  {
  data: () => ({
    options: {}
  }),

  computed: {
    trueValue () {
      return this.options.true_value ? this.options.true_value : 'True';
    },
    falseValue () {
      return this.options.false_value ? this.options.false_value : 'False';
    },
    label () {
      return this.value ? this.trueValue : this.falseValue;
    }
  }
};