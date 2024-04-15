<template>
  <div class="flex">
    <img
      v-if="field.value"
      :src="field.value"
      style="object-fit: cover;"
      class="w-8 h-8"
    >
    <span v-else>&mdash;</span>
  </div>
</template>

<script>
export default {
  props: {
    resourceName: {
      type: String,
      default: ''
    },
    field: {
      type: Object,
      default () {
        return {};
      }
    }
  }
};
</script>
