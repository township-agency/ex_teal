<template>
  <div class="flex">
    <select-control
      :options="timeControlOptions"
      :selected="controlType"
      class="form-select bg-white border px-3 py-2 text-80 text-sm appearance-none shadow-none mx-0 border-grey-light text-black"
      @input="selectTimeControl"
    />
    <span
      v-if="controlType == 'ago'"
      class="button-group"
    >
      <button
        v-for="(interval) in agoRanges"
        :key="interval.label"
        :class="{
          'relative inline-flex items-center px-3 py-2 border text-sm leading-5 font-medium transition-colors ease-in-out duration-100 focus:bg-grey-lightest hover:bg-grey-lightest -ml-px': true,
          'text-black bg-white hover:text-grey-darkest focus:text-grey-darkest': interval.label == selectedRange.label,
          'bg-grey-lightest text-grey-darker hover:text-grey-darkest focus:text-grey-darkest ': interval.label !== selectedRange.label
        }"
        @click="selectInterval(interval)"
      >
        {{ interval.label }}
      </button>
    </span>
    <div v-else>
      <select-control
        :options="units"
        :selected="selectedUnit"
        class="form-select bg-white border px-3 py-2 text-80 text-sm appearance-none shadow-none mx-0 border-grey-light text-black -ml-px"
        @input="selectUnit"
      />
    </div>
  </div>
</template>
<script>
import find from 'lodash/find';
import { DateTime } from 'luxon';
import Duration from 'luxon/src/duration';


export default {
  props: {
    agoRanges: {
      type: Array,
      required: true
    },
    selectedRange: {
      type: Object,
      required: true
    }
  },

  data () {
    return {
      controlType: 'ago',
    };
  },

  computed: {
    timeControlOptions () {
      return [
        { label: 'Interval', value: 'ago' },
        // { label: 'Custom Range', value: 'range' }
      ];
    },
    units () {
      return [
        { value: 'minute', label: 'Minute' },
        { value: 'hour', label: 'Hour' },
        { value: 'day', label: 'Day' },
        { value: 'week', label: 'Week' },
        { value: 'month', label: 'Month' },
        { value: 'year', label: 'Year' }
      ];
    }
  },

  methods: {
    selectTimeControl (type) {
      if (type === 'range') {
        const controlType = find(this.agoRanges, (v) => v.label == this.selectedInterval);
        this.selectedUnit = this.selectedRange.unit;
      }

      this.controlType = type;
    },

    selectInterval (range) {
      this.selectedInterval = range.label;
      const endAt = DateTime.local();
      const startAt = this.startAtFromRange(range);
      this.$emit('update-interval', { start: startAt, end: endAt, unit: range.unit, range });
    },

    selectUnit (unit) {
      this.selectedUnit = unit;
    },

    startAtFromRange (range) {
      const now = DateTime.local();
      const durationObj = {};

      durationObj[`${range.unit}s`] = range.value;
      return now.minus(Duration.fromObject(durationObj));
    },

    changeRange () {
      this.$emit('update', { unit: this.selectedUnit });
    }
  }
};
</script>
