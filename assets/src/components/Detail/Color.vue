<template>
  <panel-item :field="field">
    <template slot="value">
      <div v-if="field.value" class="flex items-center">
        <div
          :style="{ backgroundColor: field.value }"
          class="h-6 w-6 mr-2 inline-block"
        ></div>
        <div>{{ field.value }}</div>
      </div>
      <div v-else>&mdash;</div>
    </template>
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
