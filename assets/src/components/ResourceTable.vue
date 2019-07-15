<template>
  <table
    v-if="resources.length > 0"
    class="table w-full"
    cellpadding="0"
    cellspacing="0"
  >
    <thead>
      <tr>
        <!-- Select Checkbox -->
        <th
          :class="{
            'w-16': shouldShowCheckBoxes || isSorting,
            'w-8': !shouldShowCheckBoxes
          }"
        >
          <div v-if="shouldShowCheckBoxes">
            <!-- Select All -->
            <dropdown>
              <dropdown-trigger
                slot-scope="{ toggle }"
                :handle-click="toggle"
              >
                <fake-checkbox :checked="selectAllChecked" />
              </dropdown-trigger>

              <dropdown-menu
                slot="menu"
                width="250"
                override="table-check-menu"
              >
                <div class="p-4">
                  <ul class="list-reset">
                    <li class="flex items-center mb-4">
                      <checkbox-with-label
                        :checked="selectAllChecked"
                        @change="toggleSelectAll"
                      >
                        Select All
                      </checkbox-with-label>
                    </li>
                    <li class="flex items-center">
                      <checkbox-with-label
                        :checked="selectAllMatchingChecked"
                        @change="toggleSelectAllMatching"
                      >
                        <template>
                          <span class="mr-1"> Select All Matching </span>
                          <span>({{ allMatchingResourceCount }})</span>
                        </template>
                      </checkbox-with-label>
                    </li>
                  </ul>
                </div>
              </dropdown-menu>
            </dropdown>
          </div>
        </th>

        <!-- Field Names -->
        <th
          v-for="field in fields"
          :key="field.name"
          :class="`text-${field.text_align}`"
        >
          <sortable-icon
            v-if="showSortFor(field)"
            :resource-name="resourceName"
            :uri-key="field.attribute"
            @sort="requestOrderByChange(field)"
          >
            {{ field.name }}
          </sortable-icon>

          <span v-else> {{ field.name }} </span>
        </th>

        <th>actions</th>
      </tr>
    </thead>
    <tbody v-if="!isSorting">
      <tr
        is="resource-table-row"
        v-for="resource in resources"
        :key="resource.id"
        :fields="fields"
        :delete-resource="deleteResource"
        :resource="resource"
        :resource-name="resourceName"
        :should-show-check-boxes="shouldShowCheckBoxes"
        :update-selection-status="updateSelectionStatus"
        :via-relationship="viaRelationship"
        :via-resource="viaResource"
        :via-resource-id="viaResourceId"
        :via-many-to-many="viaManyToMany"
        :is-sorting="isSorting"
        :checked="selectedResources.indexOf(resource) > -1"
      />
    </tbody>
    <draggable
      v-else
      :list="sortableResources"
      v-bind="getDraggableOptions()"
      tag="tbody"
      @start="dragging"
      @end="reordered"
    >
      <tr
        is="resource-table-row"
        v-for="resource in sortableResources"
        :key="resource.id"
        :fields="fields"
        :delete-resource="deleteResource"
        :resource="resource"
        :resource-name="resourceName"
        :via-relationship="viaRelationship"
        :via-resource="viaResource"
        :via-resource-id="viaResourceId"
        :via-many-to-many="viaManyToMany"
        :should-show-check-boxes="false"
        :update-selection-status="updateSelectionStatus"
        :is-sorting="isSorting"
      />
    </draggable>
  </table>
</template>

<script>
import draggable from 'vuedraggable';
import { InteractsWithResourceInformation } from 'ex-teal-js';
import map from 'lodash/map';
export default {
  components: {
    draggable
  },

  mixins: [ InteractsWithResourceInformation ],

  props: {
    resourceName: {
      type: String,
      default: null
    },
    resources: {
      type: Array,
      default () {
        return [];
      }
    },
    fields: {
      type: Array,
      default () {
        return [];
      }
    },
    shouldShowCheckBoxes: {
      type: Boolean,
      default: false
    },
    selectedResources: {
      type: Array,
      default () {
        return [];
      }
    },
    updateSelectionStatus: {
      type: Function,
      required: true
    },
    updateAllMatchingChecked: {
      type: Boolean,
      default: false
    },
    toggleSelectAll: {
      type: Function,
      required: true
    },
    toggleSelectAllMatching: {
      type: Function,
      required: true
    },
    isSorting: {
      type: Boolean,
      default: false
    },
    sortableBy: {
      type: String,
      default: ''
    },
    resourcesToSort: {
      type: Array,
      default () {
        return [];
      }
    },
    allMatchingResourceCount: {
      type: Number,
      required: true
    },
    selectAllMatchingChecked: {
      type: Boolean,
      default: false
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
      default: null
    }
  },

  computed: {
    sortableResources () {
      if (this.isSorting) {
        return this.resourcesToSort;
      }
      return this.resources;
    },

    selectAllChecked () {
      return this.selectedResources.length == this.resources.length;
    },

    viaManyToMany () {
      return this.relationshipType == 'ManyToMany';
    }
  },

  methods: {
    getDraggableOptions () {
      return {
        disabled: !this.isSorting,
        sort: true
      };
    },

    /**
     * Delete the given resource.
     */
    deleteResource (resource) {
      this.$emit('delete', [ resource ]);
    },

    /**
     * Broadcast that the ordering should be updated.
     */
    requestOrderByChange (field) {
      if (this.isSorting && field.attribute == this.sortableBy) {
        return;
      }
      this.$emit('order', field);
    },

    dragging () {

    },

    reordered () {
      const resources = map(this.sortableResources, (item, i) => {
        item.fields = map(item.fields, field => {
          if (field.attribute !== this.sortableBy) {
            return field;
          }
          field.value = i + 1;
          return field;
        });
        return item;
      });
      this.$emit('update:resourcesForSorting', resources);
      this.$emit('changed');
    },

    showSortFor (field) {
      if (this.isSorting) {
        return field.attribute == this.sortableBy;
      }
      return field.sortable;
    }
  }
};
</script>
