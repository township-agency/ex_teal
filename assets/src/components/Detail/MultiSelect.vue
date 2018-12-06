<template>
  <panel-item :field="field">
    <p slot="value" class="text-90">
      <span
        v-for="v in field.value"
        :key="v.value"
        class="inline-block mr-2 bg-50 px-2 py-1"
      >
        {{ v.label }}
      </span>
    </p>
  </panel-item>
</template>

<script>
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
  }
};
</script>
