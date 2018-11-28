<template>
  <field-wrapper>
    <div class="sm:w-1/5 px-8 py-2 sm:py-6">
      <slot>
        <form-label :for="field.name">
          {{ field.name || fieldName }}
        </form-label>

        <help-text :show-help-text="showHelpText">
          {{ field.helpText }}
        </help-text>
      </slot>
    </div>
    <div class="sm:w-4/5 px-8 py-2 sm:py-6">
      <slot name="field"/>
    </div>
  </field-wrapper>
</template>

<script>
export default {
  props: {
    field: { type: Object, required: true },
    fieldName: { type: String, default: "" },
    showHelpText: { type: Boolean, default: true }
  }
};
</script>
