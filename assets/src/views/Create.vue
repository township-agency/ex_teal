<template>
  <loading-view :loading="loading">
    <div class="card-headline">
      <heading class="mb-3">
        New {{ singularName }}
      </heading>
      <!-- Create Button -->
      <div class="flex ml-auto">
        <button
          type="button"
          class="ml-auto btn btn-default btn-secondary mr-3"
          @click="createAndAddAnother"
        >
          Create &amp; Add Another
        </button>

        <button
          class="btn btn-default btn-primary"
          @click="createResource"
        >
          Create {{ singularName }}
        </button>
      </div>
    </div>

    <form
      v-if="panels"
      autocomplete="off"
      @submit.prevent="createResource"
    >
      <validation-errors :errors="validationErrors" />

      <form-panel
        v-for="(panel, index) in panelsWithFields"
        :key="panel.name"
        class="mb-6"
        :index="index"
        :panel="panel"
        :name="panel.name"
        :fields="panel.fields"
        :validation-errors="validationErrors"
        :via-resource="viaResource"
        :via-resource-id="viaResourceId"
        :via-relationship="viaRelationship"
        :resource-name="resourceName"
      />
      <!-- Validation Errors -->
      <!-- Fields -->
    </form>
  </loading-view>
</template>

<script>
import _ from 'lodash';
import {
  InteractsWithResourceInformation
} from '@/mixins';
import { Errors } from '@/util/errors';
import { Capitalize } from '@/util/capitalize';


export default {
  mixins: [ InteractsWithResourceInformation ],

  props: {
    resourceName: {
      type: String,
      required: true
    },
    viaResource: {
      default: '',
      type: String
    },
    viaResourceId: {
      default: null,
      type: Number
    },
    viaRelationship: {
      default: '',
      type: String
    }
  },

  data: () => ({
    loading: true,
    fields: [],
    panels: [],
    validationErrors: new Errors()
  }),

  computed: {
    singularName () {
      return Capitalize(this.resourceInformation.singular);
    },

    panelsWithFields () {
      return _.map(this.panels, panel => {
        return {
          ...panel,
          fields: _.filter(this.fields, field => {
            return field.panel === panel.key;
          })
        };
      });
    }
  },

  created () {
    this.getFields();
  },

  methods: {
    /**
     * Get the available fields for the resource.
     */
    async getFields () {
      this.fields = [];

      const {
        data: { fields, panels }
      } = await ExTeal.request().get(
        `/api/${this.resourceName}/creation-fields`
      );

      this.fields = fields;
      this.panels = panels;
      this.loading = false;
    },

    /**
     * Create a new resource instance using the provided data.
     */
    async createResource () {
      try {
        const response = await this.createRequest();

        this.$toasted.show(
          `The ${this.resourceInformation.singular} was created`,
          { type: 'success' }
        );
        const id = response.data.id;
        this.$router.push({
          name: 'detail',
          params: {
            resourceName: this.resourceName,
            resourceId: id
          }
        });
      } catch (error) {
        if (error.response.status == 422) {
          this.validationErrors = new Errors(error.response.data.errors);
        }
      }
    },

    /**
     * Create a new resource and reset the form
     */
    async createAndAddAnother () {
      try {
        await this.createRequest();

        this.$toasted.show(
          `The ${this.resourceInformation.singular} was created`,
          { type: 'success' }
        );

        // Reset the form by refetching the fields
        this.getFields();

        this.validationErrors = new Errors();
      } catch (error) {
        if (error.response.status == 422) {
          this.validationErrors = new Errors(error.response.data.errors);
        }
      }
    },

    /**
     * Send a create request for this resource
     */
    createRequest () {
      return ExTeal.request().post(
        `/api/${this.resourceName}`,
        this.createResourceFormData()
      );
    },

    /**
     * Create the form data for creating the resource.
     */
    createResourceFormData () {
      return _.tap(new FormData(), formData => {
        _.each(this.fields, field => {
          field.fill(formData);
        });
      });
    }
  }
};
</script>
