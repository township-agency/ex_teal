<template>
  <modal @modal-close="handleClose">
    <form
      class="bg-white rounded-lg shadow-lg overflow-hidden"
      style="width: 460px"
      @submit.prevent="handleConfirm"
    >
      <slot
        :uppercaseMode="uppercaseMode"
        :mode="mode"
      >
        <div class="p-8">
          <heading
            :level="2"
            class="mb-6"
          >
            {{ uppercaseMode }} Resource
          </heading>
          <p class="text-gray-darker leading-normal">
            Are you sure you want to {{ mode }} the selected resources?
          </p>
        </div>
      </slot>

      <div class="bg-gray-lightest px-6 py-3 flex">
        <div class="ml-auto">
          <button
            type="button"
            class="btn text-gray-darker font-normal h-9 px-3 mr-3 btn-link"
            @click.prevent="handleClose"
          >
            Cancel
          </button>
          <button
            ref="confirmButton"
            type="submit"
            class="btn btn-default btn-danger"
          >
            {{ uppercaseMode }}
          </button>
        </div>
      </div>
    </form>
  </modal>
</template>

<script>
import startCase from 'lodash/startCase';

export default {
  props: {
    mode: {
      type: String,
      default: 'delete',
      validator: function (value) {
        return [ 'force delete', 'delete', 'detach' ].indexOf(value) !== -1;
      }
    }
  },

  computed: {
    uppercaseMode () {
      return startCase(this.mode);
    }
  },

  /**
   * Mount the component.
   */
  mounted () {
    this.$refs.confirmButton.focus();
  },

  methods: {
    handleClose () {
      this.$emit('close');
    },

    handleConfirm () {
      this.$emit('confirm');
    }
  }
};
</script>
