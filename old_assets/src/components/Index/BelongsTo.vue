<template>
  <span>
    <span v-if="field.value">
      <router-link
        :to="{
          name: 'detail',
          params: {
            resourceName: field.options.belongs_to_relationship,
            resourceId: field.options.belongs_to_id
          }
        }"
        class="no-underline dim text-primary font-bold"
      >
        {{ field.value }}
      </router-link>
    </span>

    <span v-else>&mdash;</span>
  </span>
</template>

<script>
export default {
  props: {
    resourceName: {
      type: String,
      default: ''
    },
    field: {
      type: Object,
      default () {
        return {};
      }
    }
  }
};
</script>
