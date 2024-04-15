<template>
  <default-field
    :field="field"
    :errors="errors"
  >
    <template slot="field">
      <textarea
        v-model="value"
        :data-testid="field.attribute"
        :class="errorClasses"
        :placeholder="field.name"
        type="text"
        class="w-full form-control form-input form-input-bordered py-3 min-h-textarea"
      />
    </template>
  </default-field>
</template>

<script>
import { FormField, HandlesValidationErrors } from '@/mixins';

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
