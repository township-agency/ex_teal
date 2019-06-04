<template>
  <panel-item :field="field">
    <template slot="value">
      <router-link
        v-if="field.value"
        :to="{
          name: 'detail',
          params: {
            resourceName: field.options.belongs_to_relationship,
            resourceId: field.options.belongs_to_id
          }
        }"
        class="no-underline font-bold dim text-primary"
      >
        {{ field.value }}
      </router-link>
      <p v-else>
        &mdash;
      </p>
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
  }
};
</script>
