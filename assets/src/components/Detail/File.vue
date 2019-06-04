<template>
  <panel-item :field="field">
    <p
      v-if="field.value"
      slot="value"
      class="text-90"
    >
      <img
        :src="field.value"
        class="block mb-2"
      >
      <a
        :href="field.value"
        target="_blank"
        class="btn btn-default btn-primary btn-icon-inline"
      >
        <icon
          type="link"
          class="mr-2"
        /> <span>Link</span>
      </a>
    </p>
  </panel-item>
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
