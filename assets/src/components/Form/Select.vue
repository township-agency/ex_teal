<template>
  <default-field :field="field">
    <template slot="field">
      <search-input
        v-if="isSearchable"
        :value="selectedOption"
        :data="filteredOptions"
        track-by="value"
        class="w-full"
        @input="performSearch"
        @selected="selectOption"
      >
        <div
          v-if="selectedOption"
          slot="default"
          class="flex items-center"
        >
          {{ selectedOption.key }}
        </div>
        <div
          slot="option"
          slot-scope="{ option, selected }"
          class="flex items-center text-sm font-semibold leading-5 text-gray-darkest"
          :class="{ 'text-gray': selected }"
        >
          {{ option.key }}
        </div>
      </search-input>
      <select-control
        v-else
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

  data: () => ({
    selectedOption: '',
    search: ''
  }),

  computed: {
    placeholder () {
      return this.field.options.placeholder || 'Choose an option';
    },

    isSearchable () {
      return this.field.options.searchable;
    },

    filteredOptions () {
      return this.field.options.field_options.filter(option => {
        return (
          option.key.toLowerCase().indexOf(this.search.toLowerCase()) > -1
        );
      });
    }
  },

  created () {
    if (this.field.value && this.isSearchable) {
      this.selectedOption = this.field.options.field_options.find(
        v => v.value == this.field.value
      );
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

    performSearch (event) {
      this.search = event;
    },

    selectOption (option) {
      this.selectedOption = option;
      this.value = option.value;
    }
  }
};
</script>