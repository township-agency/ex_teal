<template>
  <loading-view :loading="initialLoading">
    <div v-if="shouldShowCards">
      <cards
        v-if="smallCards.length > 0"
        :cards="smallCards"
        class="mb-3"
        :resource-name="resourceName"
      />

      <cards
        v-if="largeCards.length > 0"
        :cards="largeCards"
        size="large"
        :resource-name="resourceName"
      />
    </div>
    <div class="card-headline">
      <heading
        v-if="meta.label"
        :level="1"
      >
        {{ meta.label }}
        <span
          v-if="resourceCountLabel"
          class="text-sm text-grey ml-2 inline-block"
        >
          Viewing {{ resourceCountLabel }}
        </span>
      </heading>
    </div>
    <div
      class="flex justify-between ml-auto items-center border-t border-r border-l rounded-t"
    >
      <!-- Search -->
      <div
        v-if="resourceInformation.searchable && !viaHasOne"
        class="relative flex-1 border-r"
      >
        <icon
          type="search"
          class="absolute ml-2 mt-2 text-grey"
        />

        <input
          v-model="search"
          placeholder="Search"
          class="appearance-none form-control form-input search rounded-tl w-full"
          type="search"
          @keydown.stop="performSearch"
          @search="performSearch"
        >
      </div>
      <div v-else />
      <div class="flex items-center justify-end">
        <div v-if="shouldShowReorder && !viaHasOne">
          <button
            class="border-l border-r hover:bg-grey-light px-2 h-8"
            @click="showSort"
          >
            <icon
              type="reorder"
              class="text-grey-darker"
            />
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

        <button
          v-if="shouldShowFilters"
          class="border-r hover:bg-grey-light px-2 h-8 flex items-center"
          @click="toggleFilters"
        >
          <icon
            type="filter"
            class="text-grey-darker"
          />
        </button>

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
          :can-create="!resourceIsFull"
          :relationship-type="relationshipType"
          classes="rounded-tr border-none"
        />
      </div>
    </div>

    <div
      v-if="shouldShowReorder && isSorting"
      class="border-t border-r border-l p-2"
    >
      <button
        :disabled="loading"
        class="btn btn-default btn-primary"
        @click="saveSorting"
      >
        Save Changes
      </button>
      <button
        :disabled="loading"
        class="btn btn-default btn-secondary ml-4"
        @click="cancelSorting"
      >
        Cancel
      </button>
    </div>

    <div
      v-if="showFilters"
      class="border-t border-r border-l pr-2 pb-2 pl-2"
    >
      <div
        v-if="currentFieldFilters.length > 0"
        class="flex flex-wrap"
      >
        <field-filter
          v-for="(filter, index) in currentFieldFilters"
          :key="index"
          :index="index"
          :total-filters="currentFieldFilters.length"
          :filter="filter"
          :filters="fieldFilters"
          :resource-name="resourceName"
          @fieldFilterUpdated="updateFieldFilter"
          @delete="deleteFieldFilter"
        />
      </div>
      <button
        class="mt-2 btn btn-primary btn-sm"
        @click="addNewFilter"
      >
        <span>Add Filter</span>
      </button>
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
            <g
              id="Page-1"
              fill="none"
              fill-rule="evenodd"
            >
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
            No {{ resourceInformation.title.toLowerCase() }} matched the given criteria.

            <create-resource-button
              :singular-name="singularName"
              :resource-name="resourceName"
              :via-resource="viaResource"
              :via-resource-id="viaResourceId"
              :via-relationship="viaRelationship"
              :can-create="!resourceIsFull"
              :relationship-type="relationshipType"
              classes="mt-2"
              :with-text="true"
            />
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
          :sortable-by="sortableParameter"
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
          :relationship-type="relationshipType"
          :via-resource="viaResource"
          :via-resource-id="viaResourceId"
          :via-relationship="viaRelationship"
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
        :per-page="currentPerPage"
        @previous="selectPreviousPage"
        @perPageChanged="perPageChanged"
        @next="selectNextPage"
      />
    </loading-card>
  </loading-view>
</template>

<script>
import _ from 'lodash';
import {
  Capitalize,
  Deleteable,
  HasCards,
  InteractsWithQueryString,
  InteractsWithResourceInformation,
  Minimum,
  Paginatable,
  PerPageable
} from 'ex-teal-js';

import InteractsWithFieldFilters from '@/mixins/InteractsWithFieldFilters'; 

