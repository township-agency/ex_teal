<template>
  <default-field
    :field="field"
    :errors="errors"
  >
    <template slot="field">
      <div
        v-if="field.value && field.value.length > 0"
        class="space-y-4 mb-4"
      >
        <EmbeddedRow
          v-for="(item, index) in field.value"
          :key="item[0].value"
          :fields="item"
          :index="index"
          :errors="errors"
          :label="label"
          :via-resource="viaResource"
          :via-resource-id="viaResourceId"
          :via-relationship="viaRelationship"
          :resource-name="resourceName"
          @move-up="moveUp"
          @move-down="moveDown"
          @remove-item="removeItem"
        />
      </div>
      <div>
        <a
          class="btn btn-default btn-primary btn-icon-inline"
          @click="attachNew"
        >
          <icon type="create" />
          <span>
            Add a {{ label }}
          </span>
        </a>
      </div>
    </template>
  </default-field>
</template>

<script>
import { FormField, HandlesValidationErrors } from '@/mixins';
import cloneDeep from 'lodash/cloneDeep';
import EmbeddedRow from './EmbeddedRow';
import singularOrPlural from '@/util/singularOrPlural';
import { uid } from 'uid/single';

export default {
  components: { EmbeddedRow },
  mixins: [ FormField, HandlesValidationErrors ],
  props: {
    resourceName: {
      type: String,
      required: true
    },
    field: {
      type: Object,
      required: true
    },
    viaResource: {
      type: String,
      default: null
    },
    viaResourceId: {
      type: Number,
      default: null
    },
    viaRelationship: {
      type: String,
      default: null
    }
  },

  computed: {
    label () {
      return singularOrPlural(1, this.field.name);
    },

    finalPayload () {
      if (!this.field.value) {
        return [];
      }
      return this.field.value.map(item => {
        const formData = new FormData();
        const fields = {};
        item.forEach(f => f.fill && f.fill(formData));
        for (const pair of formData.entries()) {
          fields[pair[0]] = pair[1];
        }

        return fields;
      });
    }
  },

  // mounted () {
  // },

  methods: {
    attachNew () {
      if (!this.field.value) {
        this.field.value = [];
      }
      const newElement = cloneDeep(this.field.options.embed_fields);
      newElement[0].value = uid();
      const elements = newElement.map(field => {
        if (field.component === 'embeds-many') {
          field.value = [];
        }
        return field;
      });
      this.field.value.push(elements);
    },

    fill (formData) {
      const nested = this.field.options.nested || false;
      this.finalPayload.forEach((repeatable, i) => {
        const attribute = `${this.field.attribute}[${i}]`;
        Object.keys(repeatable).forEach(key => {
          let updatedKey;
          if (nested) {
            updatedKey = `${attribute}[${key}]`;
          }
          else {
            const splitKey = key.split(/\[(.*)/s);
            updatedKey = `${attribute}[${splitKey[0]}][${splitKey[1]}`;
          }
          formData.append(updatedKey, repeatable[key]);
        });
      });
    },

    moveUp (index) {
      const item = this.field.value.splice(index, 1);
      this.field.value.splice(Math.max(0, index - 1), 0, item[0]);
    },

    moveDown (index) {
      const item = this.field.value.splice(index, 1);
      this.field.value.splice(Math.min(this.field.value.length, index + 1), 0, item[0]);
    },

    removeItem (index) {
      this.field.value.splice(index, 1);
    }
  }
};

</script>