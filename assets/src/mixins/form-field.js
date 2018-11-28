export default {
  props: {
    resourceName: {},
    field: {}
  },

  data: () => ({
    value: ""
  }),

  mounted() {
    this.setInitialValue();

    // Add a default fill method for the field
    this.field.fill = this.fill;

    // Register a global event for setting the field's value
    ExTeal.$on(this.field.attribute + "-value", value => {
      this.value = value;
    });
  },

  destroyed() {
    ExTeal.$off(this.field.attribute + "-value");
  },

  methods: {
    /*
     * Set the initial value for the field
     */
    setInitialValue() {
      this.value = this.field.value || "";
    },

    /**
     * Provide a function that fills a passed FormData object with the
     * field's internal value attribute
     */
    fill(form) {
      return (form[this.field.attribute] = this.value || "");
    },

    /**
     * Update the field's internal value
     */
    handleChange(value) {
      this.value = value;
    }
  }
};
