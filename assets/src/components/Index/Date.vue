<template>
  <p v-if="field.value" class="text-90">{{ formattedDate }}</p>
  <p v-else>&mdash;</p>
</template>

<script>
import format from "date-fns/format";
export default {
  props: {
    field: {
      type: Object,
      required: true
    }
  },

  computed: {
    formattedDate() {
      if (this.field.value) {
        if (this.field.options.format) {
          return format(this.field.value, this.field.options.format);
        }

        return this.field.value;
      }
    }
  }
};
</script>
