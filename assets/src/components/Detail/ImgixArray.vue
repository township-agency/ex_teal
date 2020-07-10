<template>
  <panel-item :field="field">
    <p
      slot="value"
      class="text-90"
    >
      <image-detail 
        v-for="(item, index) in field.value"
        :key="index"
        :field="field" 
        :value="item" 
        class="block pb-4"
      />
    </p>
  </panel-item>
</template>

<script>
import ImageDetail from '../Shared/ImageDetail';

export default {

  components: {ImageDetail},

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
  },

  computed: {
    label () {
      return this.field.value == true ? 'Yes' : 'No';
    }
  }
};
</script>
