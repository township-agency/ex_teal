export default {
  props: {
    resourceName: {
      type: String,
      required: true
    },
    resourceId: {
      type: [String, Number],
      required: true
    },
    resource: {
      type: Object,
      required: true
    },
    panel: {
      type: Object,
      required: true
    }
  },

  methods: {
    /**
     * Handle the actionExecuted event and pass it up the chain.
     */
    actionExecuted() {
      this.$emit("actionExecuted");
    }
  }
};
