<template>
  <svg
    version="1.1"
    xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    x="0px"
    y="0px"
    viewBox="0 0 20 20"
    class="h-5 w-5 fill-current text-primary checkbox"
  >
    <path
      v-if="checked"
      d="M0,0v20h20V0H0z M9,13.4L5.5,9.9l1.4-1.4L9,10.6l4.1-4.1l1.4,1.4L9,13.4z"
    />
  </svg>
</template>

<script>
export default {
  props: {
    checked: {
      type: Boolean,
      default: false
    }
  }
};
</script>
