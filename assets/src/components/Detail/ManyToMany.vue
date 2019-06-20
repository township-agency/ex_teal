<template>
  <resource-index
    :sortable="field.options.sortable"
    :sortable-by="field.options.sortable_by"
    :resource-name="field.options.uri"
    :via-resource="resourceName"
    :via-resource-id="resourceId"
    :via-relationship="field.options.many_to_many_relationship"
    :relationship-type="'ManyToMany'"
    :load-cards="false"
  />
</template>


<script>
export default {
  props: {
    resourceName: {
      type: String,
      required: true
    },
    resourceId: {
      type: Number,
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
