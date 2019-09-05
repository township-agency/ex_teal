<template>
  <loading-card
    :loading="loading"
    class="metric px-6 py-4 relative"
  >
    <div class="flex mb-4 justify-between">
      <h3 class="mr-3 text-base text-80 font-bold">
        {{ title }}
      </h3>

      <select
        v-if="Object.keys(ranges).length > 0"
        class="form-control form-select"
        @change="handleChange"
      >
        <option
          v-for="(label, key) in ranges"
          :key="key"
          :value="key"
          :selected="selectedRangeKey == key"
        >
          {{ label }}
        </option>
      </select>
    </div>

    <p class="flex items-center text-4xl mb-4">
      {{ formattedValue }}
      <span
        v-if="suffix"
        class="ml-2 text-sm font-bold text-80"
      >{{ formattedSuffix }}</span>
    </p>

    <div class="flex items-center">
      <p class="text-80 font-bold">
        <svg
          v-if="increaseOrDecreaseLabel == 'Decrease'"
          class="text-danger fill-current mr-2"
          width="20"
          height="12"
        >
          <path
            d="M2 3a1 1 0 0 0-2 0v8a1 1 0 0 0 1 1h8a1 1 0 0 0 0-2H3.414L9 4.414l3.293 3.293a1 1 0 0 0 1.414 0l6-6A1 1 0 0 0 18.293.293L13 5.586 9.707 2.293a1 1 0 0 0-1.414 0L2 8.586V3z"
          />
        </svg>
        <svg
          v-if="increaseOrDecreaseLabel == 'Increase'"
          class="rotate-180 text-success fill-current mr-2"
          width="20"
          height="12"
        >
          <path
            d="M2 3a1 1 0 0 0-2 0v8a1 1 0 0 0 1 1h8a1 1 0 0 0 0-2H3.414L9 4.414l3.293 3.293a1 1 0 0 0 1.414 0l6-6A1 1 0 0 0 18.293.293L13 5.586 9.707 2.293a1 1 0 0 0-1.414 0L2 8.586V3z"
          />
        </svg>

        <span v-if="increaseOrDecrease != 0">
          <span v-if="growthPercentage !== 0">
            {{ growthPercentage }}% {{ increaseOrDecreaseLabel }}
          </span>

          <span v-else>No Increase</span>
        </span>

        <span v-else>
          <span v-if="previous == '0' && value != '0'">No Prior Data </span>
          <span v-if="value == '0' && previous != '0'">No Current Data</span>
          <span v-if="value == '0' && previous == '0'">No Data</span>
        </span>
      </p>
    </div>
  </loading-card>
</template>

<script>
import numbro from 'numbro';
import { singularOrPlural } from 'ex-teal-js';

export default {
  props: {
    loading: { type: Boolean, default: true },
    title: {
      type: String,
      default: ''
    },
    previous: {
      type: Number,
      default: 0
    },
    value: {
      type: Number,
      default: 0
    },
    prefix: {
      type: String,
      default: ''
    },
    suffix: {
      type: String,
      default: ''
    },
    selectedRangeKey: {
      type: [ String, Number ],
      required: true
    },
    ranges: { type: Object, default: () => {} },
    format: {
      type: String,
      default: '(0[.]00a)',
    },
  },

  computed: {
    growthPercentage () {
      return Math.abs(this.increaseOrDecrease);
    },

    increaseOrDecrease () {
      if (this.previous == 0 || this.previous == null || this.value == 0) {return 0;}
      return (((this.value - this.previous) / this.previous) * 100).toFixed(2);
    },

    increaseOrDecreaseLabel () {
      let label;
      switch (Math.sign(this.increaseOrDecrease)) {
        case 1:
          label = 'Increase';
          break;
        case 0:
          label = 'Constant';
          break;
        case -1:
          label = 'Decrease';
          break;
      }
      return label;
    },

    sign () {
      let sign;
      switch (Math.sign(this.increaseOrDecrease)) {
        case 1:
          sign = '+';
          break;
        case 0:
          sign = '';
          break;
        case -1:
          sign = '-';
          break;
      }
      return sign;
    },

    isNullValue () {
      return this.value == null;
    },

    formattedValue () {
      if (!this.isNullValue) {
        return this.prefix + numbro(this.value).format(this.format);
      }

      return '';
    },

    formattedSuffix () {
      return singularOrPlural(this.value, this.suffix);
    },
  },

  methods: {
    handleChange (event) {
      this.$emit('selected', event.target.value);
    },
  },
};
</script>
