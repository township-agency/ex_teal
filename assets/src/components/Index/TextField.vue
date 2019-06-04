<template>
  <div
    v-if="field.asHtml"
    v-html="field.value"
  />
  <span
    v-else
    class="whitespace-no-wrap "
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
