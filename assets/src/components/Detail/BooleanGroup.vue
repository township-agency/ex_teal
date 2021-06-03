<template>
  <panel-item :field="field">
    <template slot="value">
      <ul
        v-if="value.length > 0"
        class="list-reset"
      >
        <li
          v-for="option in value"
          :key="option.value"
          class="mb-1 text-gray-darkest"
        >
          <span
            :class="{ 'bg-success': option.checked, 'bg-danger': !option.checked }"
            class="inline-block rounded-full w-2 h-2 mr-1"
          />
          <span>{{ option.key }}</span>
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
    this.value = options.map(option => {
      return {
        key: option.key,
        value: option.value,
        checked: this.field.value[option.value] || false
      };
    });
  },
};
</script>
