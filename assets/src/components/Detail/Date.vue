<template>
  <panel-item :field="field">
    <template slot="value">
      <p v-if="field.value" class="text-90">{{ formattedDate }}</p>
      <p v-else>&mdash;</p>
    </template>
  </panel-item>
</template>

<script>
import format from "date-fns/format";

export default {
  props: {
    resourceName: {
      type: String,
      required: true
    },
    resourceId: {
      type: [String, Number],
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
  },
  computed: {
    formattedDate() {
      if (this.field.options.format) {
        return format(this.field.value, this.field.options.format);
      }

      return this.field.value;
    }
  }
};
</script>
