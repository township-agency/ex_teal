<template>
  <button class="flex items-center text-gray-darker px-2 animate hover:bg-gray-dark">
    <icon
      type="filter"
      class="mr-2"
    />
    Filter
  </button>
</template>

<script>
export default {
  props: {
    active: {
      type: Boolean,
      default: false
    }
  }
};
</script>