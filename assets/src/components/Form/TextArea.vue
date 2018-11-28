<template>
  <default-field :field="field">
    <template slot="field">
      <textarea
        :data-testid="field.attribute"
        v-model="value"
        :class="errorClasses"
        :placeholder="field.name"
        type="text"
        class="w-full form-control form-input form-input-bordered py-3 min-h-textarea"
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
  }
};
</script>
