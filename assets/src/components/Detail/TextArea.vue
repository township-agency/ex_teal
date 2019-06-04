<template>
  <panel-item :field="field">
    <template slot="value">
      <Excerpt :content="field.value" />
    </template>
  </panel-item>
</template>

<script>
import Excerpt from '../Excerpt';

export default {
  components: { Excerpt },
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
