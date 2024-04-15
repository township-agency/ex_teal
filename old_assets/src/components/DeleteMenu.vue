<template>
  <div>
    <button
      v-if="shouldShowDeleteButton"
      class="btn btn-default btn-only-icon bg-danger text-white"
      @click="confirmDeleteSelectedResources"
    >
      <icon
        type="delete"
        class="text-white"
      />
    </button>

    <portal to="modals">
      <transition name="fade">
        <delete-resource-modal
          v-if="deleteSelectedModalOpen"
          :mode="'delete'"
          @close="closeDeleteSelectedModal"
          @confirm="deleteSelectedResources"
        />
      </transition>
    </portal>
  </div>
</template>

<script>
export default {
  props: {
    resources: {
      type: Array,
      required: true
    },
    selectedResources: {
      type: Array,
      required: true
    },
    allMatchingResourceCount: {
      type: Number,
      required: true
    },
    allMatchingSelected: {
      type: Boolean,
      required: true
    }
  },

  data: () => ({
    deleteSelectedModalOpen: false
  }),

  computed: {
    selectedResourcesCount () {
      return this.allMatchingSelected
        ? this.allMatchingResourceCount
        : this.selectedResources.length;
    },

    shouldShowDeleteButton () {
      return true;
    }
  },

  /**
   * Mount the component.
   */
  mounted () {
    document.addEventListener('keydown', this.handleEscape);
  },

  /**
   * Prepare the component to tbe destroyed.
   */
  destroyed () {
    document.removeEventListener('keydown', this.handleEscape);
  },

  methods: {
    confirmDeleteSelectedResources () {
      this.deleteSelectedModalOpen = true;
    },

    closeDeleteSelectedModal () {
      this.deleteSelectedModalOpen = false;
    },

    /**
     * Delete the selected resources.
     */
    deleteSelectedResources () {
      if (this.allMatchingSelected) {
        this.$emit('deleteAllMatching');
        return;
      }

      this.$emit('deleteSelected');
    },

    /**
     * Handle the escape key press event.
     */
    handleEscape (e) {
      if (this.show && e.keyCode == 27) {
        this.close();
      }
    },

    /**
     * Close the modal.
     */
    close () {
      this.$emit('close');
    }
  }
};
</script>
