<template>
  <p
    v-if="showHelpText"
    class="text-sm leading-normal text-80 italic pt-2"
  >
    <slot />
  </p>
</template>

<script>
export default {
  props: {
    showHelpText: { type: Boolean, default: true }
  }
};
</script>
