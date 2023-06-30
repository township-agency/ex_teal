import find from 'lodash/find';

export const InteractsWithResourceInformation = {
  computed: {
    resourceInformation () {
      return find(ExTeal.config.resources, resource => {
        return resource.uri == this.resourceName;
      });
    },

    viaResourceInformation () {
      if (!this.viaResource) {
        return;
      }
      if (!ExTeal.config.resources) {
        return;
      }

      return find(ExTeal.config.resources, resource => {
        return resource.uri == this.viaResource;
      });
    }
  }
};
