<script>
const classes = {
  '1': 'text-gray-darkest font-normal text-xl',
  '2': 'text-gray-darkest font-normal text-lg',
  '3': 'text-gray-darkest font-bold text-bg'
};

export default {
  props: {
    level: {
      default: 1,
      type: Number
    }
  },

  render (h) {
    return h(
      'h' + this.level,
      { class: classes[this.level] },
      this.$slots.default
    );
  }
};
</script>
