<template>
  <default-field :field="field">
    <template slot="field">
      <div
        v-on-clickaway="hidePicker"
        class="inline-flex mb-2 relative"
      >
        <input
          :id="field.attribute"
          v-model="value"
          :class="errorClasses"
          type="text"
          class="w-32 form-control form-input form-input-bordered br-0 z-10"
          @focus="showPicker"
          @input="updateFromInput"
        >
        <div
          :style="{ backgroundColor: value }"
          class="color-input border-l-0 h-8 border border-60 w-8"
          @click="togglePicker"
        />
        <chrome-picker
          v-if="displayPicker"
          v-model="value"
          :disable-alpha="disableAlpha"
          class="absolute z-50 top-8"
          @input="updateFromPicker"
        />
      </div>
      <p
        v-if="hasError"
        class="my-2 text-danger"
        v-html="firstError"
      />
    </template>
  </default-field>
</template>

<script>
import { FormField, HandlesValidationErrors } from 'ex-teal-js';
import { Chrome } from 'vue-color';
import { mixin as clickaway } from 'vue-clickaway';

export default {
  components: { 'chrome-picker': Chrome },
  mixins: [ HandlesValidationErrors, FormField, clickaway ],

  data: () => ({
    value: '#FFFFFF',
    displayPicker: false,
    disableAlpha: true
  }),

  mounted () {
    this.value = this.field.value || '#FFFFFF';

    this.field.fill = formData => {
      formData.append(this.field.attribute, this.value);
    };
  },

  methods: {
    handleChange (value) {
      this.value = value.hex;
    },

    showPicker () {
      this.displayPicker = true;
    },

    hidePicker () {
      this.displayPicker = false;
    },

    togglePicker () {
      this.displayPicker ? this.hidePicker() : this.showPicker();
    },

    updateFromInput () {
      this.updateColors(this.value);
    },

    updateFromPicker (color) {
      if (color.rgba.a == 1) {
        this.value = color.hex;
      } else {
        this.value =
          'rgba(' +
          color.rgba.r +
          ', ' +
          color.rgba.g +
          ', ' +
          color.rgba.b +
          ', ' +
          color.rgba.a +
          ')';
      }
    },

    updateColors (color) {
      if (color.slice(0, 1) == '#') {
        this.value = color;
      } else if (color.slice(0, 4) == 'rgba') {
        const rgba = color.replace(/^rgba?\(|\s+|\)$/g, '').split(',');
        const hex =
            '#' +
            (
              (1 << 24) +
              (parseInt(rgba[0]) << 16) +
              (parseInt(rgba[1]) << 8) +
              parseInt(rgba[2])
            )
              .toString(16)
              .slice(1);
        this.value = hex;
      }
    }
  }
};
</script>
