<template>
  <panel-item :field="field">
    <p
      slot="value"
      class="text-gray-darkest"
    >
      <span v-if="field.value.length">
        <span
          v-for="v in field.value"
          :key="v.value"
          class="inline-flex items-center mr-2 border border-rounded-sm px-2 py-1 mb-2"
        >
          <div
            v-if="v.title"
            slot="default"
            class="flex items-center"
          >
            <div
              v-if="v.thumbnail"
              class="mr-3"
            >
              <img
                :src="v.thumbnail"
                class="w-6 h-6 rounded block"
              >
            </div>
            <div class="flex">
              <p class="text-gray-darkest mr-2">
                {{ v.title }}
              </p>
              <p
                v-if="v.subtitle"
                class="text-xs mt-1 opacity-75"
              >
                {{ v.subtitle }}
              </p>
            </div>
          </div>
          <span v-else>
            {{ v.label }}
          </span>
        </span>
      </span>
      <span v-else>&mdash;</span>
    </p>
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
