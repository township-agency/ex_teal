<template>
  <loading-view :loading="loading">
    <div class="card-headline">
      <heading class="mb-3">New {{ singularName }}</heading>
      <!-- Create Button -->
      <div class="flex ml-auto">
        <button
          dusk="create-and-add-another-button"
          type="button"
          class="ml-auto btn btn-default btn-secondary mr-3"
          @click="createAndAddAnother">
          Create &amp; Add Another
        </button>

        <button
          dusk="create-button"
          class="btn btn-default btn-primary"
          @click="createResource"
        >
          Create {{ singularName }}
        </button>
      </div>
    </div>

    <card class="overflow-hidden">
      <form
        v-if="fields"
        @submit.prevent="createResource">
        <!-- Validation Errors -->
        <validation-errors :errors="validationErrors"/>
        <!-- Fields -->
        <div
          v-for="field in fields"
          :key="field.attribute">
          <component
            :is="'form-' + field.component"
            :errors="validationErrors"
            :resource-name="resourceName"
            :field="field"
            :via-resource="viaResource"
            :via-resource-id="viaResourceId"
            :via-relationship="viaRelationship"
          />
        </div>


      </form>
    </card>
  </loading-view>
</template>

<script>
import _ from "lodash";
import { Errors, InteractsWithResourceInformation, Capitalize } from "@/mixins";

export default {
  mixins: [InteractsWithResourceInformation],

  props: {
    resourceName: {
      type: String,
      required: true
    },
    viaResource: {
      default: "",
      type: String
    },
    viaResourceId: {
      default: null,
      type: Number
    },
    viaRelationship: {
      default: "",
      type: String
    }
  },

  data: () => ({
    loading: true,
    fields: [],
    validationErrors: new Errors()
  }),

  computed: {
    singularName() {
      return Capitalize(this.resourceInformation.singular);
    }
  },

  created() {
    this.getFields();
  },

  methods: {
    /**
     * Get the available fields for the resource.
     */
    async getFields() {
      this.fields = [];

      const {
        data: { fields }
      } = await ExTeal.request().get(`/api/${this.resourceName}/creation-fields`);

      this.fields = fields;
      this.loading = false;
    },

    /**
     * Create a new resource instance using the provided data.
     */
    async createResource() {
      try {
        const response = await this.createRequest();

        this.$toasted.show(
          `The ${this.resourceInformation.singular} was created`,
          { type: "success" }
        );

        let idField = _.find(response.data.fields, { attribute: "id" });
        this.$router.push({
          name: "detail",
          params: {
            resourceName: this.resourceName,
            resourceId: idField.value
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
    async createAndAddAnother() {
      try {
        await this.createRequest();

        this.$toasted.show(
          `The ${this.resourceInformation.singular} was created`,
          { type: "success" }
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
    createRequest() {
      return ExTeal.request().post(
        `/api/${this.resourceName}`,
        this.createResourceFormData()
      );
    },

    /**
     * Create the form data for creating the resource.
     */
    createResourceFormData() {
      let data = _.tap({}, formData => {
        _.each(this.fields, field => {
          field.fill(formData);
        });
      });
      return { data };
    }
  }
};
</script>
