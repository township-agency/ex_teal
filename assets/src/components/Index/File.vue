<template>
  <div class="flex">
    <img
      v-if="canShowImgix"
      :src="imgixUrl"
      style="object-fit: cover;"
      class="w-8 h-8"
    />
    <span v-else>&mdash;</span>
  </div>
</template>

<script>
export default {
  props: {
    resourceName: {
      type: String,
      default: ""
    },
    field: {
      type: Object,
      default() {
        return {};
      }
    }
  },

  computed: {
    canShowImgix() {
      return this.field.options.type === "imgix" && this.field.value;
    },
    imgixUrl() {
      return `//${this.field.options.imgix_host}/${this.field.value}?w=${
        this.field.options.width
      }&h=${this.field.options.height}`;
    }
  }
};
</script>
