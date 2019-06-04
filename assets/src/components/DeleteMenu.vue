<template>
  <div>
    <dropdown
      class="ml-3 bg-danger hover:bg-danger-dark text-white rounded border border-danger"
    >
      <dropdown-trigger
        slot-scope="{ toggle }"
        :handle-click="toggle"
        class="px-3"
      >
        <icon
          type="delete"
          class="text-white"
        />
      </dropdown-trigger>

      <dropdown-menu
        slot="menu"
        direction="rtl"
        width="250"
      >
        <div class="px-3">
          <!-- Delete Menu -->
          <button
            class="text-left w-full leading-normal dim my-2 text-danger"
            @click="confirmDeleteSelectedResources"
          >
            Delete Selected ({{ selectedResourcesCount }})
          </button>
        </div>
      </dropdown-menu>
    </dropdown>

    <portal to="modals">
      <transition name="fade">
        <delete-resource-modal
          v-if="deleteSelectedModalOpen"
          :mode="'delete'"
          close="closeDeleteSelectedModal"
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
