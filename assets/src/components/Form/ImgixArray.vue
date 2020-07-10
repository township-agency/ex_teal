<template>
  <default-field :field="field">
    <template slot="field">
      <div 
        v-if="!listFirst && !maxReached"
        class="flex border border-40 p-4 items-center" 
      >
        <image-uploader :field="field" v-model="newItem" :isHorizontal="true" class="w-full flex" />

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
        class="border border-40 py-6 px-4"
      >
        <draggable
          v-model="items"
          :disabled="!isDraggable"
          handle=".sortable-handle"
        >
          <li
            v-for="(item, index) in items"
            :key="field.attribute + '.' + index"
            class="px-4 py-2 form-input-bordered"
          >
            <div class="flex py-1 items-center">
              <span
                v-if="isDraggable"
                class="sortable-handle flex items-center pr-3 cursor-move"
              >
                <icon type="drag" />
              </span>

              <image-uploader :field="field" v-model="items[index]" class="w-full" :isHorizontal="true" />

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
        class="flex border border-40 p-4 items-center" 
      >

        <image-uploader :field="field" v-model="newItem" :isHorizontal="true" class="flex w-full" />

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
import { FormField, HandlesValidationErrors } from 'ex-teal-js';
import ImageUploader from '../Shared/ImageUploader';

export default {
  name: 'ImgixArray',

  components: { draggable, ImageUploader },

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
      return this.field.options.list_first || false;
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

  watch: {
    newItem(newVal) {
      if (Boolean(newVal)) this.addItem()
    }
  },

  mounted () {
    this.setInitialValue();
    this.field.fill = formData => {
      this.items.forEach((item, i) => {
        formData.append(`${this.field.attribute}[]`, item);
      });
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
        this.items = [...this.items, item]

        this.$nextTick(() => {
          // Clear newItem on nextTick so child component can register a change in value
          this.newItem = '';

          if (this.maxHeight) {
            this.$refs.itemslist.scrollTop = this.$refs.itemslist.scrollHeight;
          }
        });
      }
    },

    removeItem (index) {
      this.items.splice(index, 1);
    }
  }
};
</script>