export default {
  mixins: [
    Deleteable,
    HasCards,
    InteractsWithResourceInformation,
    InteractsWithQueryString,
    InteractsWithFieldFilters,
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
      default: ''
    },
    viaResourceId: {
      type: Number,
      default: null
    },
    viaRelationship: {
      type: String,
      default: ''
    },
    relationshipType: {
      type: String,
      default: ''
    },
    relSortableBy: {
      type: String,
      default: ''
    }
  },

  data: () => ({
    initialLoading: true,
    loading: true,

    resourceResponse: null,
    resources: [],
    meta: {},
    deleteModalOpen: false,

    orderBy: '',
    orderByDirection: '',
    fieldFilters: [],
    currentFieldFilters: [],
    actions: [],
    showFilters: true,
    selectedResources: [],
    selectAllMatchingResources: false,
    allMatchingResourceCount: 0,

    isSorting: false,
    search: '',

    sortable: false,
    sortableBy: null,

    resourcesToSort: []
  }),

  computed: {
    /**
     * Get the singular name for the resource
     */
    singularName () {
      return Capitalize(this.resourceInformation.singular);
    },

    /**
     * Build the resource request query string.
     */
    resourceRequestQueryString () {
      return _.pickBy(
        {
          search: this.currentSearch,
          filters: this.encodedFilters,
          field_filters: this.encodedFieldFilters,
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
    orderByParameter () {
      return this.resourceName + '_order';
    },

    /**
     * Get the name of the order by direction query string variable.
     */
    orderByDirectionParameter () {
      return this.resourceName + '_direction';
    },

    /**
     * Get the name of the per page query string variable.
     */
    perPageParameter () {
      return this.resourceName + '_per_page';
    },

    /**
     * Get the name of the page query string variable.
     */
    pageParameter () {
      return this.resourceName + '_page';
    },

    /**
     * Get the name of the field filter query string variable.
     */
    fieldFilterParameter () {
      return this.resourceName + '_field_filter';
    },

    sortableParameter () {
      if (this.viaManyToMany) {
        return this.relSortableBy;
      }
      return this.sortableBy;
    },

    /**
     * Get the current order by value from the query string.
     */
    currentOrderBy () {
      return this.$route.query[this.orderByParameter] || '';
    },

    /**
     * Get the current order by direction from the query string.
     */
    currentOrderByDirection () {
      return this.$route.query[this.orderByDirectionParameter] || 'desc';
    },

    /**
     * Get the current search value from the query string.
     */
    currentSearch () {
      return this.$route.query[this.searchParameter] || '';
    },

    /**
     * Get the name of the search query string variable.
     */
    searchParameter () {
      return this.viaRelationship + '_search';
    },

    /**
     * Determine if there any filters for this resource
     */
    hasFilters () {
      return Boolean(this.fieldFilters.length > 0);
    },

    /**
     * Determine if there are any resources for the view
     */
    hasResources () {
      return Boolean(this.resources.length > 0);
    },

    shouldShowFilters () {
      return !this.isSorting && this.hasFilters;
    },

    shouldShowReorder () {
      return (this.sortable && this.sortableBy && !this.viaManyToMany) || (this.viaManyToMany && this.relSortableBy) || this.meta.sortable_by;
    },

    /**
     * Determine whether to show the toolbar for this resource index
     */
    shouldShowToolbar () {
      return Boolean(this.hasFilters || this.shouldShowReorder);
    },

    /**
     * Get the IDs for the selected resources.
     */
    selectedResourceIds () {
      return _.map(this.selectedResources, resource => resource.id);
    },

    /**
     * Get the selected resources for the action selector.
     */
    selectedResourcesForActionSelector () {
      return this.selectAllMatchingChecked ? 'all' : this.selectedResourceIds;
    },

    /**
     * Determine whether to show the selection checkboxes for resources
     */
    shouldShowCheckBoxes () {
      return Boolean(this.hasResources && !this.viaHasOne && !this.viaManyToMany);
    },

    /**
     * Determine if all matching resources are selected.
     */
    selectAllMatchingChecked () {
      return (
        this.selectedResources.length == this.resources.length &&
        this.selectAllMatchingResources
      );
    },

    /**
     * Determine if all resources are selected.
     */
    selectAllChecked () {
      return this.selectedResources.length == this.resources.length;
    },

    /**
     * Determine whether the delete menu should be shown to the user
     */
    shouldShowDeleteMenu () {
      return Boolean(this.selectedResources.length > 0);
    },

    /**
     * Determine if the resource / relationship is "full".
     */
    resourceIsFull () {
      return this.viaHasOne && this.resources.length > 0;
    },

    /**
     * Determine if the current resource listing is via a has-one relationship.
     */
    viaHasOne () {
      return this.relationshipType == 'hasOne';
    },

    /**
     * Determine if the current resource listing is via a many-to-many relationship.
     */
    viaManyToMany () {
      return this.relationshipType == 'ManyToMany';
    },

    resourceCountLabel () {
      const first = this.perPage * (this.currentPage - 1);

      return (
        this.resources.length &&
        `${first + 1}-${first + this.resources.length} of ${
          this.allMatchingResourceCount
        }`
      );
    },

    /**
     * Determine if the resource should show any cards
     */
    shouldShowCards () {
      // Don't show cards if this resource is beings shown via a relations
      return this.cards.length > 0 && this.resourceName == this.$route.params.resourceName;
    },

    /**
     * Get the endpoint for this resource's metrics.
     */
    cardsEndpoint () {
      return `/api/${this.resourceName}/cards`;
    },

    currentPerPage () {
      return parseInt(this.$route.query[this.perPageParameter]) || 25;
    }
  },

  /**
   * Mount the component and retrieve its initial data.
   */
  async created () {
    this.initializeSearchFromQueryString();
    this.initializeOrderingFromQueryString();
    this.initializePerPageFromQueryString();
    this.initializeFieldFilterValuesFromQueryString();

    await this.getResources();
    this.getFieldFilters();

    this.getActions();

    this.initialLoading = false;

    this.$watch(
      () => {
        return (
          this.resourceName +
          this.encodedFieldFilters +
          this.currentOrderBy +
          this.currentOrderByDirection +
          this.currentPage +
          this.currentSearch +
          this.currentPerPage
        );
      },
      () => {
        this.getResources();

        this.initializeOrderingFromQueryString();
        this.initializePerPageFromQueryString();
        this.initializeFieldFilterValuesFromQueryString();
      }
    );

    this.$watch(
      () => {
        return this.resourceName;
      },
      () => {
        this.getFieldFilters();
        this.getActions();
      }
    );
  },

  methods: {
    /**
     * Get the resources based on the current page, search, filters, etc.
     */
    getResources () {
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
          this.sortableBy = data.meta.sortable_by || '';

          this.loading = false;
        });
      });
    },

    getFieldFilters () {
      this.fieldFilters = [];

      return ExTeal.request()
        .get(`/api/${this.resourceName}/field-filters`)
        .then(response => {
          this.fieldFilters = response.data.filters;
        });
    },

    toggleFilters () {
      this.showFilters = !this.showFilters;
    },

    getActions () {
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
    orderByField (field) {
      let direction = this.currentOrderByDirection == 'asc' ? 'desc' : 'asc';
      if (this.currentOrderBy != field.attribute) {
        direction = 'asc';
      }
      this.updateQueryString({
        [this.orderByParameter]: field.attribute,
        [this.orderByDirectionParameter]: direction
      });
    },

    initializeSearchFromQueryString () {
      this.search = this.currentSearch;
    },

    /**
     * Sync the current order by values from the query string.
     */
    initializeOrderingFromQueryString () {
      this.orderBy = this.currentOrderBy;
      this.orderByDirection = this.currentOrderByDirection;
    },

    showSort () {
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
          const identifier = this.viaManyToMany ? this.relSortableBy : this.sortableBy;
          const index = _.findIndex(this.resources[0].fields, {
            attribute: identifier
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
    updateSelectionStatus (resource) {
      if (!_(this.selectedResources).includes(resource))
      {return this.selectedResources.push(resource);}
      const index = this.selectedResources.indexOf(resource);
      if (index > -1) {return this.selectedResources.splice(index, 1);}
    },

    saveSorting () {
      this.updateQueryString({
        [this.perPageParameter]: this.perPageBeforeSort
      });
      this.updateQueryString({ [this.pageParameter]: this.pageBeforeSort });

      if (this.viaManyToMany) {
        this.savePivotSort();
        return;
      }

      const data = _.map(this.resourcesToSort, record => {
        const field = _.find(record.fields, { attribute: this.sortableBy });
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
            type: 'success'
          });
          this.loading = false;

          this.getResources();
        });
    },

    savePivotSort () {
      const data = _.map(this.resourcesToSort, record => {
        const idField = _.find(record.fields, { attribute: this.viaRelationship });
        const sortField = _.find(record.fields, { attribute: this.relSortableBy });
        return {
          [idField.options.belongs_to_relationship]: idField.options.belongs_to_id,
          [this.relSortableBy]: sortField.value
        };
      });
      this.loading = true;
      ExTeal.request()
        .put(`/api/${this.viaResource}/${this.viaResourceId}/reorder/${this.resourceName}`, { data: data })
        .then(() => {
          this.isSorting = false;
          this.$toasted.show(`The ${this.meta.label} were reordered`, {
            type: 'success'
          });
          this.loading = false;

          this.getResources();
        });
    },

    cancelSorting () {
      this.isSorting = false;
      if (this.resources !== this.getResources) {
        this.getResources();
      }
    },

    /**
     * Clear the selected resouces and the "select all" states.
     */
    clearResourceSelections () {
      this.selectAllMatchingResources = false;
      this.selectedResources = [];
    },

    /**
     * Select all of the available resources
     */
    selectAllResources () {
      this.selectedResources = this.resources.slice(0);
    },

    /**
     * Toggle the selection of all resources
     */
    toggleSelectAll () {
      if (this.selectAllChecked) {
        return this.clearResourceSelections();
      }
      this.selectAllResources();
    },

    /**
     * Toggle the selection of all matching resources in the database
     */
    toggleSelectAllMatching () {
      if (!this.selectAllMatchingResources) {
        this.selectAllResources();
        this.selectAllMatchingResources = true;
        return;
      }

      this.selectAllMatchingResources = false;
    },

    /**
     * Execute a search against the resource.
     */
    performSearch (event) {
      this.debouncer(() => {
        // Only search if we're not tabbing into the field
        if (event.which != 9) {
          this.updateQueryString({
            [this.pageParameter]: 1,
            [this.searchParameter]: this.search,
          });
        }
      });
    },

    perPageChanged (value) {
      this.perPage = value;
      this.updateQueryString({ [this.perPageParameter]: this.perPage });
    },

    debouncer: _.debounce(callback => callback(), 500),
  }
};
</script>
