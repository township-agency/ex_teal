<template>
  <resource-index
    :resource-name="field.options.uri"
    :via-resource="resourceName"
    :via-resource-id="resourceId"
    :via-relationship="field.options.has_one_relationship"
    :relationship-type="'hasOne'"
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
      type: [ String, Number ],
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
