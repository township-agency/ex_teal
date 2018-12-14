<template>
  <tr :class="{ checked }">
    <!-- Resource Selection Checkbox -->
    <td
      v-if="!isSorting"
      :class="{
        'w-16': shouldShowCheckBoxes || isSorting,
        'w-8': !shouldShowCheckBoxes
      }"
    >
      <checkbox
        v-if="shouldShowCheckBoxes"
        :checked="checked"
        @input="toggleSelection"
      />
    </td>
    <!-- Sort Handle -->
    <td v-if="isSorting" class="td-fit align-center">
      <icon
        type="drag"
        view-box="0 0 24 24"
        width="30"
        height="30"
        class="drag-handle pt-3"
      />
    </td>

    <!-- Fields -->
    <td v-for="field in resource.fields" :key="field.name">
      <component
        :is="'index-' + field.component"
        :class="`text-${field.text_align}`"
        :resource-name="resourceName"
        :field="field"
      />
    </td>
    <td v-if="isSorting" class="td-fit text-right pr-6" />
    <td v-else class="td-fit text-right pr-6 table-actions">
      <div class="flex">
        <span class="table-action">
          <router-link
            :to="{
              name: 'detail',
              params: {
                resourceName: resourceName,
                resourceId: resourceId
              }
            }"
            title="Show"
            class="table-action-link primary"
          >
            <icon
              type="view"
              width="18.85"
              height="16.25"
              view-box="0 0 18.85 16.25"
            />
          </router-link>
        </span>
        <span class="table-action">
          <router-link
            :to="{
              name: 'edit',
              params: {
                resourceName: resourceName,
                resourceId: resourceId
              }
            }"
            title="Edit"
            class="table-action-link primary"
          >
            <icon type="edit" />
          </router-link>
        </span>
        <span class="table-action">
          <button
            class="appearance-none cursor-pointer table-action-link danger"
            title="Delete"
            @click.prevent="openDeleteModal"
          >
            <icon type="delete" />
          </button>
        </span>
        <portal to="modals">
          <transition name="fade">
            <delete-resource-modal
              v-if="deleteModalOpen"
              mode="delete"
              @confirm="confirmDelete"
              @close="closeDeleteModal"
            >
              <div slot-scope="{ uppercaseMode, mode }" class="p-8">
                <heading :level="2" class="mb-6"
                  >{{ uppercaseMode }} Resource</heading
                >
                <p class="text-80 leading-normal">
                  Are you sure you want to delete this resource?
                </p>
              </div>
            </delete-resource-modal>
          </transition>
        </portal>
      </div>
    </td>
  </tr>
</template>

<script>
import { Deleteable } from "@/mixins";
export default {
  mixins: [Deleteable],
  props: {
    deleteResource: {
      type: Function,
      required: true
    },
    resource: {
      type: Object,
      required: true
    },
    resourceName: {
      type: String,
      required: true
    },
    relationshipType: {
      type: String,
      default: null
    },
    viaRelationship: {
      type: String,
      default: null
    },
    viaResource: {
      type: String,
      default: null
    },
    viaResourceId: {
      type: String,
      default: null
    },
    viaManyToMany: {
      type: Boolean,
      default: false
    },
    checked: {
      type: Boolean,
      default: false
    },
    actionsAreAvailable: {
      type: Boolean,
      default: false
    },
    shouldShowCheckBoxes: {
      type: Boolean,
      default: false
    },
    updateSelectionStatus: {
      type: Function,
      required: true
    },
    isSorting: {
      type: Boolean,
      default: false
    }
  },

  data: () => ({
    deleteModalOpen: false
  }),

  computed: {
    resourceId() {
      return this.resource.id;
    }
  },

  methods: {
    /**
     * Select the resource in the parent component
     */
    toggleSelection() {
      this.updateSelectionStatus(this.resource);
    },

    openDeleteModal() {
      this.deleteModalOpen = true;
    },

    confirmDelete() {
      this.deleteResource(this.resource);
      this.closeDeleteModal();
    },

    closeDeleteModal() {
      this.deleteModalOpen = false;
    }
  }
};
</script>
