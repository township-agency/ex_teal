<template>
  <default-field
    :field="field"
    :errors="errors"
  >
    <template slot="field">
      <span class="form-file mr-4">
        <input
          :id="idAttr"
          ref="fileField"
          class="form-file-input select-none"
          type="file"
          name="name"
          @change="fileChange"
        >
        <label
          :for="labelFor"
          class="form-file-btn btn btn-default btn-primary select-none"
        >
          Choose File
        </label>
      </span>

      <span class="text-gray-50 select-none"> {{ currentLabel }} </span>
    </template>
  </default-field>
</template>

<script>
import { FormField, HandlesValidationErrors } from '@/mixins';
export default {
  mixins: [ HandlesValidationErrors, FormField ],

  data: () => ({
    file: null,
    fileName: null
  }),

  computed: {
    /**
     * The current label of the file field.
     */
    currentLabel () {
      return this.fileName || 'No File Selected';
    },

    /**
     * The ID attribute to use for the file field.
     */
    idAttr () {
      return this.labelFor;
    },

    /**
     * The label attribute to use for the file field.
     */
    labelFor () {
      return `file-${this.field.attribute}`;
    }
  },

  mounted () {
    this.field.fill = formData => {
      if (this.file) {
        formData.append(this.field.attribute, this.file, this.fileName);
      }
    };
  },

  methods: {
    fileChange (event) {
      const path = event.target.value;
      const fileName = path.match(/[^\\/]*$/)[0];
      this.fileName = fileName;
      this.file = this.$refs.fileField.files[0];
    }
  }
};
</script>
