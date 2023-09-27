<template>
  <div
    class="flex border-b border-gray-light flex-col"
    :class="{ 'md:flex-row': !stacked }"
  >
    <slot />
  </div>
</template>

<script>
export default {
  props: {
    stacked: {
      type: Boolean,
      default: false,
    },
  },
};
</script>
