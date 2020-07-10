<template>
  <div>
    <transition name="fade">
      <div v-if="!isEditing" :class="layoutClass">
        <img v-if="showPreview" :src="imgixUrl" class="h-20 block mb-2" />

        <div v-if="hasValue" class="my-2 block">
          <a
            v-if="canShowLink"
            :href="directUrl"
            target="_blank"
            class="btn btn-default btn-primary btn-icon-inline"
          >
            <icon type="link" class="mr-2" /> <span>Link</span>
          </a>

          <a class="btn btn-default btn-secondary btn-icon-inline cursor" @click="showEdit">
            <icon type="edit" class="mr-2" /> <span>Edit</span>
          </a>

          <a class="btn btn-default btn-danger btn-icon-inline" @click="deleteFile">
            <icon type="delete" class="mr-2" /> <span>Delete</span>
          </a>

          <span class="ml-2" v-if="!canShowLink">
            {{currentLabel}}
          </span>
        </div>
      </div>
    </transition>
    <transition name="fade">
      <div v-if="isEditing" class="form-file mr-4 h-20 flex items-center" >
        <input
          ref="fileField"
          :id="idAttr"
          class="form-file-input"
          type="file"
          name="name"
          @change="fileChange"
        />
        <label
          :for="labelFor"
          class="form-file-btn btn btn-default btn-primary mr-2"
        >
          Choose File
        </label>

        <span class="text-gray-50"> {{ currentLabel }} </span>
        <a v-if="value" class="btn btn-default" @click="cancelEdit">Cancel</a>
      </div>
    </transition>
  </div>
</template>

<script>
import axios from "axios";
import SmoothReflow from "vue-smooth-reflow";

import { HandlesValidationErrors } from "ex-teal-js";

export default {
  name: 'image-uploader',

  mixins: [HandlesValidationErrors, SmoothReflow],

  props: {
    value: String,
    index: Number,
    field: { type: Object, required: true },
    isHorizontal: {
      type: Boolean,
      default: false,
    }
  },

  data: () => ({
    file: null,
    label: "No File Selected",
    fileName: "",
    isEditing: false,
    uploadProgress: 0,
    isUploading: false,
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
      return true; //this.field.options.type == "imgix";
    },

    canShowLink() {
      return this.isImgix || this.canShowS3;
    },

    canShowS3() {
      return !this.field.options.presign_s3 || (this.field.options.presigned_url && !this.value.length > 0);
    },

    showPreview() {
      return this.hasValue && this.isImgix && !this.isEditing;
    },

    directUrl() {
      if(this.isImgix) {
        return this.imgixUrl;
      }

      if(this.field.options.presign_s3) {
        return this.field.options.presigned_url;
      }

      return `//${this.field.options.s3_host}/${this.value}`;
    },

    layoutClass() {
      return this.isHorizontal ? 'flex justify-between items-center' : ''
    }
  },

  watch: {
    value(newVal, oldVal) {
      if (!newVal) {
        this.isEditing = true
        this.label = "No File Selected"
        this.fileName = ""
      }
    }
  },

  mounted() {
    this.$smoothReflow();

    if (!this.value) {
      this.isEditing = true;
    }
  },

  methods: {
    /**
     * Responds to the file change
     */
    fileChange(event) {
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
        this.file = null;
        this.isUploading = false;
        this.uploadProgress = 0;
        this.label = `${this.fileName} Uploaded`;
        this.isEditing = false;

        this.$emit('input', signature.key)
        return;
      }
    },

    showEdit() {
      this.isEditing = true;
    },

    cancelEdit() {
      this.isEditing = false;
    },

    deleteFile() {
      this.$emit('input', null)
      this.file = null;
      this.isEditing = true;
      this.label = "No File Selected";
    }
  }
};
</script>