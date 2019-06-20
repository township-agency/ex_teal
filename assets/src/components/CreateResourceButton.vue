<template>
  <div class="create-resource-button">
    <router-link
      v-if="shouldShowAttachButton"
      :class="classesWithOverrides"
      :to="{
        name: 'attach',
        params: {
          resourceName: viaResource,
          resourceId: viaResourceId,
          relatedResourceName: resourceName,
        },
        query: {
          viaRelationship: viaRelationship
        }
      }"
    >
      <icon type="create" />
    </router-link>
    <!-- Create Related Models -->
    <router-link
      v-else-if="shouldShowCreateButton"
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
      default: '',
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
      default: ''
    },
    viaResourceId: {
      type: Number,
      default: null
    },
    viaRelationship: {
      type: String,
      default: ''
    },
    relationshipType: {
      type: String,
      default: ''
    },
    canCreate: {
      type: Boolean,
      default: true
    }
  },

  computed: {
    shouldShowAttachButton () {
      return this.relationshipType === 'ManyToMany';
    },

    shouldShowCreateButton () {
      return this.canCreate;
    },

    title () {
      return `Create ${this.singularName}`;
    },

    classesWithOverrides () {
      return `btn btn-default btn-primary capitalize btn-only-icon ${
        this.classes
      }`;
    }
  }
};
</script>
