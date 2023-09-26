<template>
  <panel-item :field="field">
    <template slot="value">
      <div v-if="field.value && field.value.length > 1">
        <div
          v-for="(item, index) in field.value"
          :key="index"
        >
          <div class="border p-4 mb-4">
            <component
              :is="resolveComponentName(nested_field)"
              v-for="(nested_field, nested_index) in item"
              :key="nested_index"
              :class="{ 'remove-bottom-border': index === field.value.length - 1 }"
              :resource-name="resourceName"
              :resource-id="resourceId"
              :resource="resource"
              :field="nested_field"
            />
          </div>
        </div>
      </div>
      <div v-else>
        &mdash;
      </div>
    </template>
  </panel-item>
</template>

<script>
export default {
  props: {
    resourceName: {
      type: String,
      required: true
    },
    resourceId: {
      type: [ String, Number ],
      required: true
    },
    resource: {
      type: Object,
      required: true
    },
    field: {
      type: Object,
      required: true
    }
  },

  methods: {
    resolveComponentName (field) {
      return field.prefix_component
        ? 'detail-' + field.component
        : field.component;
    },
  }
};
</script>