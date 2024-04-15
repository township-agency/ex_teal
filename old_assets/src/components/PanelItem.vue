<template>
  <div :class="styles">
    <div
      :class="{'pt-4 pb-2': field.stacked, 'w-1/4 py-4': !field.stacked}"
    >
      <slot>
        <h4 class="font-normal text-gray-darker">
          {{ label }}
        </h4>
      </slot>
    </div>
    <div
      :class="{'pt-2 pb-4': field.stacked, 'w-3/4 py-4': !field.stacked}"
    >
      <slot name="value">
        <p
          v-if="field.value && !field.as_html"
          class="text-gray-darkest"
        >
          {{ field.value }}
        </p>
        <div
          v-else-if="field.value && field.as_html"
          v-html="field.value"
        />
        <p v-else>
          &mdash;
        </p>
      </slot>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    field: {
      type: Object,
      required: true,
    },
    fieldName: {
      type: String,
      default: '',
    },
  },
  computed: {
    label () {
      return this.fieldName || this.field.name;
    },
    styles () {
      return [
        'flex border-b border-gray-light',
        this.field.stacked && 'flex-col',
      ];
    },
  },
};
</script>
