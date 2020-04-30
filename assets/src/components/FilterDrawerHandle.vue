<template>
  <button class="flex items-center text-80 px-2 animate hover:bg-grey-dark">
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