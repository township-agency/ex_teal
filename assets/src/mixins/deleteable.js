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
    deleteResources(resources, callback = null) {
      return ExTeal.request({
        url: `api/${this.resourceName}`,
        method: "delete",
        params: {
          ...this.queryString,
          ...{ resources: mapResources(resources) }
        }
      }).then(
        callback
          ? callback
          : () => {
              this.deleteModalOpen = false;
              this.getResources();
            }
      );
    },

    /**
     * Delete the selected resources.
     */
    deleteSelectedResources() {
      this.deleteResources(this.selectedResources);
    },

    /**
     * Delete all of the matching resources.
     */
    deleteAllMatchingResources() {
      return ExTeal.request({
        url: `api/${this.resourceName}`,
        method: "delete",
        params: {
          ...this.queryString,
          ...{ resources: "all" }
        }
      }).then(() => {
        this.deleteModalOpen = false;
        this.getResources();
      });
    }
  }
};

function mapResources(resources) {
  return _.map(resources, resource => resource.id).join(",");
}
