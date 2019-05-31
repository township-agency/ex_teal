<template>
  <default-field :field="field">
    <template slot="field">
      <input
        :id="field.attribute"
        v-model="value"
        :type="inputType"
        :min="inputMin"
        :max="inputMax"
        :step="inputStep"
        :class="errorClasses"
        :placeholder="field.name"
        class="w-full form-control form-input form-input-bordered"
      >

      <p
        v-if="hasError"
        class="my-2 text-danger"
      >
        {{ firstError }}
      </p>
    </template>
  </default-field>
</template>

<script>
import { FormField, HandlesValidationErrors } from 'ex-teal-js';

export default {
  mixins: [ HandlesValidationErrors, FormField ],

  computed: {
    /**
     * Get the input type.
     */
    inputType () {
      return this.field.type || 'number';
    },

    /**
     * Get the input step amount.
     */
    inputStep () {
      return this.field.options['step'];
    },

    /**
     * Get the input minimum amount.
     */
    inputMin () {
      return this.field.options['min'];
    },

    /**
     * Get the input maximum amount.
     */
    inputMax () {
      return this.field.options['max'];
    }
  }
};
</script>
