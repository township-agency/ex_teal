<template>
  <loading-view :loading="initialLoading">
    <div
      v-for="panel in availablePanels"
      :key="panel.key"
      class="mb-8">
      <component
        :is="panel.component"
        :resource-name="resourceName"
        :resource-id="resourceId"
        :resource="resource"
        :panel="panel"
      >
        <div
          v-if="panel.name.includes('Details')"
          class="card-headline">
          <h2 class="text-90 font-normal text-xl">{{ panel.name }}</h2>
          <div class="ml-auto flex">
            <button
              class="btn btn-default btn-icon btn-danger mr-3"
              title="Delete"
              @click="openDeleteModal"
            >
              <icon
                type="delete"
                class="text-white" />
            </button>

            <portal to="modals">
              <transition name="fade">
                <delete-resource-modal
                  v-if="deleteModalOpen"
                  mode="delete"
                  @confirm="confirmDelete"
                  @close="closeDeleteModal"
                />
              </transition>
            </portal>

            <router-link
              :to="{ name: 'edit', params: {id: resource.id} }"
              data-testid="edit-resource"
              dusk="edit-resource-button"
              class="btn btn-default btn-icon btn-primary"
              title="Edit"
            >
              <icon
                type="edit"
                class="text-white"
                style="margin-top: -2px; margin-left: 3px" />
            </router-link>
          </div>

        </div>

      </component>
    </div>
  </loading-view>
</template>

<script>
import { InteractsWithResourceInformation, Deleteable } from "@/mixins";
import _ from "lodash";
export default {
  mixins: [InteractsWithResourceInformation, Deleteable],
  props: {
    resourceName: {
      type: String,
      required: true
    },
    resourceId: {
      type: Number,
      required: true
    }
  },

  data: () => ({
    initialLoading: true,
    loading: true,

    resource: null,
    panels: [],
    deleteModalOpen: false
  }),

  computed: {
    /**
     * Get the available field panels.
     */
    availablePanels() {
      if (this.resource) {
        var panels = {};

        var fields = _.toArray(
          JSON.parse(JSON.stringify(this.resource.fields))
        );

        fields.forEach(field => {
          if (field.options.listable) {
            return (panels[field.name] = this.createPanelForRelationship(
              field
            ));
          } else if (panels[field.panel]) {
            return panels[field.panel].fields.push(field);
          }

          panels[field.panel] = this.createPanelForField(field);
        });

        return _.toArray(panels);
      }
    }
  },

  watch: {
    resourceId: function(newResourceId, oldResourceId) {
      if (newResourceId != oldResourceId) {
        this.initializeComponent();
      }
    }
  },

  /**
   * Mount the component.
   */
  mounted() {
    this.initializeComponent();
  },

  methods: {
    /**
     * Initialize the compnent's data.
     */
    async initializeComponent() {
      await this.getResource();

      this.initialLoading = false;
    },

    /**
     * Open the delete modal
     */
    openDeleteModal() {
      this.deleteModalOpen = true;
    },

    /**
     * Close the delete modal
     */
    closeDeleteModal() {
      this.deleteModalOpen = false;
    },

    /**
     * Show the confirmation modal for deleting or detaching a resource
     */
    async deleteResource(resource) {
      try {
        await this.deleteRequest(resource);
      } catch (error) {
        if (error.response.status == 422) {
          let resp_errors = error.response.data.errors;
          let messages = Object.values(resp_errors)[0].join(", ");
          this.$toasted.show("Could not delete, error: " + messages, {
            type: "error"
          });
        }
      }
    },
    async confirmDelete() {
      try {
        await this.deleteResources(this.resource, () => {
          this.$toasted.show(
            `The ${this.resourceInformation.singular.toLowerCase()} was deleted!`,
            { type: "success" }
          );

          if (!this.resource.softDeletes) {
            this.$router.push({
              name: "index",
              params: { resourceName: this.resourceName }
            });
            return;
          }

          this.closeDeleteModal();
          this.getResource();
        });
      } catch (error) {
        if (error.response.status == 422) {
          let resp_errors = error.response.data.errors;
          let messages = Object.values(resp_errors)[0].join(", ");
          this.$toasted.show("Could not delete, error: " + messages, {
            type: "error"
          });
        }
      }
    },

    /**
     * Get the resource information.
     */
    getResource() {
      this.resource = null;

      return ExTeal.request()
        .get(`/api/${this.resourceName}/${this.resourceId}`)
        .then(({ data: { panels, fields } }) => {
          this.panels = panels;
          this.resource = { fields };
          this.loading = false;
        })
        .catch(error => {
          if (error.response.status >= 500) {
            ExTeal.$emit("error", error.response.data.message);
            return;
          }

          if (error.response.status === 404 && this.initialLoading) {
            this.$router.push({ name: "404" });
            return;
          }

          if (error.response.status === 403) {
            this.$router.push({ name: "403" });
            return;
          }

          this.$toasted.show(this.__("This resource no longer exists"), {
            type: "error"
          });

          this.$router.push({
            name: "index",
            params: { resourceName: this.resourceName }
          });
        });
    },

    /**
     * Create a new panel for the given relationship field.
     */
    createPanelForRelationship(field) {
      return {
        component: "relationship-panel",
        prefixComponent: true,
        name: field.name,
        fields: [field]
      };
    },

    /**
     * Create a new panel for the given field.
     */
    createPanelForField(field) {
      return _.tap(
        _.find(this.panels, panel => panel.key == field.panel),
        panel => {
          panel.component = "panel";
          panel.fields = [field];
        }
      );
    }
  }
};
</script>
