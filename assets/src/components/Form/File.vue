<template>
  <default-field :field="field" :errors="errors">
    <template slot="field">
      <span class="form-file mr-4">
        <input
          ref="fileField"
          :dusk="field.attribute"
          :id="idAttr"
          class="form-file-input select-none"
          type="file"
          name="name"
          @change="fileChange"
        />
        <label
          :for="labelFor"
          class="form-file-btn btn btn-default btn-primary select-none"
        >
          Choose File
        </label>
      </span>

      <span class="text-gray-50 select-none"> {{ currentLabel }} </span>

      <p v-if="hasError" class="text-xs mt-2 text-danger">{{ firstError }}</p>
    </template>
  </default-field>
</template>

<script>
import { FormField, HandlesValidationErrors } from "@/mixins";
export default {
  mixins: [HandlesValidationErrors, FormField],

  data: () => ({
    file: null,
    fileName: null
  }),

  computed: {
    /**
     * The current label of the file field.
     */
    currentLabel() {
      return this.fileName || "No File Selected";
    },

    /**
     * The ID attribute to use for the file field.
     */
    idAttr() {
      return this.labelFor;
    },

    /**
     * The label attribute to use for the file field.
     */
    labelFor() {
      return `file-${this.field.attribute}`;
    }
  },

  mounted() {
    this.field.fill = formData => {
      if (this.file) {
        formData.append(this.field.attribute, this.file, this.fileName);
      }
    };
  },

  methods: {
    fileChange(event) {
      let path = event.target.value;
      let fileName = path.match(/[^\\/]*$/)[0];
      this.fileName = fileName;
      this.file = this.$refs.fileField.files[0];
    }
  }
};
</script>
