<template>
  <p
    v-if="field.value"
    class="text-gray-darkest"
  >
    {{ formattedDate }}
  </p>
  <p v-else>
    &mdash;
  </p>
</template>

<script>
import { InteractsWithDateTimes } from '@/mixins';

export default {
  mixins: [ InteractsWithDateTimes ],

  props: {
    field: {
      type: Object,
      required: true
    }
  }
};
</script>
