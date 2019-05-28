<template>
  <default-field :field="field">
    <template slot="field">
      <select
        :id="field.attribute"
        v-model="value"
        :class="errorClasses"
        class="w-full form-control form-select"
      >
        <option value="" selected disabled> Choose an Option </option>

        <option
          v-for="(label, key) in field.options"
          :key="key"
          :value="key"
          :selected="key == value"
        >
          {{ label }}
        </option>
      </select>

      <p v-if="hasError" class="my-2 text-danger">{{ firstError }}</p>
    </template>
  </default-field>
</template>

<script>
import { FormField, HandlesValidationErrors } from "ex-teal-js";

export default {
  mixins: [HandlesValidationErrors, FormField],

  methods: {
    fill(formData) {
      formData.append(this.field.attribute, this.value);
    }
  }
};
</script>
