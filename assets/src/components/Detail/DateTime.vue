<template>
  <panel-item :field="field">
    <template slot="value">
      <p
        v-if="field.value"
        class="text-90"
      >
        {{ formattedDate }}
      </p>
      <p v-else>
        &mdash;
      </p>
    </template>
  </panel-item>
</template>

<script>
import InteractsWithDateTimes from '@/mixins/InteractsWithDateTimes';

export default {
  mixins: [ InteractsWithDateTimes ],
  props: {
    resourceName: {
      type: String,
      required: true
    },
    resourceId: {
      type: [ String, Number ],
      required: true
    },
    resource: {
      type: Object,
      required: true
    },
    field: {
      type: Object,
      required: true
    }
  }
};
</script>
