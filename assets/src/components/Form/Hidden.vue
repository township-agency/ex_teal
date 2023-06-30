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
import { FormField, HandlesValidationErrors } from '@/mixins';

export default {
  mixins: [ FormField, HandlesValidationErrors ],
};
</script>
