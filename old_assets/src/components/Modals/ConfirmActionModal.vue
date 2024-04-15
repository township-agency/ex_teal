<template>
  <modal
    tabindex="-1"
    role="dialog"
    @modal-close="handleClose"
  >
    <form
      :class="{
        'w-action-fields': selectedAction.fields.length > 0,
        'w-action': selectedAction.fields.length == 0
      }"
      autocomplete="off"
      class="bg-white rounded-lg shadow-lg overflow-hidden"
      @keydown="handleKeydown"
      @submit.prevent.stop="handleConfirm"
    >
      <div>
        <heading
          :level="2"
          class="pt-8 px-8"
        >
          {{
            selectedAction.title
          }}
        </heading>

        <p
          v-if="selectedAction.fields.length == 0"
          class="text-gray-darker px-8 my-8"
        >
          Are you sure you want to run this action?
        </p>

        <div v-else>
          <validation-errors :errors="errors" />

          <!-- Action Fields -->
          <div
            v-for="field in selectedAction.fields"
            :key="field.attribute"
            class="action"
          >
            <component
              :is="'form-' + field.component"
              :errors="errors"
              :resource-name="resourceName"
              :field="field"
            />
          </div>
        </div>
      </div>

      <div class="bg-gray-lighter px-6 py-3 flex">
        <div class="flex items-center ml-auto">
          <button
            dusk="cancel-action-button"
            type="button"
            class="btn text-gray-darker font-normal h-9 px-3 mr-3 btn-link"
            @click.prevent="handleClose"
          >
            Cancel
          </button>

          <button
            :disabled="working"
            :class="{
              'btn-primary': !selectedAction.destructive,
              'btn-danger': selectedAction.destructive
            }"
            type="submit"
            class="btn btn-default"
          >
            <loader
              v-if="working"
              width="30"
            />
            <span v-else>Run Action</span>
          </button>
        </div>
      </div>
    </form>
  </modal>
</template>

<script>
export default {
  props: {
    working: {
      type: Boolean,
      default: false
    },
    resourceName: {
      type: String,
      required: true
    },
    selectedAction: {
      type: Object,
      required: true
    },
    errors: {
      type: Object,
      required: true
    }
  },

  /**
   * Mount the component.
   */
  mounted () {
    // If the modal has inputs, let's highlight the first one, otherwise
    // let's highlight the submit button
    if (document.querySelectorAll('.modal input').length) {
      document.querySelectorAll('.modal input')[0].focus();
    } else {
      document.querySelectorAll('.modal button[type=submit]')[0].focus();
    }
  },

  methods: {
    /**
     * Stop propogation of input events unless it's for an escape or enter keypress
     */
    handleKeydown (e) {
      if ([ 'Escape', 'Enter' ].indexOf(e.key) !== -1) {
        return;
      }

      e.stopPropagation();
    },

    /**
     * Execute the selected action.
     */
    handleConfirm () {
      this.$emit('confirm');
    },

    /**
     * Close the modal.
     */
    handleClose () {
      this.$emit('close');
    }
  }
};
</script>
