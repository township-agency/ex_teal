<template>
  <field-wrapper :stacked="field.stacked">
    <div
      class="px-8 py-2"
      :class="{'sm:py-6 sm:w-1/5': !field.stacked, 'sm:pt-4': field.stacked}"
    >
      <slot>
        <form-label :for="field.name">
          {{ field.name || fieldName }}
        </form-label>
      </slot>
    </div>
    <div
      class="px-8 py-2"
      :class="{'sm:w-4/5 sm:py-6': !field.stacked, 'w-full sm:pb-6': field.stacked}"
    >
      <slot name="field" />
      <help-text
        :show-help-text="canShowHelpText"
      >
        {{ helpText }}
      </help-text>
      <p
        v-if="hasError"
        class="my-2 text-danger"
      >
        {{ firstError }}
      </p>
    </div>
  </field-wrapper>
</template>

<script>
import { HandlesValidationErrors } from '@/mixins';

export default {
  mixins: [ HandlesValidationErrors ],

  props: {
    field: { type: Object, required: true },
    fieldName: { type: String, default: '' }
  },

  computed: {
    helpText () {
      return this.field.options.help_text;
    },
    canShowHelpText () {
      return this.helpText != null;
    }
  }
};
</script>
