<template>
  <default-field
    :field="field"
    :errors="errors"
  >
    <template slot="field">
      <checkbox
        :id="field.attribute"
        :name="field.name"
        :checked="checked"
        class="py-2"
        @input="toggle"
      />
    </template>
  </default-field>
</template>

<script>
import { FormField, HandlesValidationErrors } from '@/mixins';

export default {
  mixins: [ HandlesValidationErrors, FormField ],

  data: () => ({
    value: false
  }),

  computed: {
    checked () {
      return Boolean(this.value);
    }
  },

  mounted () {
    this.value = this.field.value || false;

    this.field.fill = formData => {
      formData.append(this.field.attribute, this.value);
    };
  },

  methods: {
    toggle () {
      this.value = !this.value;
    }
  }
};
</script>
