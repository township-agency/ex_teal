<template>
  <select
    class="relative"
    v-bind="$attrs"
    :value="selected"
    v-on="inputListeners"
  >
    <slot />
    <template v-for="option in options">
      <optgroup
        v-if="option.group"
        :key="option.group"
        :label="option.group"
      >
        <option
          v-for="o in option.options"
          :key="o.key"
          v-bind="attrsFor(o)"
        >
          {{ labelFor(o) }}
        </option>
      </optgroup>
      <template v-else>
        <option
          :key="option.value"
          v-bind="attrsFor(option)"
        >
          {{ labelFor(option) }}
        </option>
      </template>
    </template>
  </select>
</template>

<script>
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
    inputListeners () {
      return assign({}, this.$listeners, {
        change: event => {
          this.$emit('input', event.target.value);
          this.$emit('change', event);
        },
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
    }
  },
};
</script>
