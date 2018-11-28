<template>
  <div v-if="!loading">
    <div class="card-headline">
      <heading class="">Editing {{ pageKey }}</heading>
      <div class="flex ml-auto">
        <button
          dusk="update-button"
          class="ml-auto btn btn-default btn-secondary mr-3"
          @click="updateResource"
        >
          Save &amp; Close
        </button>

        <button
          type="button"
          dusk="update-and-continue-editing-button"
          class="btn btn-default btn-primary capitalize"
          @click="updateAndContinueEditing">
          Save {{ pageKey }}
        </button>
      </div>
    </div>

    <card class="overflow-hidden">
      <form
        v-if="fields"
        @submit.prevent="updateResource">
        <!-- Validation Errors -->
        <validation-errors :errors="validationErrors" />

        <!-- Fields -->
        <div
          v-for="field in fields"
          :key="field.attribute">
          <component
            :is="'form-' + field.component"
            :errors="validationErrors"
            :resource-id="pageKey"
            :resource-name="pageKey"
            :field="field"
          />
        </div>
      </form>
    </card>
  </div>
</template>

<script>
import _ from "lodash";
import { Errors } from "@/mixins";
import Heading from "@/components/Heading";

export default {
  components: { Heading },
  props: {
    pageKey: {
      type: String,
      required: true
    }
  },

  data: () => ({
    loading: true,
    fields: [],
    validationErrors: new Errors(),
    lastRetrievedAt: null
  }),

  computed: {
    /**
     * Create the form data for creating the resource.
     */
    updateResourceFormData() {
      let data = _.tap({}, formData => {
        _(this.fields).each(field => {
          field.fill(formData);
        });

        // formData.append("_method", "PUT");
        // formData.append("_retrieved_at", this.lastRetrievedAt);
      });
      return { data };
    }
  },

  created() {
    this.getFields();

    this.updateLastRetrievedAtTimestamp();
  },

  methods: {
    /**
     * Get the available fields for the resource.
     */
    async getFields() {
      this.loading = true;

      this.fields = [];

      const {
        data: { fields }
      } = await ExTeal.request()
        .get(`/plugins/pages/${this.pageKey}/update-fields`)
        .catch(error => {
          if (error.response.status == 404) {
            this.$router.push({ name: "404" });
            return;
          }
        });

      this.fields = fields;

      this.loading = false;
    },

    /**
     * Update the resource using the provided data.
     */
    async updateResource() {
      try {
        await this.updateRequest();

        this.$toasted.show(`The ${this.pageKey} was updated`, {
          type: "success"
        });

        this.$router.push({
          name: "page_detail",
          params: {
            pageKey: this.pageKey
          }
        });
      } catch (error) {
        if (error.response.status == 422) {
          this.validationErrors = new Errors(error.response.data.errors);
        }

        if (error.response.status == 409) {
          this.$toasted.show(
            "Another user has updated this resource since this page was loaded. Please refresh the page and try again.",
            { type: "error" }
          );
        }
      }
    },

    /**
     * Update the resource and reset the form
     */
    async updateAndContinueEditing() {
      try {
        await this.updateRequest();

        this.$toasted.show(`The ${this.pageKey} was updated!`, {
          type: "success"
        });

        // Reset the form by refetching the fields
        this.getFields();
        this.updateLastRetrievedAtTimestamp();
      } catch (error) {
        console.log(error);
        if (error.response.status == 422) {
          this.validationErrors = new Errors(error.response.data.errors);
        }

        if (error.response.status == 409) {
          this.$toasted.show(
            this.__(
              "Another user has updated this resource since this page was loaded. Please refresh the page and try again."
            ),
            { type: "error" }
          );
        }
      }
    },

    /**
     * Send an update request for this resource
     */
    updateRequest() {
      return ExTeal.request().put(
        `/plugins/pages/${this.pageKey}`,
        this.updateResourceFormData
      );
    },

    /**
     * Update the last retrieved at timestamp to the current UNIX timestamp.
     */
    updateLastRetrievedAtTimestamp() {
      this.lastRetrievedAt = Math.floor(new Date().getTime() / 1000);
    }
  }
};
</script>
