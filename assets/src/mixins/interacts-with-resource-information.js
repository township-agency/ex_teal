import _ from "lodash";

export default {
  computed: {
    /**
     * Get the resource information object for the current resource.
     */
    resourceInformation() {
      return _.find(ExTeal.config.resources, resource => {
        return resource.uri == this.resourceName;
      });
    },

    /**
     * Get the resource information object for the current resource.
     */
    viaResourceInformation() {
      if (!this.viaResource) {
        return;
      }
      if (!ExTeal.config.resources) {
        return;
      }

      return _.find(ExTeal.config.resources, resource => {
        return resource.uri == this.viaResource;
      });
    }
  }
};
