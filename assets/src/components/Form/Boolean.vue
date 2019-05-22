<template>
  <default-field :field="field">
    <template slot="field">
      <checkbox
        :id="field.attribute"
        :name="field.name"
        :checked="checked"
        class="py-2"
        @input="toggle"
      />

      <p v-if="hasError" class="my-2 text-danger" v-html="firstError" />
    </template>
  </default-field>
</template>

<script>
import { FormField, HandlesValidationErrors } from "@/mixins";

export default {
  mixins: [HandlesValidationErrors, FormField],

  data: () => ({
    value: false
  }),

  computed: {
    checked() {
      return Boolean(this.value);
    }
  },

  mounted() {
    this.value = this.field.value || false;

    this.field.fill = formData => {
      formData.append(this.field.attribute, this.value);
    };
  },

  methods: {
    toggle() {
      this.value = !this.value;
    }
  }
};
</script>
