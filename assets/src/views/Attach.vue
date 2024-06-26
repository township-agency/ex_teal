<template>
  <loading-view :loading="loading">
    <div class="card-headline">
      <heading class="mb-3">
        Attach {{ relatedResourceLabel }}
      </heading>
      <div class="flex ml-auto">
        <button
          type="button"
          class="ml-auto btn btn-default btn-secondary mr-3"
          @click="attachAndAttachAnother"
        >
          Attach &amp; Attach Another
        </button>

        <button
          class="btn btn-default btn-primary"
          @click="attachResource"
        >
          Attach {{ relatedResourceLabel }}
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
            <search-input
              v-if="field.options.searchable"
              :value="selectedResource"
              :data="availableResources"
              track-by="value"
              class="mb-3"
              @input="performSearch"
              @clear="clearSelection"
              @selected="selectResource"
            >
              <div
                v-if="selectedResource"
                slot="default"
                class="flex items-center"
              >
                {{ selectedResource.title }}
              </div>
              <div
                slot="option"
                slot-scope="{ option }"
                class="flex items-center"
              >
                {{ option.title }}
              </div>
            </search-input>
            <select
              v-else
              class="form-control form-select mb-3 w-full"
              @change="selectResourceFromSelectControl"
            >
              <option
                value=""
                selected
              >
                Choose {{ field.name }}
              </option>

              <option
                v-for="resource in availableResources"
                :key="resource.id"
                :value="resource.id"
                :selected="selectedResourceId == resource.id"
              >
                {{ resource.title }}
              </option>
            </select>
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
import { PerformsSearches } from '@/mixins';
import { Errors } from '@/util/errors';
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
    viaResource: {
      type: String,
      default: null
    },
    viaResourceId: {
      type: String,
      default: null
    },
    viaRelationship: {
      type: String,
      default: null
    }
  },

  data: () => ({
    loading: true,
    submittedViaAttachAndAttachAnother: false,
    submittedViaAttachResource: false,
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
          formData.append(this.relatedResourceName, this.selectedResource.id);
        }
        formData.append('viaRelationship', this.viaRelationship);
      });
    }
  },

  mounted () {
    this.initializeComponent();
  },

  methods: {
    initializeComponent () {
      this.clearSelection();
      this.getField();
      this.getPivotFields();
      this.resetErrors();
    },

    getField () {
      this.field = null;

      ExTeal.request()
        .get(`/api/${this.resourceName}/field/${this.viaRelationship}`)
        .then(({ data }) => {
          this.field = data.field;
          this.getAvailableResources();
          this.loading = false;
        });
    },

    getPivotFields () {
      this.fields = [];
      ExTeal.request()
        .get(`/api/${this.resourceName}/creation-pivot-fields/${this.relatedResourceName}`)
        .then(({ data }) => {
          this.fields = data.fields;
          this.fields.forEach((field) => {
            field.fill = () => '';
          });
        });
    },

    resetErrors () {
      this.validationErrors = new Errors();
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
    },

    getAvailableResources (search = '') {
      ExTeal.request()
        .get(
          `/api/${this.resourceName}/${this.resourceId}/attachable/${
            this.relatedResourceName
          }`,
          {
            params: {
              search,
              current: this.selectedResourceId,
            },
          }
        )
        .then(({ data }) => {
          this.availableResources = data.data;
        });
    },

    async attachResource () {
      this.submittedViaAttachResource = true;

      if (!this.selectedResource) {
        return;
      }

      try {
        await this.attachRequest();

        this.submittedViaAttachResource = false;
        this.$router.push({
          name: 'detail',
          params: {
            resourceName: this.resourceName,
            resourceId: this.resourceId
          }
        });
      } catch (error) {
        this.submittedViaAttachResource = false;
        this.handleInvalid(error);
        if (error.response.status === 422) {
          this.validationErrors = new Errors(error.response.data.errors);
        }
      }
    },

    async attachAndAttachAnother () {
      this.submittedViaAttachAndAttachAnother = true;

      if (!this.selectedResource) {
        return;
      }

      try {
        await this.attachRequest();

        this.submittedViaAttachAndAttachAnother = false;
        this.initializeComponent();
      } catch (error) {
        this.submittedViaAttachAndAttachAnother = false;
        this.handleInvalid(error);
      }
    },

    attachRequest () {
      return ExTeal.request().post(`/api/${this.resourceName}/${this.resourceId}/attach/${this.relatedResourceName}`, this.attachmentFormData);
    },

    handleInvalid (error) {
      const errors = error.response.data.errors;
      ExTeal.$emit('error', `Unable to attach the ${this.relatedResourceLabel}`);
      this.validationErrors = new Errors(errors);
    }
  },
};

</script>
