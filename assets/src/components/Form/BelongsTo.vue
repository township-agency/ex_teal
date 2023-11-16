<template>
  <default-field
    :field="field"
    :errors="errors"
  >
    <template slot="field">
      <search-input
        :disabled="creatingViaRelatedResource"
        :error="hasError"
        :value="selectedResource"
        :data="availableResources"
        :is-searching="isSearching"
        track-by="value"
        search-by="display"
        class="mb-3"
        @input="performSearch"
        @clear="clearSelection"
        @selected="selectResource"
      >
        <div
          v-if="selectedResource"
          slot="default"
          class="flex items-center"
        >
          <div
            v-if="selectedResource.thumbnail"
            class="mr-3"
          >
            <img
              :src="selectedResource.thumbnail"
              class="w-6 h-6 rounded block"
            >
          </div>
          <div class="flex">
            <p class="text-gray-darkest mr-2">
              {{ selectedResource.title }}
            </p>
            <p
              v-if="selectedResource.subtitle"
              class="text-xs mt-1 opacity-75"
            >
              {{ selectedResource.subtitle }}
            </p>
          </div>
        </div>

        <div
          slot="option"
          slot-scope="{ option }"
          class="flex items-center"
        >
          <div
            v-if="option.thumbnail"
            class="mr-3"
          >
            <img
              :src="option.thumbnail"
              class="w-8 h-8 rounded block"
            >
          </div>
          <div>
            <p class="text-gray-darkest">
              {{ option.title }}
            </p>
            <p
              v-if="option.subtitle"
              class="text-xs mt-1 opacity-75"
            >
              {{ option.subtitle }}
            </p>
          </div>
        </div>
      </search-input>
    </template>
  </default-field>
</template>

<script>
import { HandlesValidationErrors, PerformsSearches } from '@/mixins';

export default {
  mixins: [ PerformsSearches, HandlesValidationErrors ],

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
    search: '',
    isSearching: false
  }),

  computed: {
    /**
     * Determine if we are editing and existing resource
     */
    editingExistingResource () {
      return Boolean(this.field.options.belongs_to_id);
    },

    /**
     * Determine if we are creating a new resource via a parent relation
     */
    creatingViaRelatedResource () {
      return (
        this.viaResource == this.field.options.belongs_to_relationship &&
        this.field.options.reverse &&
        this.viaResourceId
      );
    },

    /**
     * Determine if we should select an initial resource when mounting this field
     */
    shouldSelectInitialResource () {
      return Boolean(
        this.editingExistingResource || this.creatingViaRelatedResource
      );
    },

    /**
     * Get the query params for getting available resources
     */
    queryParams () {
      return {
        params: {
          current: this.selectedResourceId,
          first: this.initializingWithExistingResource,
          search: this.search
        }
      };
    },
  },

  /**
   * Mount the component.
   */
  mounted () {
    this.initializeComponent();
  },

  methods: {
    initializeComponent () {
      if (this.editingExistingResource) {
        // If a user is editing an existing resource with this relation
        // we'll have a belongsToId on the field, and we should prefill
        // that resource in this field
        this.initializingWithExistingResource = true;
        this.selectedResourceId = this.field.options.belongs_to_id;
      } else if (this.creatingViaRelatedResource) {
        // If the user is creating this resource via a related resource's index
        // page we'll have a viaResource and viaResourceId in the params and
        // should prefill the resource in this field with that information
        this.initializingWithExistingResource = true;
        this.selectedResourceId = this.viaResourceId;
      }

      if (this.shouldSelectInitialResource) {
        // If we should select the initial resource and the field is
        // searchable, we won't load all the resources but we will select
        // the initial option
        this.getAvailableResources().then(() => this.selectInitialResource());
      } else {
        this.getAvailableResources();
      }

      this.field.fill = this.fill;
    },

    fetchAvailableResources (resourceName, attribute, params) {
      return ExTeal.request().get(
        `/api/${resourceName}/relatable/${attribute}`,
        params
      );
    },

    /**
     * Fill the forms formData with details from this field
     */
    fill (formData) {
      const key = this.field.options.belongs_to_key
        ? this.field.options.belongs_to_key
        : this.field.attribute;

      if (this.selectedResource) {
        formData.append(key, this.selectedResource.id);
      } else {
        formData.append(key, null);
      }
    },

    /**
     * Get the resources that may be related to this resource.
     */
    getAvailableResources () {
      return this.fetchAvailableResources(
        this.resourceName,
        this.field.attribute,
        this.queryParams
      ).then(({ data: { data: resources } }) => {
        this.initializingWithExistingResource = false;
        this.availableResources = resources;
        this.isSearching = false;
      });
    },

    /**
     * Determine if the given value is numeric.
     */
    isNumeric (value) {
      return !isNaN(parseFloat(value)) && isFinite(value);
    },

    /**
     * Select the initial selected resource
     */
    selectInitialResource () {
      this.selectedResource = this.availableResources.find(
        r => r.id == this.selectedResourceId
      );
    },

    performSearch (search) {
      this.search = search;

      const trimmedSearch = search.trim();
      if (trimmedSearch == '') {
        return;
      }
      this.isSearching = true;
      this.debouncer(() => {
        this.getAvailableResources(trimmedSearch);
      }, 500);
    }
  }
};
</script>
