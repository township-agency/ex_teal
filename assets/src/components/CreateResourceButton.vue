<template>
  <span class="ml-auto">
    <!-- Create Related Models -->
    <router-link
      :class="classes"
      :to="{
        name: 'create',
        params: {
          resourceName: resourceName
        },
        query: {
          viaResource: viaResource,
          viaResourceId: viaResourceId,
          viaRelationship: viaRelationship
        }
      }"
      tag="button"
    >
      Create {{ singularName }}
    </router-link>
  </span>
</template>

<script>
export default {
  props: {
    classes: {
      default: "btn btn-default btn-primary capitalize",
      type: String
    },
    singularName: {
      type: String,
      required: true
    },
    resourceName: {
      type: String,
      required: true
    },
    viaResource: {
      type: String,
      default: ""
    },
    viaResourceId: {
      type: Number,
      default: null
    },
    viaRelationship: {
      type: String,
      default: ""
    },
    relationshipType: {
      type: String,
      default: ""
    }
  },

  computed: {
    shouldShowCreateButton() {
      return true;
    }
  }
};
</script>
