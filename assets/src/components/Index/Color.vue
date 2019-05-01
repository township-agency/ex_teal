<template>
  <div v-if="field.value" class="inline-flex items-center">
    <div
      :style="{ backgroundColor: field.value }"
      class="h-6 w-6 mr-2 inline-block"
    ></div>
    <div>{{ field.value }}</div>
  </div>
  <p v-else>&mdash;</p>
</template>

<script>
export default {
  props: {
    field: {
      type: Object,
      required: true
    }
  }
};
</script>
