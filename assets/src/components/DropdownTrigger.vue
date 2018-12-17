<template>
  <a
    class="dropdown-trigger h-8 flex items-center cursor-pointer select-none rounded"
    @click="handleClick"
  >
    <slot />

    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="7"
      height="5"
      viewBox="0 0 7 5"
      class="ml-2 stroke-current"
    >
      <path fill="none" fill-rule="evenodd" d="M6.53 1L3.764 3.765 1 1z" />
    </svg>
  </a>
</template>

<script>
export default {
  props: {
    handleClick: {
      type: Function,
      required: true
    }
  }
};
</script>
