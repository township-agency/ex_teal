<template>
  <div
    class="modal select-none fixed inset-0 flex justify-center items-center z-50"
  >
    <div class="relative z-20 bg-white shadow-lg overflow-hidden">
      <slot />
    </div>
    <div
      class="absolute inset-0 bg-gray-darker z-0 opacity-25"
      @click="close"
    />
  </div>
</template>

<script>
import { mixin as clickaway } from 'vue-clickaway';

export default {
  mixins: [ clickaway ],

  created () {
    document.addEventListener('keydown', this.handleEscape);
  },

  destroyed () {
    document.removeEventListener('keydown', this.handleEscape);
  },

  methods: {
    handleEscape (e) {
      e.stopPropagation();

      if (e.keyCode == 27) {
        this.close();
      }
    },

    close () {
      this.$emit('modal-close');
    }
  }
};
</script>
