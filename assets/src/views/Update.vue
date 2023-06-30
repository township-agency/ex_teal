<template>
  <div v-if="!loading">
    <div class="card-headline">
      <Heading class="">
        Editing {{ singularName }}
      </Heading>
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
          @click="updateAndContinueEditing"
        >
          Save {{ singularName }}
        </button>
      </div>
    </div>

    <form
      v-if="fields"
      @submit.prevent="updateResource"
    >
      <!-- Validation Errors -->
      <validation-errors :errors="validationErrors" />
      <!-- Update Button -->

      <form-panel
        v-for="(panel, index) in panelsWithFields"
        :key="panel.name"
        class="mb-6"
        :index="index"
        :panel="panel"
        :name="panel.name"
        :fields="panel.fields"
        :validation-errors="validationErrors"
        :resource-name="resourceName"
      />
    </form>
  </div>
</template>

<script>
import _ from 'lodash';
import { InteractsWithResourceInformation } from '@/mixins';
import { Errors } from '@/util/errors';
import Heading from '@/components/Heading';

const flattenErrors = (obj, prefix = '') => {
  const result = {};
  for (const key in obj) {
    if (typeof obj[key] === 'string') {
      result[prefix + key] = obj[key];
    } else {
      const flatErrors = flattenErrors(obj[key], `${prefix}${key}[`);
      for (const flatKey in flatErrors) {
        result[flatKey + ']'] = flatErrors[flatKey];
      }
    }
  }
  return result;
};

export default {
  components: { Heading },
  mixins: [ InteractsWithResourceInformation ],

  props: {
    resourceName: {
      type: String,
      required: true
    },
    resourceId: {
      required: true,
      type: Number
    }
  },

  data: () => ({
    loading: true,
    fields: [],
    panels: [],
    validationErrors: new Errors(),
    lastRetrievedAt: null
  }),

  computed: {
    /**
     * Create the form data for creating the resource.
     */
    updateResourceFormData () {
      return _.tap(new FormData(), formData => {
        _(this.fields).each(field => {
          field.fill(formData);
        });

        formData.append('_method', 'PUT');
        formData.append('_retrieved_at', this.lastRetrievedAt);
      });
    },

    singularName () {
      return this.resourceInformation.singular;
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

    this.updateLastRetrievedAtTimestamp();
  },

  methods: {
    /**
     * Get the available fields for the resource.
     */
    async getFields () {
      this.loading = true;

      this.fields = [];

      const {
        data: { fields, panels }
      } = await ExTeal.request()
        .get(`/api/${this.resourceName}/${this.resourceId}/update-fields`)
        .catch(error => {
          if (error.response.status == 404) {
            this.$router.push({ name: '404' });
            return;
          }
        });

      this.fields = fields;
      this.panels = panels;
      this.loading = false;
    },

    /**
     * Update the resource using the provided data.
     */
    async updateResource () {
      try {
        await this.updateRequest();

        this.$toasted.show(
          `The ${this.resourceInformation.singular} was updated`,
          { type: 'success' }
        );

        this.$router.push({
          name: 'detail',
          params: {
            resourceName: this.resourceName,
            resourceId: this.resourceId
          }
        });
      } catch (error) {
        if (error.response.status == 422) {
          this.validationErrors = new Errors(error.response.data.errors);
        }

        if (error.response.status == 409) {
          this.$toasted.show(
            'Another user has updated this resource since this page was loaded. Please refresh the page and try again.',
            { type: 'error' }
          );
        }
      }
    },

    /**
     * Update the resource and reset the form
     */
    async updateAndContinueEditing () {
      try {
        await this.updateRequest();

        this.$toasted.show(
          `The ${this.resourceInformation.singular.toLowerCase()} was updated!`,
          { type: 'success' }
        );

        // Reset the form by refetching the fields
        this.getFields();
        this.validationErrors = new Errors();
        this.updateLastRetrievedAtTimestamp();
      } catch (error) {
        if (error.response.status == 422) {
          this.validationErrors = new Errors(error.response.data.errors);
        }

        if (error.response.status == 409) {
          this.$toasted.show(
            this.__(
              'Another user has updated this resource since this page was loaded. Please refresh the page and try again.'
            ),
            { type: 'error' }
          );
        }
      }
    },

    /**
     * Send an update request for this resource
     */
    updateRequest () {
      return ExTeal.request().put(
        `/api/${this.resourceName}/${this.resourceId}`,
        this.updateResourceFormData
      );
    },

    /**
     * Update the last retrieved at timestamp to the current UNIX timestamp.
     */
    updateLastRetrievedAtTimestamp () {
      this.lastRetrievedAt = Math.floor(new Date().getTime() / 1000);
    }
  }
};
</script>
