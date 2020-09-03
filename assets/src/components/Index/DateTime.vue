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
import InteractsWithDateTimes from '@/mixins/InteractsWithDateTimes';

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
