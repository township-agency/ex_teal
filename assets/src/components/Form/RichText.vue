<template>
  <default-field :field="field">
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
  mixins: [FormField, HandlesValidationErrors],

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
    editorId() {
      return `editor-${this.field.name}`;
    }
  }
};
</script>
