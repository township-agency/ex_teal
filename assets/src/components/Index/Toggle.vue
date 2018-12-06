<template>
  <div class="text-center">
    <span
      :class="{ 'bg-success': field.value, 'bg-danger': !field.value }"
      class="inline-block rounded-full w-2 h-2"
    />
  </div>
</template>

<script>
export default {
  props: {
    resourceName: {
      type: String,
      default: ""
    },
    field: {
      type: Object,
      default() {
        return {};
      }
    }
  }
};
</script>
