<template>
  <panel-item :field="field">
    <p
      slot="value"
      class="text-gray-darkest"
    >
      <span
        v-for="v in field.value"
        :key="v.value"
        class="inline-block mr-2 bg-gray px-2 py-1"
      >
        {{ v.label }}
      </span>
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
