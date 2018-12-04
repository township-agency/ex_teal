<template>
  <default-field :field="field">
    <template slot="field">
      <div v-for="field in indexedFields" :key="field.title" class="mb-2">
        <component
          :is="'form-' + inputType"
          :errors="errors"
          :resource-id="resourceId"
          :resource-name="resourceName"
          :field="field"
        />
      </div>
      <p v-if="hasError" class="my-2 text-danger">{{ firstError }}</p>
    </template>
  </default-field>
</template>

<script>
import _ from "lodash";
import { FormField, HandlesValidationErrors } from "@/mixins";

export default {
  mixins: [HandlesValidationErrors, FormField],

  props: {
    resourceId: {
      type: String,
      required: true
    }
  },

  data() {
    return {
      indexedFields: []
    };
  },

  computed: {
    /**
     * Get the input type.
     */
    inputType() {
      return this.field.options.child_component;
    }
  },

  mounted() {
    this.indexedFields = _.map(this.value, ({ content, title }) => {
      return {
        ...this.field,
        component: this.inputType,
        options: this.field.options,
        value: content,
        name: title
      };
    });

    this.field.fill = form => {
      let data = _.map(this.indexedFields, field => {
        let val = field.fill({});
        return { title: field.name, content: val };
      });
      form[this.field.attribute] = data;
    };
  }
};
</script>
