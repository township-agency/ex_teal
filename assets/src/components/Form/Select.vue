<template>
  <default-field :field="field">
    <template slot="field">
      <select-control
        :selected="value"
        class="w-full form-control form-select"
        :options="field.options.field_options"
        label="key"
        value-key="value"
        @change="handleChange"
      />    
    </template>
  </default-field>
</template>

<script>
import { FormField, HandlesValidationErrors } from 'ex-teal-js';

export default {
  mixins: [ HandlesValidationErrors, FormField ],

  computed: {
    placeholder () {
      return this.field.options.placeholder || 'Choose an option';
    }
  },

  methods: {
    fill (formData) {
      formData.append(this.field.attribute, this.value);
    },

    /**
     * Handle the selection change event.
     */
    handleChange (e) {
      this.value = e.target.value;
    },
  }
};
</script>