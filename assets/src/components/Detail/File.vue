<template>
  <panel-item :field="field">
    <p v-if="field.value" slot="value" class="text-90">
      <img v-if="isImgix" :src="imgixUrl" class="block mb-2" />
      <a
        :href="s3DirectUrl"
        target="_blank"
        class="btn btn-default btn-primary btn-icon-inline"
      >
        <icon type="link" class="mr-2" /> <span>Link</span>
      </a>
    </p>
  </panel-item>
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
    }
  },

  computed: {
    imgixUrl() {
      return `//${this.field.options.imgix_host}/${this.field.value}`;
    },

    isImgix() {
      return this.field.options.type == "imgix";
    },

    s3DirectUrl() {
      return `//${this.field.options.s3_host}/${this.field.value}`;
    }
  }
};
</script>
