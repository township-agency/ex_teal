<template>
  <loading-view :loading="loading">
    <div class="card-headline">
      <heading class="mb-3">
        Updating Attached {{ relatedResourceLabel }}
      </heading>

      <div class="flex ml-auto">
        <button
          type="button"
          class="ml-auto btn btn-default btn-secondary mr-3"
          @click="updateAndContinueEditing"
        >
          Update &amp; Continue Editing
        </button>

        <button
          class="btn btn-default btn-primary"
          @click="updateAttached"
        >
          Update {{ relatedResourceLabel }}
        </button>
      </div>
    </div>
    <card class="overflow-hidden">
      <form
        v-if="field"
        autocomplete="off"
        @submit.prevent="attachResource"
      >
        <!-- Related Resource -->
        <default-field
          :field="field"
          :errors="validationErrors"
        >
          <template>{{ relatedResourceLabel }}</template>
          <template slot="field">
            <select-control
              class="form-control form-select mb-3 w-full"
              :options="availableResources"
              :selected="selectedResourceId"
              disabled
              label="title"
              value-key="id"
              @change="selectResourceFromSelectControl"
            >
              <option
                value=""
                disabled
                selected="1"
              >
                Choose {{ relatedResourceLabel }}
              </option>
            </select-control>
          </template>
        </default-field>

        <!-- Pivot Fields -->
        <div
          v-for="field in fields"
          :key="field.attribute"
        >
          <component
            :is="'form-' + field.component"
            :resource-name="resourceName"
            :field="field"
            :errors="validationErrors"
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
import { Errors, PerformsSearches } from 'ex-teal-js';
import find from 'lodash/find';
import tap from 'lodash/tap';

export default {
  mixins: [ PerformsSearches ],
  props: {
    resourceName: {
      type: String,
      required: true,
    },
    resourceId: {
      type: Number,
      required: true
    },
    relatedResourceName: {
      type: String,
      required: true
    },
    relatedResourceId: {
      type: [ String, Number ],
      required: true
    },
    viaResource: {
      type: String,
      default: '',
    },
    viaResourceId: {
      type: String,
      default: '',
    },
    viaRelationship: {
      type: String,
      default: null
    }
  },

  data: () => ({
    loading: true,
    submittedViaUpdateAndContinueEditing: false,
    submittedViaUpdate: false,
    field: null,
    fields: [],
    validationErrors: new Errors(),
    selectedResource: null,
    selectedResourceId: null
  }),

  computed: {
    relatedResourceLabel () {
      if (this.field) {
        return this.field.options.singular;
      }
      return null;
    },
    attachmentFormData (){
      return tap(new FormData(), formData => {
        this.fields.forEach(field => {
          field.fill(formData);
        });
        if (!this.selectedResource) {
          formData.append(this.relatedResourceName, '');
        } else {
          formData.append(this.relatedResourceName, this.selectedResource.value);
        }
      });
    }
  },

  mounted () {
    this.initializeComponent();
  },

  methods: {
    async initializeComponent () {
      this.clearSelection();
      this.getField();

      await this.getPivotFields();
      await this.getAvailableResources();

      this.selectedResourceId = parseInt(this.relatedResourceId);
      this.selectInitialResource();
    },

    getField () {
      this.field = null;

      return ExTeal.request()
        .get(`/api/${this.resourceName}/field/${this.relatedResourceName}`)
        .then(({ data }) => {
          this.field = data.field;
          this.loading = false;
        });
    },

    getPivotFields () {
      this.fields = [];
      return ExTeal.request()
        .get(`/api/${this.resourceName}/${this.resourceId}/update-pivot-fields/${this.relatedResourceName}/${this.relatedResourceId}`)
        .then(({ data }) => {
          this.fields = data.fields;
          this.fields.forEach((field) => {
            field.fill = () => '';
          });
        });
    },

    getAvailableResources () {
      return ExTeal.request()
        .get(
          `/api/${this.resourceName}/${this.resourceId}/attachable/${this.relatedResourceName}`,
          {
            params: {
              current: this.relatedResourceId,
              first: true
            }
          }
        )
        .then(({ data }) => {
          this.availableResources = data.data;
        });
    },

    async updateAndContinueEditing () {
      this.updateAndContinueEditing = true;
      try {
        await this.updateRequest();
        this.updateAndContinueEditing = false;
        this.$toasted.show('The resource was updated!', { type: 'success' });
        this.initializeComponent();
      } catch (error) {
        this.updateAndContinueEditing = false;
        if (error.response.status == 422) {
          this.validationErrors = new Errors(error.response.data.errors);
        }
      }
    },

    async updateAttached () {
      this.updateAttached = true;

      try {
        await this.updateRequest();
        this.updateAttachedResource = false;
        this.$toasted.show('The resource was updated!', { type: 'success' });
        this.$router.push({
          name: 'detail',
          params: {
            resourceName: this.resourceName,
            resourceId: this.resourceId,
          },
        });
      } catch (error) {
        this.updateAttachedResource = false;

        if (error.response.status == 422) {
          this.validationErrors = new Errors(error.response.data.errors);
        }
      }
    },

    updateRequest () {
      return ExTeal.request().put(
        `/api/${this.resourceName}/${this.resourceId}/update-pivot/${this.relatedResourceName}/${this.relatedResourceId}`,
        this.attachmentFormData
      );
    },

    selectResourceFromSelectControl (e) {
      this.selectedResourceId = e.target.value;
      this.selectInitialResource();
    },

    selectInitialResource () {
      this.selectedResource = find(
        this.availableResources,
        r => r.id == this.selectedResourceId
      );
    }
  }

};
</script>
