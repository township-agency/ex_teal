<template>
  <div
    v-on-clickaway="close"
    :class="{ 'opacity-75': disabled }"
  >
    <div class="relative">
      <div
        ref="input"
        :class="{ focus: show, 'border-danger': error }"
        :tabindex="show ? -1 : 0"
        class="flex items-center form-control form-input form-input-bordered pr-6"
        @click="open"
        @focus="open"
        @keydown.down.prevent="open"
        @keydown.up.prevent="open"
      >
        <div
          v-if="shouldShowDropdownArrow"
          class="search-input-trigger absolute inset select-box"
        />

        <slot name="default">
          <icon type="search" />
          <div class="text-gray">
            Click to search
          </div>
        </slot>
      </div>

      <button
        v-if="value"
        type="button"
        tabindex="-1"
        class="absolute p-2 inline-block"
        style="right: 4px; top: 6px;"
        @click.stop="clear"
      >
        <svg
          class="block fill-current icon h-2 w-2"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="278.046 126.846 235.908 235.908"
        >
          <path
            d="M506.784 134.017c-9.56-9.56-25.06-9.56-34.62 0L396 210.18l-76.164-76.164c-9.56-9.56-25.06-9.56-34.62 0-9.56 9.56-9.56 25.06 0 34.62L361.38 244.8l-76.164 76.165c-9.56 9.56-9.56 25.06 0 34.62 9.56 9.56 25.06 9.56 34.62 0L396 279.42l76.164 76.165c9.56 9.56 25.06 9.56 34.62 0 9.56-9.56 9.56-25.06 0-34.62L430.62 244.8l76.164-76.163c9.56-9.56 9.56-25.06 0-34.62z"
          />
        </svg>
      </button>
    </div>

    <div
      v-if="show"
      ref="dropdown"
      :style="{ width: inputWidth + 'px', zIndex: 2000 }"
      class="form-input form-input-bordered search-input absolute top-0 left-0 my-1 overflow-hidden"
    >
      <div class="p-2 bg-gray-300">
        <input
          ref="search"
          v-model="search"
          :disabled="disabled"
          placeholder="Search"
          class="outline-none search-input-input w-full text-sm leading-normal bg-white"
          tabindex="-1"
          type="text"
          spellcheck="false"
          @input="handleInput"
          @keydown.enter.prevent="chooseSelected"
          @keydown.down.prevent="move(1)"
          @keydown.up.prevent="move(-1)"
        >
      </div>
      <div
        ref="container"
        class="search-input-options relative overflow-y-auto scrolling-touch text-sm shadow"
        tabindex="-1"
        style="max-height: 155px;"
      >
        <div
          v-if="shouldShowHelpText"
          class="p-2"
        >
          Enter a search term more than {{ minSearchLength }} long.
        </div>
        <div
          v-if="!isSearching && !shouldShowHelpText && data.length == 0"
          class="p-2"
        >
          No results found
        </div>
        <div v-if="isSearching">
          Searching
        </div>

        <div
          v-for="(option, index) in data"
          :key="getTrackedByKey(option)"
          :ref="index === selected ? 'selected' : null"
          :class="{
            [`search-input-item-${index}`]: true,
            'hover:bg-gray-lighter': index !== selected,
            'bg-primary text-white': index === selected
          }"
          class="px-4 py-2 cursor-pointer"
          @click="choose(option)"
        >
          <slot
            :option="option"
            :selected="index === selected"
            name="option"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import _ from 'lodash';
import Vue from 'vue';
import Popper from 'popper.js';
import { mixin as clickaway } from 'vue-clickaway';

