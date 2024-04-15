<template>
  <span>
    <span
      v-if="field.value"
      :title="title"
    >{{ field.value.length }} Items</span>
    <span v-else>&mdash;</span>
  </span>
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
  },
  computed: {
    title () {
      if (this.field.value.length) {
        return this.field.value.join(', ');
      }
      return 'Empty Array';
    }
  }
};
</script>
