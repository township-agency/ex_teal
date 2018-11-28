<template>
  <trix-editor
    ref="theEditor"
    :value="value"
    :placeholder="placeholder"
    class="trix-content"
    @trix-initialize="initialize"
    @trix-change="handleChange"
  />
</template>

<script>
import Trix from "trix"; // eslint-disable-line no-unused-vars
import "trix/dist/trix.css";

export default {
  props: {
    value: { type: String, default: "" },
    placeholder: { type: String, default: "" }
  },
  methods: {
    initialize() {
      this.$refs.theEditor.editor.insertHTML(this.value);
    },
    handleChange() {
      this.$emit("change", this.$refs.theEditor.value);
    }
  }
};
</script>
