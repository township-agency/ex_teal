<template>
  <div class="flex items-center">
    <div
      :disabled="disabled"
      class="select-none"
      @keydown.prevent.space.enter="toggle"
      @click="toggle"
    >
      <input
        :checked="checked"
        :disabled="disabled"
        class="hidden"
        type="checkbox"
      >

      <div class="h-5 w-5">
        <fake-checkbox :checked="checked" />
      </div>
    </div>

    <slot />
  </div>
</template>

<script>
export default {
  props: {
    disabled: {
      type: Boolean,
      default: false
    },
    checked: {
      type: Boolean,
      default: false
    }
  },

  methods: {
    toggle () {
      this.$emit('input', !this.checked);
    }
  }
};
</script>
