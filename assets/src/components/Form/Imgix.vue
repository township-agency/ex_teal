<template>
  <default-field :field="field">
    <template slot="field">
      <transition name="fade">
        <div v-if="!isEditing">
          <img v-if="showPreview" :src="imgixUrl" class="h-20 block mb-2" />

          <div v-if="hasValue" class="my-2 block">
            <a
              :href="s3DirectUrl"
              target="_blank"
              class="btn btn-default btn-primary btn-icon-inline"
            >
              <icon type="link" class="mr-2" /> <span>Link</span>
            </a>

            <a class="btn btn-default btn-icon-inline" @click="showEdit">
              <icon type="edit" class="mr-2" /> <span>Edit</span>
            </a>
          </div>
        </div>
      </transition>
      <transition name="fade">
        <div v-if="isEditing" class="form-file mr-4 h-20">
          <input
            ref="fileField"
            :dusk="field.attribute"
            :id="idAttr"
            class="form-file-input"
            type="file"
            name="name"
            @change="fileChange"
          />
          <label
            :for="labelFor"
            class="form-file-btn btn btn-default btn-primary"
          >
            Choose File
          </label>

          <span class="text-gray-50"> {{ currentLabel }} </span>
          <a v-if="value" class="btn btn-default" @click="cancelEdit">Cancel</a>
        </div>
      </transition>
    </template>
  </default-field>
</template>

<script>
import axios from "axios";
import SmoothReflow from "vue-smooth-reflow";

import { FormField, HandlesValidationErrors } from "ex-teal-js";

export default {
  mixins: [HandlesValidationErrors, FormField, SmoothReflow],

  data: () => ({
    file: null,
    label: "no file selected",
    fileName: "",
    value: null,
    isEditing: false,
    uploadProgress: 0,
    isUploading: false
  }),

  computed: {
    /**
     * The current label of the file field
     */
    currentLabel() {
      if (this.uploadProgress !== 0) {
        return `${this.uploadProgress}% Complete`;
      }
      if (this.isUploading) {
        return "Uploading...";
      }
      return this.label || this.fileName;
    },

    /**
     * The ID attribute to use for the file field
     */
    idAttr() {
      return this.labelFor;
    },

    /**
     * The label attribute to use for the file field
     * @return {[type]} [description]
     */
    labelFor() {
      return `file-${this.field.attribute}`;
    },

    /**
     * Determine whether the field has a value
     */
    hasValue() {
      return Boolean(this.value);
    },

    imgixUrl() {
      return `//${this.field.options.imgix_host}/${this.value}`;
    },

    isImgix() {
      return this.field.options.type == "imgix";
    },

    showPreview() {
      return this.hasValue && this.isImgix && !this.isEditing;
    },

    s3DirectUrl() {
      return `//${this.field.options.s3_host}/${this.value}`;
    }
  },

  mounted() {
    this.$smoothReflow();
    this.value = this.field.value;

    this.field.fill = form => {
      if (this.isEditing) {
        form[this.field.attribute] = null;
        return;
      }
      form[this.field.attribute] = this.value;
    };

    if (!this.field.value) {
      this.isEditing = true;
    }
  },

  methods: {
    /**
     * Responds to the file change
     */
    fileChange(event) {
      this.field.value = null;
      let path = event.target.value;
      let fileName = path.match(/[^\\/]*$/)[0];
      this.fileName = fileName;

      this.file = this.$refs.fileField.files[0];
      this.signFileForUpload().then(() => {
        this.file = null;
      });
    },

    async signFileForUpload() {
      let { type, name } = this.file;
      this.isUploading = true;

      let { data: response } = await ExTeal.request().post(
        "/plugins/imgix/sign",
        {
          fileName: name,
          contentType: type
        }
      );

      let config = {
        onUploadProgress: progressEvent => {
          var percentCompleted = Math.round(
            (progressEvent.loaded * 100) / progressEvent.total
          );
          this.uploadProgress = percentCompleted;
        },
        headers: { "Content-Type": "multipart/form-data" }
      };

      let fd = new FormData();
      let signature = response.signature;
      Object.keys(signature).forEach(key => {
        fd.append(key, signature[key]);
      });
      fd.append("file", this.file);

      let s3Response = await axios.post(response.postEndpoint, fd, config);

      if (s3Response.status == 201) {
        this.value = signature.key;
        this.file = null;
        this.isUploading = false;
        this.uploadProgress = 0;
        this.label = `${this.fileName} Uploaded`;
        this.isEditing = false;
        return;
      }
    },

    showEdit() {
      this.isEditing = true;
    },

    cancelEdit() {
      this.isEditing = false;
    }
  }
};
</script>
