<template>
  <div :class="`text-${field.textAlign}`">
    <tooltip trigger="click">
      <div class="text-primary inline-flex items-center dim cursor-pointer">
        <span class="text-primary font-bold">View</span>
      </div>

      <tooltip-content slot="content">
        <ul
          v-if="value.length > 0"
          class="list-reset"
        >
          <li
            v-for="option in value"
            :key="option.key"
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
              <span class="ml-1">{{ option.value }}</span>
            </span>
          </li>
        </ul>
        <span v-else>{{ field.options.no_value || "No Data" }}</span>
      </tooltip-content>
    </tooltip>
  </div>
</template>

<script>
export default {
  props: {
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
        checked: this.field.value[option.key] || false
      };
    });
  }
};
</script>
