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
            'w-16': shouldShowCheckboxes || isSorting,
            'w-8': !shouldShowCheckboxes
          }"
        >
          &nbsp;
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

        <th>&nbsp;<!-- View, Edit, Delete --></th>
      </tr>
    </thead>
    <tbody v-if="!isSorting">
      <tr
        is="resource-table-row"
        v-for="resource in resources"
        :fields="fields"
        :key="resource.id"
        :delete-resource="deleteResource"
        :resource="resource"
        :resource-name="resourceName"
        :should-show-checkboxes="shouldShowCheckboxes"
        :is-sorting="isSorting"
      />
    </tbody>
    <draggable
      v-else
      :list="sortableResources"
      :options="draggableOptions"
      element="tbody"
      @end="reordered"
    >
      <tr
        is="resource-table-row"
        v-for="resource in sortableResources"
        :fields="fields"
        :key="resource.id"
        :delete-resource="deleteResource"
        :resource="resource"
        :resource-name="resourceName"
        :should-show-checkboxes="shouldShowCheckboxes"
        :is-sorting="isSorting"
      />
    </draggable>
  </table>
</template>

<script>
import draggable from "vuedraggable";
import { InteractsWithResourceInformation } from "@/mixins";
import map from "lodash/map";
export default {
  components: {
    draggable
  },

  mixins: [InteractsWithResourceInformation],

  props: {
    resourceName: {
      type: String,
      default: null
    },
    resources: {
      type: Array,
      default() {
        return [];
      }
    },
    fields: {
      type: Array,
      default() {
        return [];
      }
    },
    shouldShowCheckboxes: {
      type: Boolean,
      default: false
    },
    isSorting: {
      type: Boolean,
      default: false
    },
    sortableBy: {
      type: String,
      default: ""
    },
    resourcesToSort: {
      type: Array,
      default() {
        return [];
      }
    }
  },

  computed: {
    draggableOptions() {
      return {
        disabled: !this.isSorting,
        sort: true
      };
    },

    sortableResources() {
      if (this.isSorting) {
        return this.resourcesToSort;
      }
      return this.resources;
    }
  },

  methods: {
    /**
     * Delete the given resource.
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
    deleteRequest(resource) {
      return this.$teal
        .request()
        .delete(`/api/${this.resourceName}/${resource.id}`);
    },

    /**
     * Broadcast that the ordering should be updated.
     */
    requestOrderByChange(field) {
      if (this.isSorting && field.attribute == this.sortableBy) {
        return;
      }
      this.$emit("order", field);
    },

    reordered() {
      let resources = map(this.sortableResources, (item, i) => {
        item.fields = map(item.fields, field => {
          if (field.attribute !== this.sortableBy) {
            return field;
          }
          field.value = i + 1;
          return field;
        });
        return item;
      });
      this.$emit("update:resourcesForSorting", resources);
      this.$emit("changed");
    },

    showSortFor(field) {
      if (this.isSorting) {
        return field.attribute == this.sortableBy;
      }
      return field.sortable;
    }
  }
};
</script>
