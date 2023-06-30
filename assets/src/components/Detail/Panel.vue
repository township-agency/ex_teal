<template>
  <div>
    <slot>
      <h4 class="mb-3 text-gray-darkest font-normal text-lg">
        {{ panel.name }}
      </h4>
      <p
        v-if="helperText"
        class="text-gray-dark text-sm font-semibold italic mb-3"
        v-html="helperText"
      />
    </slot>

    <card class="mb-6 py-3 px-6">
      <component
        :is="resolveComponentName(field)"
        v-for="(field, index) in fields"
        :key="index"
        :class="{ 'remove-bottom-border': index == panel.fields.length - 1 }"
        :resource-name="resourceName"
        :resource-id="resourceId"
        :resource="resource"
        :field="field"
        @actionExecuted="actionExecuted"
      />
      <div
        v-if="shouldShowShowAllFieldsButton"
        class="bg-20 -mt-px -mx-6 -mb-6 border-t border-40 p-3 flex items-center justify-center"
      >
        <button
          class="block w-full text-sm text-primary font-bold pb-3"
          @click="showAllFields"
        >
          Show All Fields
        </button>
      </div>
    </card>
  </div>
</template>

<script>
import { BehavesAsPanel } from '@/mixins';

export default {
  mixins: [ BehavesAsPanel ],

  computed: {
    fields () {
      const limit = this.panel.options.limit;
      if (limit && limit > 0) {
        return this.panel.fields.slice(0, limit);
      }
      return this.panel.fields;
    },
    /**
     * Determines if should display the 'Show all fields' button.
     */
    shouldShowShowAllFieldsButton () {
      return this.panel.options.limit > 0;
    },

    helperText () {
      if (!this.panel.options || !this.panel.options.helper_text) { return false; }
      return this.panel.options.helper_text;
    }
  },

  methods: {
    /**
     * Resolve the component name.
     */
    resolveComponentName (field) {
      return field.prefix_component
        ? 'detail-' + field.component
        : field.component;
    },

    /**
     * Show all of the Panel's fields.
     */
    showAllFields () {
      return (this.panel.options.limit = 0);
    },
  }
};
</script>
