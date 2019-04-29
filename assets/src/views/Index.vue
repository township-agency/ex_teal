<template>
  <loading-view :loading="initialLoading">
    <div class="card-headline">
      <heading v-if="meta.label" :level="1"> {{ meta.label }} </heading>
      <div class="flex justify-between ml-auto">
        <!-- Search -->
        <div v-if="resourceInformation.searchable" class="relative h-9 mb-6">
          <icon
            type="search"
            class="absolute search-icon-center ml-3 text-70"
          />

          <input
            :placeholder="Search"
            v-model="search"
            class="appearance-none form-control form-input w-search pl-search"
            type="search"
            @keydown.stop="performSearch"
            @search="performSearch"
          />
        </div>
        <div class="index-action-bar">
          <div v-if="shouldShowReorder">
            <button
              v-if="isSorting"
              :disabled="loading"
              class="btn btn-default btn-primary"
              @click="saveSorting"
            >
              Save Changes
            </button>
            <button
              v-if="isSorting"
              :disabled="loading"
              class="btn btn-default btn-secondary ml-4"
              @click="cancelSorting"
            >
              Cancel
            </button>
            <button
              v-if="!isSorting"
              class="bg-grey-lighter hover:bg-grey-light rounded px-2 mr-4 h-8"
              @click="showSort"
            >
              <icon type="reorder" class="text-grey-darker" />
            </button>
          </div>

          <!-- Action Selector -->
          <action-selector
            v-if="selectedResources.length > 0"
            :resource-name="resourceName"
            :actions="actions"
            :query-string="{
              currentSearch,
              encodedFilters,
              viaResource,
              viaResourceId,
              viaRelationship
            }"
            :selected-resources="selectedResourcesForActionSelector"
            @actionExecuted="getResources"
          />

          <dropdown
            v-if="shouldShowFilterDropdown"
            class="bg-white border hover:bg-grey-light rounded"
          >
            <dropdown-trigger
              slot-scope="{ toggle }"
              :handle-click="toggle"
              class="px-3"
            >
              <icon type="filter" class="text-grey-darker" />
              <span class="text-grey-darker text-sm mx-2">Filter</span>
            </dropdown-trigger>

            <dropdown-menu slot="menu" :dark="true" width="290" direction="rtl">
              <!-- Filters -->
              <filter-selector
                :filters="filters"
                :current-filters.sync="currentFilters"
                @changed="filterChanged"
              />

              <!-- Per Page -->
              <filter-select v-if="!viaResource">
                <h3 slot="default" class="small-header">Per Page:</h3>

                <select
                  slot="select"
                  v-model="perPage"
                  dusk="per-page-select"
                  class="block w-full form-control-sm form-select"
                  @change="perPageChanged"
                >
                  <option value="25">25</option>
                  <option value="50">50</option>
                  <option value="100">100</option>
                </select>
              </filter-select>
            </dropdown-menu>
          </dropdown>

          <delete-menu
            v-if="shouldShowDeleteMenu"
            :resources="resources"
            :selected-resources="selectedResources"
            :all-matching-resource-count="allMatchingResourceCount"
            :all-matching-selected="selectAllMatchingChecked"
            @deleteSelected="deleteSelectedResources"
            @deleteAllMatching="deleteAllMatchingResources"
            @close="deleteModalOpen = false"
          />

          <!-- Create / Attach Button -->
          <create-resource-button
            :singular-name="singularName"
            :resource-name="resourceName"
            :via-resource="viaResource"
            :via-resource-id="viaResourceId"
            :via-relationship="viaRelationship"
            :relationship-type="relationshipType"
            classes="btn-lg"
          />
        </div>
      </div>
    </div>

    <loading-card
      :loading="loading"
      :class="{ 'overflow-hidden border border-50': !shouldShowToolbar }"
    >
      <div
        v-if="!resources.length && !loading"
        class="flex justify-center items-center px-6 py-8"
      >
        <div class="text-center">
          <svg
            class="mb-3"
            xmlns="http://www.w3.org/2000/svg"
            width="65"
            height="51"
            viewBox="0 0 65 51"
          >
            <g id="Page-1" fill="none" fill-rule="evenodd">
              <g
                id="05-blank-state"
                fill="#A8B9C5"
                fill-rule="nonzero"
                transform="translate(-779 -695)"
              >
                <path
                  id="Combined-Shape"
                  d="M835 735h2c.552285 0 1 .447715 1 1s-.447715 1-1 1h-2v2c0 .552285-.447715 1-1 1s-1-.447715-1-1v-2h-2c-.552285 0-1-.447715-1-1s.447715-1 1-1h2v-2c0-.552285.447715-1 1-1s1 .447715 1 1v2zm-5.364125-8H817v8h7.049375c.350333-3.528515 2.534789-6.517471 5.5865-8zm-5.5865 10H785c-3.313708 0-6-2.686292-6-6v-30c0-3.313708 2.686292-6 6-6h44c3.313708 0 6 2.686292 6 6v25.049375c5.053323.501725 9 4.765277 9 9.950625 0 5.522847-4.477153 10-10 10-5.185348 0-9.4489-3.946677-9.950625-9zM799 725h16v-8h-16v8zm0 2v8h16v-8h-16zm34-2v-8h-16v8h16zm-52 0h16v-8h-16v8zm0 2v4c0 2.209139 1.790861 4 4 4h12v-8h-16zm18-12h16v-8h-16v8zm34 0v-8h-16v8h16zm-52 0h16v-8h-16v8zm52-10v-4c0-2.209139-1.790861-4-4-4h-44c-2.209139 0-4 1.790861-4 4v4h52zm1 39c4.418278 0 8-3.581722 8-8s-3.581722-8-8-8-8 3.581722-8 8 3.581722 8 8 8z"
                />
              </g>
            </g>
          </svg>

          <h3 class="text-base text-80 font-normal mb-6">
            No {{ resourceInformation.title.toLowerCase() }} matched the given
            criteria.
          </h3>
        </div>
      </div>
      <div class="overflow-hidden overflow-x-auto relative">
        <resource-table
          ref="resourceTable"
          :resource-name="resourceName"
          :resources="resources"
          :fields="meta.fields"
          :singular-name="singularName"
          :is-sorting="isSorting"
          :sortable-by="sortableBy"
          :resources-to-sort.sync="resourcesToSort"
          :should-show-check-boxes="shouldShowCheckBoxes"
          :selected-resources="selectedResources"
          :selected-resource-ids="selectedResourceIds"
          :select-all-matching-resources="selectAllMatchingResources"
          :select-all-matching-checked="selectAllMatchingChecked"
          :update-selection-status="updateSelectionStatus"
          :all-matching-resource-count="allMatchingResourceCount"
          :toggle-select-all="toggleSelectAll"
          :toggle-select-all-matching="toggleSelectAllMatching"
          @order="orderByField"
          @delete="deleteResources"
        />
      </div>

      <!-- Pagination -->
      <pagination-links
        v-if="resourceResponse"
        :resource-name="resourceName"
        :resources="resources"
        :resource-response="resourceResponse"
        :current-page="currentPage"
        @previous="selectPreviousPage"
        @next="selectNextPage"
      />
    </loading-card>
  </loading-view>
