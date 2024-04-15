<template>
  <div class="flex">
    <dropdown
      v-if="agoRanges.length > 0"
      class="rounded-none"
    >
      <dropdown-trigger
        slot-scope="{ toggle }"
        :handle-click="toggle"
        class="px-3 border bg-white rounded-none"
      >
        {{ selectedRange.label }}
      </dropdown-trigger>

      <dropdown-menu
        slot="menu"
        direction="rtl"
        width="150"
      >
        <ul class="flex flex-wrap divide-x divide-y divide-gray-lighter">
          <li
            v-for="interval in agoRanges"
            :key="interval.label"
            class="w-1/3 text-center"
          >
            <a
              :class="{
                'px-3 py-2 block hover:bg-gray-lightest text-center': true,
                'hover:bg-gray-lightest bg-gray-light': selectedRange.label == interval.label
              }"
              @click="selectInterval(interval)"
            > {{ interval.label }} </a>
          </li>
        </ul>
      </dropdown-menu>
    </dropdown>
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

  computed: {
    timeControlOptions () {
      return [
        { label: 'Interval', value: 'ago' },
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
