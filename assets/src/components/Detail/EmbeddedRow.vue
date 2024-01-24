<template>
  <div class="border">
    <div class="border-b flex justify-between items-center bg-primary-10">
      <div class="inline-flex items-center pl-2">
        <button
          type="button"
          class="inline-flex items-center"
          @click="toggleExpand"
        >
          <div
            class="origin-center transition-transform transform"
            :class="{ 'rotate-180': !expanded }"
          >
            <icon type="chevron-down" />
          </div>
        </button>
        <span class="px-2">{{ label }} #{{ index + 1 }}</span>
      </div>
    </div>
    <div :class="{ hidden: !expanded, 'px-4': true }">
      <component
        :is="resolveComponentName(field)"
        v-for="(field, i) in fields"
        :key="fieldKey(field, index)"
        :resource-id="resourceId"
        :resource-name="resourceName"
        :resource="resource"
        :field="field"
        :class="{ 'remove-bottom-border': i === fields.length - 1 }"
      />
    </div>
  </div>
</template>

<script>
export default {
  props: {
    fields: {
      type: Array,
      required: true,
    },
    index: {
      type: Number,
      required: true,
    },
    resource: {
      type: Object,
      required: true,
    },
    resourceName: {
      type: String,
      required: true,
    },
    resourceId: {
      type: [String, Number],
      required: true,
    },
    label: {
      type: String,
      default: "Item",
    },
  },

  data: () => ({
    expanded: true,
  }),

  methods: {
    toggleExpand() {
      this.expanded = !this.expanded;
    },
    resolveComponentName(field) {
      return field.prefix_component
        ? "detail-" + field.component
        : field.component;
    },
    fieldKey(field, index) {
      return `field-${field.attribute}-${index}`;
    },
  },
};
</script>
