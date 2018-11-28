<template>
  <default-field :field="field">
    <template slot="field">
      <select
        :id="field.attribute"
        v-model="value"
        :class="errorClasses"
        class="w-full form-control form-select"
      >
        <option
          value=""
          selected
          disabled>
          Choose an Option
        </option>

        <option
          v-for="(label, key) in field.options"
          :key="key"
          :value="key"
          :selected="key == value"
        >
          {{ label }}
        </option>
      </select>

      <p
        v-if="hasError"
        class="my-2 text-danger">
        {{ firstError }}
      </p>
    </template>
  </default-field>
</template>

<script>
import { FormField, HandlesValidationErrors } from "@/mixins";

export default {
  mixins: [HandlesValidationErrors, FormField],

  methods: {
    /**
     * Provide a function that fills a passed FormData object with the
     * field's internal value attribute. Here we are forcing there to be a
     * value sent to the server instead of the default behavior of
     * `this.value || ''` to avoid loose-comparison issues if the keys
     * are truthy or falsey
     */
    fill(form) {
      return (form[this.field.attribute] = this.value);
    }
  }
};
</script>
