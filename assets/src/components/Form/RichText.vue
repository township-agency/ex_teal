<template>
  <default-field
    :field="field"
    :errors="errors"
  >
    <template slot="field">
      <input
        :id="editorId"
        type="hidden"
        name="content"
      >
      <editor
        :value="field.value"
        :class="errorClasses"
        :input="editorId"
        :placeholder="field.name"
        @change="handleChange"
      />
    </template>
  </default-field>
</template>

<script>
import { FormField, HandlesValidationErrors } from 'ex-teal-js';

export default {
  mixins: [ FormField, HandlesValidationErrors ],

  props: {
    resourceName: {
      type: String,
      required: true
    },
    field: {
      type: Object,
      required: true
    }
  },

  computed: {
    editorId () {
      return `editor-${this.field.name}`;
    }
  }
};
</script>
