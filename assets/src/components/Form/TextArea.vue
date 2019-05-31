<template>
  <default-field :field="field">
    <template slot="field">
      <textarea
        v-model="value"
        :data-testid="field.attribute"
        :class="errorClasses"
        :placeholder="field.name"
        type="text"
        class="w-full form-control form-input form-input-bordered py-3 min-h-textarea"
      />
      <p
        v-if="hasError"
        class="my-2 text-danger"
      >
        {{ firstError }}
      </p>
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
  }
};
</script>
