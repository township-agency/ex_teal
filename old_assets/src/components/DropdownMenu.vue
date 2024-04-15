<template>
  <div
    :class="menuClasses"
    class="dropdown-menu absolute z-50 select-none"
  >
    <div
      :style="styles"
      class="z-40 overflow-x-hidden overflow-y-scroll bg-white border shadow"
    >
      <slot />
    </div>
  </div>
</template>

<script>
export default {
  props: {
    dark: {
      type: Boolean,
      default: false
    },
    direction: {
      type: String,
      default: 'ltr',
      validator: value => [ 'ltr', 'rtl' ].indexOf(value) != -1
    },
    width: {
      default: 120,
      type: [ Number, String ]
    },
    maxHeight: {
      default: 200,
      type: [ Number, String ]
    },
    override: {
      type: String,
      default: null
    }
  },
  computed: {
    menuClasses () {
      return [
        this.direction == 'ltr' ? 'dropdown-menu-left' : 'dropdown-menu-right',
        this.override ? this.override : null
      ];
    },
    arrowClasses () {
      return [
        this.direction == 'ltr' ? 'dropdown-arrow-left' : 'dropdown-arrow-right'
      ];
    },
    styles () {
      return {
        width: `${this.width}px`,
        'max-height': `${this.maxHeight}px`
      };
    }
  }
};
</script>
