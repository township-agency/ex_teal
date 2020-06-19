<template>
  <select
    v-bind="$attrs"
    :value="selected"
    v-on="inputListeners"
  >
    <slot />
    <template v-for="(gOptions, group) in groupedOptions">
      <optgroup
        v-if="group"
        :key="group"
        :label="group"
      >
        <option
          v-for="option in gOptions"
          :key="option.value"
          v-bind="attrsFor(option)"
        >
          {{ labelFor(option) }}
        </option>
      </optgroup>
      <template v-else>
        <option
          v-for="option in gOptions"
          :key="option.id"
          v-bind="attrsFor(option)"
        >
          {{ labelFor(option) }}
        </option>
      </template>
    </template>
  </select>
</template>

<script>
import groupBy from 'lodash/groupBy';
import assign from 'lodash/assign';
export default {
  props: {
    options: {
      type: Array,
      default () {
        return [];
      }
    },
    selected: {
      type: [ Number, String ],
      default: null
    },
    label: {
      type: String,
      default: 'label',
    },
    valueKey: {
      type: String,
      default: 'value'
    },
  },

  computed: {
    groupedOptions () {
      return groupBy(this.options, option => option.group || '');
    },

    inputListeners () {
      return assign({}, this.$listeners, {
        input: event => {
          this.$emit('input', event.target.value);
        },
      });
    },
  },

  methods: {
    labelFor (option) {
      return this.label instanceof Function ? this.label(option) : option[this.label];
    },

    attrsFor (option) {
      return assign(
        {},
        option.attrs || {},
        { value: option[this.valueKey] },
        this.selected !== void 0 ? { selected: this.selected == option[this.valueKey] } : {}
      );
    },
  },
};
</script>
