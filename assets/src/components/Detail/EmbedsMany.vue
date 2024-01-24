<template>
  <panel-item :field="field">
    <template slot="value">
      <div
        v-if="field.value && field.value.length > 0"
        class="space-y-4 mb-4"
      >
        <EmbeddedRow
          v-for="(item, index) in field.value"
          :key="item[0].value"
          :fields="item"
          :index="index"
          :resource-name="resourceName"
          :resource-id="resourceId"
          :resource="resource"
          :label="label"
        />
      </div>
      <div v-else>
        &mdash;
      </div>
    </template>
  </panel-item>
</template>

<script>
import EmbeddedRow from './EmbeddedRow';
import singularOrPlural from '@/util/singularOrPlural';

export default {
  components: { EmbeddedRow },
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

  computed: {
    label () {
      return singularOrPlural(1, this.field.name);
    }
  }
};
</script>