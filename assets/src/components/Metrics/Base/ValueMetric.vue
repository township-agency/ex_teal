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
      <p class="text-80 font-bold inline-flex items-center">
        <svg
          v-if="increaseOrDecreaseLabel == 'Decrease'"
          class="text-danger fill-current mr-2"
          width="20"
          height="20"
        >
          <path
            d="M1.25,18.75V0H0v20h20v-1.25H1.25z M9.3876,9.375l1.2374-1.2374l4.9372,4.9371H9.696v1.25h8v-8h-1.25v5.8661l-4.9371-4.9372
    L10.625,6.3698L8.5037,8.4911L4.4378,4.4252L3.554,5.3091l4.9497,4.9497L9.3876,9.375z"
          />
        </svg>
        <svg
          v-if="increaseOrDecreaseLabel == 'Increase'"
          class="rotate-180 text-success fill-current mr-2"
          width="20"
          height="20"
        >
          <path
            d="M1.25,18.75V0H0v20h20v-1.25H1.25z M8.5037,10.2589l2.1213,2.1213l5.8211-5.821v5.8661h1.25v-8h-8v1.25h5.8661
    l-4.9372,4.9372L9.3425,9.33L8.5037,8.4911L3.554,13.4409l0.8839,0.8839L8.5037,10.2589z"
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
