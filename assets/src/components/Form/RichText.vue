<template>
  <default-field
    :field="field"
    :errors="errors"
  >
    <template slot="field">
      <editor
        :value="field.value"
        :class="errorClasses"
        :placeholder="field.name"
        :with-files="withFiles"
        @change="handleChange"
        @file-added="handleFileAdded"
      />
    </template>
  </default-field>
</template>

<script>
import { FormField, HandlesValidationErrors } from '@/mixins';

export default {
  mixins: [ FormField, HandlesValidationErrors ],

  props: {
    resourceName: {
      type: String,
      required: true
    },
    field: {
      type: Object,
      required: true
    }
  },

  computed: {
    withFiles () {
      return this.field.options.withFiles || false;
    },
  },

  methods: {
    handleFileAdded ({ attachment }) {
      const uploader = ExTeal.config.asset_upload_provider;

      if (!attachment.file || !uploader) { return; }

      const onUploadProgress = progressEvent => {
        attachment.setUploadProgress(
          Math.round((progressEvent.loaded * 100) / progressEvent.total)
        );
      };

      window[uploader].uploadFile(attachment.file, onUploadProgress).then(({ url }) => {
        return attachment.setAttributes({
          url: url,
          href: url,
        });
      });
    },
  }
};
</script>
