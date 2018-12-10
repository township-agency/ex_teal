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
      console.log(resources);
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
    }
  }
};

function mapResources(resources) {
  return _.map(resources, resource => resource.id);
}
