<template>
  <resource-index
    :sortable="field.options.sortable"
    :sortable-by="field.options.sortable_by"
    :resource-name="uri"
    :load-cards="false"
  />
</template>

<script>
export default {
  props: {
    field: {
      type: Object,
      required: true
    }
  },

  computed: {
    uri() {
      return this.field.attribute;
    }
  }
};
</script>
