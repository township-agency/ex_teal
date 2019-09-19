<template>
  <div
    v-if="field.as_html"
    v-html="field.value"
  />
  <span
    v-else
    class="block truncate max-w-xs"
  >{{ field.value }}</span>
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
