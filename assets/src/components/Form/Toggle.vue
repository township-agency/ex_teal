<template>
  <default-field
    :field="field"
    :errors="errors"
  >
    <template slot="field">
      <div class="mb-2">
        <div
          class="form-switch inline-block align-middle"
          @click="toggle"
        >
          <input
            :id="field.attribute"
            :name="field.name"
            :checked="checked"
            type="checkbox"
            class="form-switch-checkbox"
          >
          <label
            class="form-switch-label"
            for="field.attribute"
          />
        </div>
        <label
          class="text-xs text-gray-dark"
          for="field.attribute"
        >{{
          label
        }}</label>
      </div>
    </template>
  </default-field>
</template>

<script>
import { FormField, HandlesValidationErrors, Toggle } from 'ex-teal-js';

export default {
  mixins: [ HandlesValidationErrors, FormField, Toggle ],

  data: () => ({
    value: false,
    options: {}
  }),

  computed: {
    checked () {
      return Boolean(this.value);
    }
  },

  mounted () {
    this.value = this.field.value || false;
    this.options = this.field.options || {};

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
