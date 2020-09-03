<template>
  <div>
    <slot>
      <h4 class="mb-3 pl-5 text-gray-darkest font-normal text-lg">
        {{ panel.name }}
      </h4>
    </slot>

    <card class="mb-6 py-3 px-6">
      <component
        :is="resolveComponentName(field)"
        v-for="(field, index) in panel.fields"
        :key="index"
        :class="{ 'remove-bottom-border': index == panel.fields.length - 1 }"
        :resource-name="resourceName"
        :resource-id="resourceId"
        :resource="resource"
        :field="field"
        @actionExecuted="actionExecuted"
      />
    </card>
  </div>
</template>

<script>
import { BehavesAsPanel } from 'ex-teal-js';

export default {
  mixins: [ BehavesAsPanel ],

  methods: {
    /**
     * Resolve the component name.
     */
    resolveComponentName (field) {
      return field.prefix_component
        ? 'detail-' + field.component
        : field.component;
    }
  }
};
</script>
