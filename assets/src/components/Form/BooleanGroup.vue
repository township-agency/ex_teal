<template>
  <default-field
    :field="field"
    :errors="errors"
  >
    <template slot="field">
      <checkbox-with-label
        v-for="option in value"
        :key="option.name"
        class="mt-2"
        :name="option.name"
        :checked="option.checked"
        @change="toggle($event, option)"
      >
        {{ option.label }}
      </checkbox-with-label>
    </template>
  </default-field>
</template>

<script>
import { Errors, FormField, HandlesValidationErrors } from 'ex-teal-js';
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
        .map(o => [ o.name, o.checked ])
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
      this.value = Object.keys(options).map(name => { 
        return {
          name: name,
          label: options[name],
          checked: this.field.value[name] || false
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
      const firstOption = this.value.find(o => o.name == option.name);

      if (!firstOption) {
        this.value[option.name] = event.target.checked;
      } else {
        firstOption.checked = event.target.checked;
      }
    },
  },
};
</script>
