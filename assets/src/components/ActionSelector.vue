<template>
  <div>
    <dropdown
      v-if="actions.length > 0"
      class="bg-white border rounded"
    >
      <dropdown-trigger
        slot-scope="{ toggle }"
        :handle-click="toggle"
        class="px-3"
      >
        <icon
          type="action"
          class="text-grey-darker"
          view-box="0 0 16 16"
        />
        <span class="text-grey-darker text-sm ml-2">Actions</span>
      </dropdown-trigger>

      <dropdown-menu
        slot="menu"
        :dark="true"
        width="270"
        direction="rtl"
      >
        <ul class="list-reset px-2 py-1">
          <li
            v-for="action in actions"
            :key="action.key"
          >
            <a @click="selectAction(action)"> {{ action.title }} </a>
          </li>
        </ul>
      </dropdown-menu>
    </dropdown>

    <transition name="fade">
      <confirm-action-modal
        v-if="confirmActionModalOpened"
        :working="working"
        :resource-name="resourceName"
        :selected-action="selectedAction"
        :errors="errors"
        @confirm="executeAction"
        @close="confirmActionModalOpened = false"
      />
    </transition>
  </div>
</template>

<script>
import each from 'lodash/each';
import tap from 'lodash/tap';
import { Errors, InteractsWithResourceInformation } from 'ex-teal-js';

export default {
  mixins: [ InteractsWithResourceInformation ],

  props: {
    selectedResources: {
      type: [ Array, String ],
      default: () => []
    },
    resourceName: {
      type: String,
      required: true
    },
    actions: {
      type: Array,
      default: () => []
    },
    queryString: {
      type: Object,
      default: () => ({
        currentSearch: '',
        encodedFilters: '',
        viaResource: '',
        viaResourceId: '',
        viaRelationship: ''
      })
    }
  },

  data: () => ({
    working: false,
    errors: new Errors(),
    selectedActionKey: '',
    confirmActionModalOpened: false
  }),

  computed: {
    selectedAction () {
      if (this.selectedActionKey) {
        return this.actions.find(a => a.key == this.selectedActionKey);
      }
      return false;
    },

    /**
     * Get the query string for an action request.
     */
    actionRequestQueryString () {
      return {
        action: this.selectedActionKey,
        search: this.queryString.currentSearch,
        filters: this.queryString.encodedFilters,
        viaResource: this.queryString.viaResource,
        viaResourceId: this.queryString.viaResourceId,
        viaRelationship: this.queryString.viaRelationship
      };
    },

    /**
     * Get all of the available non-pivot actions for the resource.
     */
    availableActions () {
      return this.actions.filter((action) => {
        if (this.selectedResources != 'all') {
          return true;
        }

        return action.options.availableForEntireResource;
      });
    }
  },

  watch: {
    /**
     * Watch the actions property for changes.
     */
    actions () {
      this.selectedActionKey = '';
      this.initializeActionFields();
    }
  },

  methods: {
    selectAction (action) {
      this.selectedActionKey = action.key;
      this.openConfirmationModal();
    },
    /**
     * Confirm with the user that they actually want to run the selected action.
     */
    openConfirmationModal () {
      this.confirmActionModalOpened = true;
    },

    /**
     * Close the action confirmation modal.
     */
    closeConfirmationModal () {
      this.confirmActionModalOpened = false;
    },

    /**
     * Initialize all of the action fields to empty strings.
     */
    initializeActionFields () {
      this.actions.forEach(action => {
        action.fields.forEach(field => {
          field.fill = () => '';
        });
      });
    },

    /**
     * Execute the selected action.
     */
    executeAction () {
      this.working = true;

      if (this.selectedResources.length == 0) {
        alert('Please select a resource to perform this action on.');
        return;
      }

      ExTeal.request({
        method: 'post',
        url: `/api/${this.resourceName}/actions`,
        params: this.actionRequestQueryString,
        data: this.actionFormData()
      })
        .then(response => {
          this.confirmActionModalOpened = false;
          this.handleActionResponse(response.data);
          this.working = false;
        })
        .catch(error => {
          this.working = false;

          if (error.response.status == 422) {
            this.errors = new Errors(error.response.data.errors);
          }
        });
    },

    /**
     * Gather the action FormData for the given action.
     */
    actionFormData () {
      return tap(new FormData(), formData => {
        formData.append('resources', this.selectedResources);

        each(this.selectedAction.fields, field => {
          field.fill(formData);
        });
      });
    },

    /**
     * Handle the action response. Typically either a message, download or a redirect.
     */
    handleActionResponse (response) {
      if (response.message) {
        this.$emit('actionExecuted');
        this.$toasted.show(response.message, { type: 'success' });
      } else if (response.deleted) {
        this.$emit('actionExecuted');
      } else if (response.error) {
        this.$emit('actionExecuted');
        this.$toasted.show(response.error, { type: 'error' });
      } else if (response.redirect) {
        window.location = response.redirect;
      } else {
        this.$emit('actionExecuted');
        this.$toasted.show('The action ran successfully!', {
          type: 'success'
        });
      }
    }
  }
};
</script>