</template>

<script>
import _ from "lodash";
import {
  Capitalize,
  Deleteable,
  Filterable,
  InteractsWithQueryString,
  InteractsWithResourceInformation,
  Minimum,
  Paginatable,
  PerPageable
} from "@/mixins";

export default {
  mixins: [
    Deleteable,
    Filterable,
    InteractsWithResourceInformation,
    InteractsWithQueryString,
    Paginatable,
    PerPageable
  ],

  props: {
    resourceName: {
      type: String,
      required: true
    },
    viaResource: {
      type: String,
      default: ""
    },
    viaResourceId: {
      type: Number,
      default: null
    },
    viaRelationship: {
      type: String,
      default: ""
    },
    relationshipType: {
      type: String,
      default: ""
    }
  },

  data: () => ({
    initialLoading: true,
    loading: true,

    resourceResponse: null,
    resources: [],
    meta: {},
    deleteModalOpen: false,

    orderBy: "",
    orderByDirection: "",
    filters: [],
    actions: [],

    selectedResources: [],
    selectAllMatchingResources: false,
    allMatchingResourceCount: 0,

    isSorting: false,

    sortable: false,
    sortableBy: null,

    resourcesToSort: []
  }),

  computed: {
    /**
     * Get the singular name for the resource
     */
    singularName() {
      return Capitalize(this.resourceInformation.singular);
    },

    /**
     * Build the resource request query string.
     */
    resourceRequestQueryString() {
      return _.pickBy(
        {
          filters: this.encodedFilters,
          order_by: this.currentOrderBy,
          order_by_direction: this.currentOrderByDirection,
          per_page: this.currentPerPage,
          page: this.currentPage,
          via_resource: this.viaResource,
          via_resource_id: this.viaResourceId,
          via_relationship: this.viaRelationship,
          via_resource_relationship: this.viaResourceRelationship,
          relationship_type: this.relationshipType
        },
        _.identity
      );
    },

    /**
     * Get the name of the order by query string variable.
     */
    orderByParameter() {
      return this.resourceName + "_order";
    },

    /**
     * Get the name of the order by direction query string variable.
     */
    orderByDirectionParameter() {
      return this.resourceName + "_direction";
    },

    /**
     * Get the name of the per page query string variable.
     */
    perPageParameter() {
      return this.resourceName + "_per_page";
    },

    /**
     * Get the name of the page query string variable.
     */
    pageParameter() {
      return this.resourceName + "_page";
    },

    /**
     * Get the name of the filter query string variable.
     */
    filterParameter() {
      return this.resourceName + "_filter";
    },

    /**
     * Get the current order by value from the query string.
     */
    currentOrderBy() {
      return this.$route.query[this.orderByParameter] || "";
    },

    /**
     * Get the current order by direction from the query string.
     */
    currentOrderByDirection() {
      return this.$route.query[this.orderByDirectionParameter] || "desc";
    },

    /**
     * Get the current search value from the query string.
     */
    currentSearch() {
      return this.$route.query[this.searchParameter] || "";
    },

    /**
     * Determine if there any filters for this resource
     */
    hasFilters() {
      return Boolean(this.filters.length > 0);
    },

    /**
     * Determine if there are any resources for the view
     */
    hasResources() {
      return Boolean(this.resources.length > 0);
    },

    shouldShowFilterDropdown() {
      if (this.isSorting) {
        return false;
      }

      return this.filters.length > 0 || !this.viaResource;
    },

    shouldShowReorder() {
      return (this.sortable && this.sortableBy) || this.meta.sortable_by;
    },

    /**
     * Determine whether to show the toolbar for this resource index
     */
    shouldShowToolbar() {
      return Boolean(this.hasFilters || this.shouldShowReorder);
    },

    /**
     * Get the IDs for the selected resources.
     */
    selectedResourceIds() {
      return _.map(this.selectedResources, resource => resource.id);
    },

    /**
     * Get the selected resources for the action selector.
     */
    selectedResourcesForActionSelector() {
      return this.selectAllMatchingChecked ? "all" : this.selectedResourceIds;
    },

    /**
     * Determine whether to show the selection checkboxes for resources
     */
    shouldShowCheckBoxes() {
      return Boolean(this.hasResources);
    },

    /**
     * Determine if all matching resources are selected.
     */
    selectAllMatchingChecked() {
      return (
        this.selectedResources.length == this.resources.length &&
        this.selectAllMatchingResources
      );
    },

    /**
     * Determine if all resources are selected.
     */
    selectAllChecked() {
      return this.selectedResources.length == this.resources.length;
    },

    /**
     * Determine whether the delete menu should be shown to the user
     */
    shouldShowDeleteMenu() {
      return Boolean(this.selectedResources.length > 0);
    }
  },

  /**
   * Mount the component and retrieve its initial data.
   */
  async created() {
    this.initializeOrderingFromQueryString();
    this.initializePerPageFromQueryString();

    await this.getResources();
    await this.getFilters();

    this.getActions();

    this.initialLoading = false;

    this.$watch(
      () => {
        return (
          this.resourceName +
          this.encodedFilters +
          this.currentOrderBy +
          this.currentOrderByDirection +
          this.currentPage +
          this.currentPerPage
        );
      },
      () => {
        this.getResources();

        this.initializeOrderingFromQueryString();
        this.initializePerPageFromQueryString();
        this.initializeFilterValuesFromQueryString();
      }
    );

    this.$watch(
      () => {
        return this.resourceName;
      },
      () => {
        this.getFilters();
        this.getActions();
      }
    );
  },

  methods: {
    /**
     * Get the resources based on the current page, search, filters, etc.
     */
    getResources() {
      this.loading = true;
      this.$nextTick(() => {
        this.clearResourceSelections();

        return Minimum(
          ExTeal.request().get(`/api/${this.resourceName}`, {
            params: this.resourceRequestQueryString
          })
        ).then(({ data }) => {
          this.resources = [];

          this.resourceResponse = data;
          this.resources = data.data;
          this.meta = data.meta;
          this.allMatchingResourceCount = data.meta.all;
          this.sortable = Boolean(data.meta.sortable_by);
          this.sortableBy = data.meta.sortable_by || "";

          this.loading = false;
        });
      });
    },

    /**
     * Get the filters available for the current resource.
     */
    getFilters() {
      this.filters = [];
      this.currentFilters = [];

      return ExTeal.request()
        .get(`/api/${this.resourceName}/filters`)
        .then(response => {
          this.filters = response.data.filters;
          this.initializeFilterValuesFromQueryString();
        });
    },

    getActions() {
      this.actions = [];
      return ExTeal.request()
        .get(`/api/${this.resourceName}/actions`)
        .then(response => {
          this.actions = response.data.actions;
        });
    },

    /**
     * Sort the resources by the given field.
     */
    orderByField(field) {
      var direction = this.currentOrderByDirection == "asc" ? "desc" : "asc";
      if (this.currentOrderBy != field.attribute) {
        direction = "asc";
      }
      this.updateQueryString({
        [this.orderByParameter]: field.attribute,
        [this.orderByDirectionParameter]: direction
      });
    },

    /**
     * Sync the current order by values from the query string.
     */
    initializeOrderingFromQueryString() {
      this.orderBy = this.currentOrderBy;
      this.orderByDirection = this.currentOrderByDirection;
    },

    showSort() {
      this.perPageBeforeSort = this.currentPerPage;
      this.pageBeforeSort = this.currentPage;

      this.updateQueryString({ [this.perPageParameter]: 500 });
      this.updateQueryString({ [this.pageParameter]: 1 });

      ExTeal.request()
        .get(`/api/${this.resourceName}`, {
          params: this.resourceRequestQueryString
        })
        .then(({ data }) => {
          this.resources = [];

          this.resources = data.data;

          this.loading = false;
          let index = _.findIndex(this.resources[0].fields, {
            attribute: this.sortableBy
          });

          this.resourcesToSort = _.sortBy(this.resources, resource => {
            return resource.fields[index].value;
          });

          this.isSorting = true;
        });
    },

    /*
     * Update the resource selection status
     */
    updateSelectionStatus(resource) {
      if (!_(this.selectedResources).includes(resource))
        return this.selectedResources.push(resource);
      const index = this.selectedResources.indexOf(resource);
      if (index > -1) return this.selectedResources.splice(index, 1);
    },

    saveSorting() {
      this.updateQueryString({
        [this.perPageParameter]: this.perPageBeforeSort
      });
      this.updateQueryString({ [this.pageParameter]: this.pageBeforeSort });
      let data = _.map(this.resourcesToSort, record => {
        let field = _.find(record.fields, { attribute: this.sortableBy });
        return {
          id: record.id,
          attributes: {
            [this.sortableBy]: field.value
          }
        };
      });
      this.loading = true;
      ExTeal.request()
        .put(`/api/${this.resourceName}/reorder`, { data: data })
        .then(() => {
          this.isSorting = false;
          this.$toasted.show(`The ${this.meta.label} were reordered`, {
            type: "success"
          });
          this.loading = false;

          this.getResources();
        });
    },

    cancelSorting() {
      this.isSorting = false;
      if (this.resources !== this.getResources) {
        this.getResources();
      }
    },

    /**
     * Clear the selected resouces and the "select all" states.
     */
    clearResourceSelections() {
      this.selectAllMatchingResources = false;
      this.selectedResources = [];
    },

    /**
     * Select all of the available resources
     */
    selectAllResources() {
      this.selectedResources = this.resources.slice(0);
    },

    /**
     * Toggle the selection of all resources
     */
    toggleSelectAll() {
      if (this.selectAllChecked) {
        return this.clearResourceSelections();
      }
      this.selectAllResources();
    },

    /**
     * Toggle the selection of all matching resources in the database
     */
    toggleSelectAllMatching() {
      console.log(this.selectAllMatchingResources);
      if (!this.selectAllMatchingResources) {
        this.selectAllResources();
        this.selectAllMatchingResources = true;
        return;
      }

      this.selectAllMatchingResources = false;
    }
  }
};
</script>
