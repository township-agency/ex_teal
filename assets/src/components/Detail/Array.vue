<template>
  <panel-item :field="field">
    <p
      slot="value"
      class="text-gray-darkest"
    >
      <span
        v-for="(item, index) in field.value"
        :key="index"
        class="block pb-4"
      >
        {{ item }}
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
  },

  computed: {
    label () {
      return this.field.value == true ? 'Yes' : 'No';
    }
  }
};
</script>
