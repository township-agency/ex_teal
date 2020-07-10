<template>
  <p v-if="value" slot="value" class="text-90">
    <img v-if="isImgix" :src="imgixUrl" class="block mb-2 w-48" />
    <a
      :href="directUrl"
      target="_blank"
      class="btn btn-default btn-primary btn-icon-inline"
    >
      <icon type="link" class="mr-2" /> <span>Link</span>
    </a>
  </p>
</template>

<script>
export default {
  props: {
    resourceName: {
      type: String,
      required: true
    },
    resourceId: {
      type: [String, Number],
      required: true
    },
    resource: {
      type: Object,
      required: true
    },
    field: {
      type: Object,
      required: true
    },
    value: {
      type: String,
      required: true
    }
  },

  computed: {
    imgixUrl() {
      return `//${this.field.options.imgix_host}/${this.value}`;
    },

    isImgix() {
      return true;
    },

    directUrl() {
      if(this.isImgix) {
        return this.imgixUrl;
      }

      if(this.field.options.presign_s3) {
        return this.field.options.presigned_url;
      }
      
      return `//${this.field.options.s3_host}/${this.value}`;
    }
  }
};
</script>