export default {
  mixins: [ clickaway ],
  inheritAttrs: false,
  props: {
    disabled: { default: false, type: Boolean },
    value: {
      default: null,
      type: [ Object, String ]
    },
    data: {
      type: Array,
      default: () => { return []; }
    },
    trackBy: {
      type: String,
      default: null
    },
    error: {
      type: Boolean,
      default: false
    },
    boundary: {
      type: String,
      default: null
    },
    debounce: {
      type: Number,
      default: 500
    },
    minSearchLength: {
      type: Number,
      default: 3
    },
    isSearching: {
      type: Boolean,
      default: false
    }
  },

  data: () => ({
    show: false,
    search: '',
    selected: 0,
    popper: null,
    inputWidth: null
  }),

  computed: {
    shouldShowDropdownArrow () {
      return this.value == '' || this.value == null;
    },

    shouldShowHelpText () {
      return this.search == null || this.search == '' || this.search.length < this.minSearchLength;
    },

    dataLength () {
      return this.data ? this.data.length : false;
    }
  },

  watch: {
    search () {
      this.selected = 0;
      if (this.$refs.container) {
        this.$refs.container.scrollTop = 0;
      }

      if (this.show.length >= this.minSearchLength && this.popper) {
        this.popper.update();
      }
    },
    show (show) {
      if (show) {
        const selected = _.findIndex(this.data, [
          this.trackBy,
          _.get(this.value, this.trackBy)
        ]);
        if (selected !== -1) {this.selected = selected;}
        this.inputWidth = this.$refs.input.offsetWidth;

        Vue.nextTick(() => {
          const vm = this;

          this.popper = new Popper(this.$refs.input, this.$refs.dropdown, {
            placement: 'bottom-start',
            onCreate () {
              vm.$refs.container.scrollTop = vm.$refs.container.scrollHeight;
              vm.updateScrollPosition();
              vm.$refs.search.focus();
            },
            modifiers: {
              preventOverflow: {
                boundariesElement: this.boundary
                  ? this.boundary
                  : 'scrollParent'
              }
            }
          });
        });
      } else {
        if (this.popper) {this.popper.destroy();}
      }
    },

    dataLength () {
      if (this.popper) {this.popper.update(); }
    }
  },

  mounted () {
    document.addEventListener('keydown', e => {
      if (this.show && (e.keyCode == 9 || e.keyCode == 27)) {
        setTimeout(() => this.close(), 50);
      }
    });
  },

  methods: {
    getTrackedByKey (option) {
      return _.get(option, this.trackBy);
    },

    open () {
      if (!this.disabled) {
        this.show = true;
        this.search = '';
      }
    },

    close () {
      this.show = false;
    },

    clear () {
      if (!this.disabled) {
        this.selected = null;
        this.$emit('clear', null);
      }
    },

    move (offset) {
      const newIndex = this.selected + offset;

      if (newIndex >= 0 && newIndex < this.data.length) {
        this.selected = newIndex;
        this.updateScrollPosition();
      }
    },

    updateScrollPosition () {
      Vue.nextTick(() => {
        if (this.$refs.selected) {
          if (
            this.$refs.selected.offsetTop >
            this.$refs.container.scrollTop +
              this.$refs.container.clientHeight -
              this.$refs.selected.clientHeight
          ) {
            this.$refs.container.scrollTop =
              this.$refs.selected.offsetTop +
              this.$refs.selected.clientHeight -
              this.$refs.container.clientHeight;
          }

          if (
            this.$refs.selected.offsetTop < this.$refs.container.scrollTop
          ) {
            this.$refs.container.scrollTop = this.$refs.selected.offsetTop;
          }
        }
      });
    },

    chooseSelected () {
      if (this.data[this.selected] !== undefined) {
        this.$emit('selected', this.data[this.selected]);
        this.$refs.input.focus();
        Vue.nextTick(() => this.close());
      }
    },

    choose (option) {
      this.selected = _.findIndex(this.data, [
        this.trackBy,
        _.get(option, this.trackBy)
      ]);
      this.$emit('selected', option);
      this.$refs.input.focus();
      Vue.nextTick(() => this.close());
    },

    /**
     * Handle the input event of the search box
     */
    handleInput (e) {
      if (e.target.value && e.target.value.length >= 3) {
        this.debouncer(() => {
          this.$emit('input', e.target.value);
        });
      }
    },

    /**
     * Debounce function for the input handler
     */
    debouncer: _.debounce(callback => callback(), 500)
  }
};
</script>
