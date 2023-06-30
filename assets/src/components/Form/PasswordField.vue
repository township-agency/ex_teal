<template>
  <default-field
    :field="field"
    :errors="errors"
  >
    <template slot="field">
      <input
        :id="field.attribute"
        v-model="value"
        :type="inputType"
        :pattern="inputPattern"
        :class="errorClasses"
        :placeholder="field.name"
        class="w-full form-control form-input form-input-bordered"
      >
    </template>
  </default-field>
</template>

<script>
import { FormField, HandlesValidationErrors } from '@/mixins';

export default {
  mixins: [ HandlesValidationErrors, FormField ],

  computed: {
    /**
     * Get the input type.
     */
    inputType () {
      return this.field.type || 'password';
    },

    /**
     * Get the pattern that should be used for the field
     */
    inputPattern () {
      return this.field.pattern;
    }
  }
};
</script>
