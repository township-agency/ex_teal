<template>
  <div class="create-resource-button">
    <!-- Create Related Models -->
    <router-link
      :class="classesWithOverrides"
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
      :title="title"
      tag="button"
    >
      <icon type="create" />
    </router-link>
  </div>
</template>

<script>
export default {
  props: {
    classes: {
      default: "",
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
    },

    title() {
      return `Create ${this.singularName}`;
    },

    classesWithOverrides() {
      return `btn btn-default btn-primary capitalize btn-only-icon ${
        this.classes
      }`;
    }
  }
};
</script>
