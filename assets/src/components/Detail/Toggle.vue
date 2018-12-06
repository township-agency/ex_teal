<template>
  <panel-item :field="field">
    <p slot="value" class="text-90">
      <span
        :class="{ 'bg-success': field.value, 'bg-danger': !field.value }"
        class="inline-block rounded-full w-2 h-2 mr-1"
      />
      <span>{{ label }}</span>
    </p>
  </panel-item>
</template>

<script>
import { Toggle } from "@/mixins";

export default {
  mixins: [Toggle],

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

  mounted() {
    this.value = this.field.value || false;
    this.options = this.field.options || {};
  }
};
</script>
