<template>
  <label
    :for="labelFor"
    class="inline-block text-gray-darkest h-9 pt-2"
  >
    <slot />
  </label>
</template>

<script>
export default {
  props: {
    labelFor: {
      type: String,
      default: ''
    }
  }
};
</script>
