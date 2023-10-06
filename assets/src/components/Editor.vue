<template>
  <trix-editor
    ref="theEditor"
    :value="value"
    :placeholder="placeholder"
    class="trix-content"
    @trix-initialize="initialize"
    @trix-change="handleChange"
    @trix-attachment-add="handleAddFile"
    @trix-file-accept="handleFileAccept"
  />
</template>

<script>
import Trix from 'trix'; // eslint-disable-line no-unused-vars
import 'trix/dist/trix.css';

export default {
  props: {
    value: { type: String, default: '' },
    placeholder: { type: String, default: '' },
    withFiles: { type: Boolean, default: false },
  },

  emits: [ 'change', 'file-added', 'file-removed' ],

  methods: {
    initialize () {
      this.$refs.theEditor.editor.insertHTML(this.value);
    },
    handleChange () {
      this.$emit('change', this.$refs.theEditor.value);
    },

    handleFileAccept (e) {
      if (!this.withFiles) {
        e.preventDefault();
      }
    },

    handleAddFile (event) {
      this.$emit('file-added', event);
    },

    handleRemoveFile (event) {
      this.$emit('file-removed', event);
    },
  }
};
</script>
