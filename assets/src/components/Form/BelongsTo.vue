<template>
  <default-field :field="field">
    <template slot="field">
      <select
        :class="{ 'border-danger': hasError }"
        :data-testid="`${field.resourceName}-select`"
        :disabled="isLocked"
        class="form-control form-select mb-3 w-full"
        @change="selectResourceFromSelectControl"
      >
        <option
          value=""
          selected>Choose {{ field.name }}</option>

        <option
          v-for="resource in availableResources"
          :key="resource.id"
          :value="resource.id"
          :selected="selectedResourceId == resource.id"
        >
          {{ resource.display_title }}
        </option>
      </select>

      <p
        v-if="hasError"
        class="my-2 text-danger">
        {{ firstError }}
      </p>
    </template>
  </default-field>
</template>

<script>
import _ from "lodash";
import { PerformsSearches, HandlesValidationErrors } from "@/mixins";

export default {
  mixins: [PerformsSearches, HandlesValidationErrors],

  props: {
    resourceName: {
      type: String,
      required: true
    },
    field: {
      type: Object,
      required: true
    },
    viaResource: {
      type: String,
      default: null
    },
    viaResourceId: {
      type: Number,
      default: null
    },
    viaRelationship: {
      type: String,
      default: null
    }
  },

  data: () => ({
    availableResources: [],
    initializingWithExistingResource: false,
    selectedResource: null,
    selectedResourceId: null,
    search: ""
  }),

  computed: {
    /**
     * Determine if we are editing and existing resource
     */
    editingExistingResource() {
      return Boolean(this.field.options.belongs_to_id);
    },

    /**
     * Determine if we are creating a new resource via a parent relation
     */
    creatingViaRelatedResource() {
      return (
        this.viaResource == this.field.options.belongs_to_relationship &&
        this.viaResourceId
      );
    },

    /**
     * Determine if we should select an initial resource when mounting this field
     */
    shouldSelectInitialResource() {
      return Boolean(
        this.editingExistingResource || this.creatingViaRelatedResource
      );
    },

    /**
     * Determine if the related resources is searchable
     */
    isSearchable() {
      return false;
    },

    /**
     * Get the query params for getting available resources
     */
    queryParams() {
      return {
        params: {
          current: this.selectedResourceId,
          first: this.initializingWithExistingResource,
          search: this.search
        }
      };
    },

    isLocked() {
      return this.viaResource == this.field.options.belongs_to_relationship;
    }
  },

  /**
   * Mount the component.
   */
  mounted() {
    this.initializeComponent();
  },

  methods: {
    initializeComponent() {
      this.withTrashed = false;

      // If a user is editing an existing resource with this relation
      // we'll have a belongsToId on the field, and we should prefill
      // that resource in this field
      if (this.editingExistingResource) {
        this.initializingWithExistingResource = true;
        this.selectedResourceId = this.field.options.belongs_to_id;
      }

      // If the user is creating this resource via a related resource's index
      // page we'll have a viaResource and viaResourceId in the params and
      // should prefill the resource in this field with that information
      if (this.creatingViaRelatedResource) {
        this.initializingWithExistingResource = true;
        this.selectedResourceId = this.viaResourceId;
      }

      if (this.shouldSelectInitialResource && !this.isSearchable) {
        // If we should select the initial resource but the field is not
        // searchable we should load all of the available resources into the
        // field first and select the initial option
        this.initializingWithExistingResource = false;
        this.getAvailableResources().then(() => this.selectInitialResource());
      } else if (this.shouldSelectInitialResource && this.isSearchable) {
        // If we should select the initial resource and the field is
        // searchable, we won't load all the resources but we will select
        // the initial option
        this.getAvailableResources().then(() => this.selectInitialResource());
      } else if (!this.shouldSelectInitialResource && !this.isSearchable) {
        // If we don't need to select an initial resource because the user
        // came to create a resource directly and there's no parent resource,
        // and the field is searchable we'll just load all of the resources
        this.getAvailableResources();
      }

      this.field.fill = this.fill;
    },

    fetchAvailableResources(resourceName, attribute, params) {
      return ExTeal.request().get(
        `/api/${resourceName}/relatable/${attribute}`,
        params
      );
    },

    /**
     * Select a resource using the <select> control
     */
    selectResourceFromSelectControl(e) {
      this.selectedResourceId = e.target.value;
      this.selectInitialResource();
    },

    /**
     * Fill the forms formData with details from this field
     */
    fill(formData) {
      let key = this.field.options.belongs_to_key
        ? this.field.options.belongs_to_key
        : this.field.attribute;

      if (this.selectedResource) {
        formData[key] = this.selectedResource.id;
      } else {
        formData[key] = null;
      }
    },

    /**
     * Get the resources that may be related to this resource.
     */
    getAvailableResources() {
      return this.fetchAvailableResources(
        this.resourceName,
        this.field.attribute,
        this.queryParams
      ).then(({ data: { data: resources } }) => {
        this.initializingWithExistingResource = false;
        this.availableResources = resources;
      });
    },

    /**
     * Determine if the given value is numeric.
     */
    isNumeric(value) {
      return !isNaN(parseFloat(value)) && isFinite(value);
    },

    /**
     * Select the initial selected resource
     */
    selectInitialResource() {
      this.selectedResource = _.find(
        this.availableResources,
        r => r.id == this.selectedResourceId
      );
    }
  }
};
</script>
