import _ from "lodash";
export default {
  methods: {
    /**
     * Open the delete menu modal.
     */
    openDeleteModal() {
      this.deleteModalOpen = true;
    },

    /**
     * Delete the given resources.
     */
    deleteResources(resource, callback = null) {
      let id = resource.id
        ? resource.id
        : _.find(resource.fields, { attribute: "id" }).value;
      return ExTeal.request()
        .delete(`api/${this.resourceName}/${id}`)
        .then(
          callback
            ? callback
            : () => {
                this.deleteModalOpen = false;
                this.getResources();
              }
        );
    }
  }
};
