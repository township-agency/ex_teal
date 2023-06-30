<template>
  <ResourceIndex
    :resource-name="card.options.resource_uri"
    :include-cards="false"
  />
</template>
<script>
import ResourceIndex from '@/views/Index.vue';
export default {
  components: {
    ResourceIndex
  },
  props: {
    card: {
      type: Object,
      required: true,
    },
  },
};
</script>