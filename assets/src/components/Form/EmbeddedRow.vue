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
            :class="{'rotate-180': !expanded}"
          >
            <icon type="chevron-down" />
          </div>
        </button>
        <span class="px-2">{{ label }} #{{ index + 1 }}</span>
      </div>
      <div class="inline-flex items-center">
        <button
          type="button"
          class="btn btn-icon btn-sm"
          @click="moveUp(index)"
        >
          <icon type="arrow-up" />
        </button>
        <button
          type="button"
          class="btn btn-icon  btn-sm"
          @click="moveDown(index)"
        >
          <icon type="arrow-down" />
        </button>
        <button
          type="button"
          class="btn btn-icon btn-danger btn-sm"
          @click="removeItem(index)"
        >
          <icon type="delete" />
        </button>
      </div>
    </div>
    <div :class="{'hidden': !expanded}">
      <component
        :is="'form-' + field.component"
        v-for="field in fields"
        :key="fieldKey(field, index)"
        :via-resource="viaResource"
        :via-resource-id="viaResourceId"
        :via-relationship="viaRelationship"
        :resource-name="resourceName"
        :field="field"
      />
    </div>
  </div>
</template>

<script>
export default {
  props: {
    fields: {
      type: Array,
      required: true
    },
    index: {
      type: Number,
      required: true
    },
    errors: {
      type: Object,
      required: true
    },
    label: {
      type: String,
      required: true
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
    }
  },

  data: () => ({
    expanded: true
  }),

  methods: {
    moveUp (index) {
      this.$emit('move-up', index);
    },

    moveDown (index) {
      this.$emit('move-down', index);
    },

    removeItem (index) {
      this.$emit('remove-item', index);
    },

    fieldKey (field, index) {
      return `field-${field.attribute}-${index}`;
    },
    toggleExpand () {
      this.expanded = !this.expanded;
    }
  }
};
</script>