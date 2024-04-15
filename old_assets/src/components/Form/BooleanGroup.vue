<template>
  <default-field
    :field="field"
    :errors="errors"
  >
    <template slot="field">
      <checkbox-with-label
        v-for="option in value"
        :key="option.value"
        class="mt-2"
        :name="option.key"
        :checked="option.checked"
        @change="toggle($event, option)"
      >
        {{ option.value }}
      </checkbox-with-label>
    </template>
  </default-field>
</template>

<script>
import { FormField, HandlesValidationErrors } from '@/mixins';

import _ from 'lodash';
export default {
  mixins: [ HandlesValidationErrors, FormField ],

  data: () => ({
    value: [],
  }),

  computed: {
    /**
     * Return the final filtered json object
     */
    finalPayload () {
      return _(this.value)
        .map((o) => [ o.key, o.checked ])
        .fromPairs()
        .value();
    },
  },

  methods: {
    /*
     * Set the initial value for the field
     */
    setInitialValue () {
      this.field.value = this.field.value || {};
      const options = this.field.options.group_options || {};
      this.value = options.map((option) => {
        return {
          key: option.key,
          value: option.value,
          checked: this.field.value[option.key] || false,
        };
      });
    },

    /**
     * Provide a function that fills a passed FormData object with the
     * field's internal value attribute.
     */
    fill (formData) {
      formData.append(this.field.attribute, JSON.stringify(this.finalPayload));
    },

    /**
     * Toggle the option's value.
     */
    toggle (event, option) {
      const firstOption = this.value.find((o) => o.value == option.value);

      if (!firstOption) {
        this.value[option.value] = event.target.checked;
      } else {
        firstOption.checked = event.target.checked;
      }
    },
  },
};
</script>
