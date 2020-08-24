<template>
  <panel-item :field="field">
    <template slot="value">
      <ul
        v-if="value.length > 0"
        class="list-reset"
      >
        <li
          v-for="option in value"
          :key="option.name"
          class="mb-1"
        >
          <span
            :class="classes[option.checked]"
            class="inline-flex items-center py-1 pl-2 pr-3 rounded-full font-bold text-sm leading-tight"
          >
            <fake-checkbox
              :checked="option.checked"
              width="20"
              height="20"
            />
            <span class="ml-1">{{ option.label }}</span>
          </span>
        </li>
      </ul>
      <span v-else>{{ field.options.no_value || "No Data" }}</span>
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

  data: () => ({
    value: [],
    classes: {
      true: 'bg-success-light text-success-dark',
      false: 'bg-danger-light text-danger-dark',
    },
  }),

  created () {
    this.field.value = this.field.value || {};
    const options = this.field.options.group_options || {};
    this.value = Object.keys(options).map(name => {
      return {
        name: name,
        label: options[name],
        checked: this.field.value[name] || false
      };
    });
  },
};
</script>
