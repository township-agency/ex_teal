<template>
  <div>
    <div 
      v-for="field in panel.fields" 
      :key="field + resourceId">
      <component
        :is="'detail-' + field.component"
        :resource-name="resourceName"
        :resource-id="resourceId"
        :resource="resource"
        :field="field"
        @actionExecuted="actionExecuted" />
    </div>
  </div>
</template>

<script>
import { BehavesAsPanel } from "@/mixins";

export default {
  mixins: [BehavesAsPanel]
};
</script>
