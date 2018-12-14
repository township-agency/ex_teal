<template>
  <label
    ref="label"
    class="flex items-center select-none"
    @keydown.prevent.enter.space="$refs.label.click()"
  >
    <fake-checkbox :checked="checked" class="mr-2" />
    <input
      :disabled="disabled"
      :tabindex="disabled ? false : 0"
      :aria-checked="checked"
      type="checkbox"
      @change="$emit('change', $event)"
    />
    <slot />
  </label>
</template>

<script>
export default {
  props: {
    checked: {
      type: Boolean,
      default: false
    },
    disabled: {
      type: Boolean,
      default: false
    }
  }
};
</script>

<style scoped>
label {
  overflow: hidden;
}
input[type="checkbox"] {
  position: absolute;
  left: 0;
  opacity: 0;
  outline: none;
  z-index: -1;
}

input:focus,
input:active {
  outline: none;
}
</style>
