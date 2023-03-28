<template>
  <div v-if="panel.fields.length > 0">
    <heading
      v-if="index > 0"
      :class="panel.helpText ? 'mb-2' : 'mb-3'"
    >
      {{ panel.name }}
    </heading>
    <p
      v-if="helperText"
      class="text-gray-dark text-sm font-semibold italic mb-3"
      v-html="helperText"
    />

    <card>
      <div
        v-for="field in panel.fields"
        :key="field.attribute"
      >
        <component
          :is="'form-' + field.component"
          :errors="validationErrors"
          :resource-name="resourceName"
          :field="field"
          :via-resource="viaResource"
          :via-resource-id="viaResourceId"
          :via-relationship="viaRelationship"
        />
      </div>
    </card>
  </div>
</template>

<script>
export default {
  name: 'FormPanel',

  props: {
    panel: {
      type: Object,
      required: true,
    },

    name: {
      default: 'Panel',
      type: String,
    },

    index: {
      default: 0,
      type: Number,
    },

    fields: {
      type: Array,
      default: () => [],
    },
    resourceName: {
      type: String,
      required: true
    },
    viaResource: {
      default: '',
      type: String
    },
    viaResourceId: {
      default: null,
      type: Number
    },
    viaRelationship: {
      default: '',
      type: String
    },
    validationErrors: {
      type: Object,
      required: true
    }
  },
  computed: {
    helperText () {
      return this.panel.options.helper_text;
    }
  }
};
</script>
