<template>
  <panel-item :field="field">
    <p
      slot="value"
      class="text-gray-darkest"
    >
      <span
        :class="{ 'bg-success': field.value, 'bg-danger': !field.value }"
        class="inline-block rounded-full w-2 h-2 mr-1"
      />
      <span>{{ label }}</span>
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
  },

  computed: {
    label () {
      return this.field.value == true ? 'Yes' : 'No';
    }
  }
};
</script>
