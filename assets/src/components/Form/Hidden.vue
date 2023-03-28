<template>
  <div
    class="hidden"
    :errors="errors"
  >
    <input
      :id="field.attribute"
      v-model="value"
      type="hidden"
    >
  </div>
</template>

<script>
import { FormField, HandlesValidationErrors } from 'ex-teal-js';

export default {
  mixins: [ FormField, HandlesValidationErrors ],
};
</script>
