<template>
  <default-field
    :field="field"
    :errors="errors"
  >
    <template slot="field">
      <div
        v-if="!listFirst && !maxReached"
        class="flex border border-gray-light p-4"
      >
        <input
          v-model="newItem"
          :type="field.inputType"
          :placeholder="placeholder"
          autocomplete="new-password"
          class="flex-1 form-control form-input form-input-bordered"
          @keydown.enter.prevent="addItem"
        >
        <a
          v-if="!hideCreateButton"
          class="btn btn-default btn-primary btn-only-icon ml-3 cursor-pointer"
          @click="addItem"
        >
          <icon type="create" />
        </a>
      </div>
      <ul
        v-if="items.length"
        ref="itemslist"
        :style="maxHeight"
        class="border border-gray-light py-2"
      >
        <draggable
          v-model="items"
          :disabled="!isDraggable"
          handle=".sortable-handle"
        >
          <li
            v-for="(item, index) in items"
            :key="field.attribute + '.' + index"
            class="px-4 py-2"
          >
            <div class="flex py-1 items-center">
              <span
                v-if="isDraggable"
                class="sortable-handle flex items-center pr-3 cursor-move"
              >
                <icon type="drag" />
              </span>
              <input
                :value="item"
                :type="field.inputType"
                :name="field.name + '['+ index +']'"
                autocomplete="new-password"
                class="flex-1 form-control form-input form-input-bordered"
                @keyup="updateItem(index, $event)"
              >
              <a
                class="btn btn-default btn-danger btn-only-icon cursor-pointer ml-3"
                @click="removeItem(index)"
              >
                <icon type="delete" />
              </a>
            </div>
          </li>
        </draggable>
      </ul>
      <div
        v-if="listFirst && !maxReached"
        class="flex border border-gray-light p-4"
      >
        <input
          v-model="newItem"
          :type="field.inputType"
          :placeholder="placeholder"
          autocomplete="new-password"
          class="flex-1 form-control form-input form-input-bordered"
          @keydown.enter.prevent="addItem"
        >
        <a
          v-if="!hideCreateButton"
          class="btn btn-default btn-primary btn-only-icon ml-3 cursor-pointer"
          @click="addItem"
        >
          <icon type="create" />
        </a>
      </div>
    </template>
  </default-field>
</template>

<script>
import draggable from 'vuedraggable';
import { FormField, HandlesValidationErrors } from '@/mixins';

export default {
  components: { draggable },

  mixins: [ HandlesValidationErrors, FormField ],

  data: function () {
    return {
      value: '',
      items: [],
      newItem: ''
    };
  },

  computed: {
    listFirst () {
      return this.field.options.list_first || true;
    },

    hideCreateButton () {
      return this.field.options.hide_create_button || false;
    },

    maxItems () {
      return this.field.options.max || false;
    },

    maxHeight () {
      return this.field.options.max_height || false;
    },

    maxReached () {
      return this.maxItems !== false && this.items.length + 1 > this.maxItems;
    },

    isDraggable () {
      return this.field.options.draggable || false;
    },

    placeholder () {
      return this.field.options.placeholder || 'Add an Item';
    }
  },

  mounted () {
    this.setInitialValue();
    this.field.fill = formData => {
      if (this.items.length == 0) {
        formData.append(`${this.field.attribute}[]`, []);
      } else {
        this.items.forEach((item, i) => {
          formData.append(`${this.field.attribute}[]`, item);
        });
      }
    };
  },

  methods: {
    setInitialValue () {
      this.value = this.field.value || [];
      this.items = this.field.value || [];
    },

    addItem () {
      const item = this.newItem.trim();

      if (item && ! this.maxReached) {
        this.items.push(item);
        this.newItem = '';

        this.$nextTick(() => {
          if (this.maxHeight) {
            this.$refs.itemslist.scrollTop = this.$refs.itemslist.scrollHeight;
          }
        });
      }
    },

    updateItem (index, event) {
      this.$set(this.items, index, event.target.value);
    },

    removeItem (index) {
      this.items.splice(index, 1);
    }
  }
};
</script>
