function mapResources (resources) {
  return resources.map(resource => resource.id).join(',');
}

export const Deleteable = {
  computed: {
    deleteParams () {
      return {
        search: this.currentSearch,
        field_filters: this.encodedFieldFilters,
        via_resource: this.viaResource,
        via_resource_id: this.viaResourceId,
        via_resource_relationship: this.viaResourceRelationship,
        via_relationship: this.viaRelationship,
        relationship_type: this.relationshipType
      };
    }
  },

  methods: {
    /**
     * Open the delete menu modal.
     */
    openDeleteModal () {
      this.deleteModalOpen = true;
    },

    /**
     * Delete the given resources.
     */
    deleteResources (resources, callback = null) {
      if (this.viaManyToMany) {
        return this.detachResources(resources, callback);
      }

      return ExTeal.request({
        url: `api/${this.resourceName}`,
        method: 'delete',
        params: {
          ...this.deleteParams,
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

    detachResources (resources, callback) {
      return ExTeal.request({
        url: `api/${this.viaResource}/${this.viaResourceId}/detach/${this.viaRelationship}`,
        method: 'delete',
        params: {
          ...this.deleteParams,
          resources: mapResources(resources)
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
    deleteSelectedResources () {
      this.deleteResources(this.selectedResources);
    },

    /**
     * Delete all of the matching resources.
     */
    deleteAllMatchingResources () {
      return ExTeal.request({
        url: `api/${this.resourceName}`,
        method: 'delete',
        params: {
          ...this.deleteParams,
          ...{ resources: 'all' }
        }
      }).then(() => {
        this.deleteModalOpen = false;
        this.getResources();
      });
    }
  }
};
