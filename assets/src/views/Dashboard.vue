<template>
  <div>
    <div class="lg:flex lg:items-center lg:justify-between pb-6 w-full">
      <heading class="lg:flex md:items-center mb-4 lg:mb-0">
        {{ dashboard.title }}
        <span
          v-if="startAt"
          class="text-70 text-sm ml-4"
        >{{ timeRange }}</span>
      </heading>
      <metric-time-control
        v-if="!!selectedRange"
        :ago-ranges="ranges"
        :unit="unit"
        :selected-range="selectedRange"
        @update-interval="updateInterval"
      />
    </div>

    <div v-if="shouldShowCards">
      <cards
        v-if="cards.length > 0"
        :cards="cards"
        :metric-data="metricData"
      />
    </div>
  </div>
</template>

<script>
import { HasCards } from 'ex-teal-js';
import find from 'lodash/find';
import { DateTime } from 'luxon';
import Duration from 'luxon/src/duration';
import Interval from 'luxon/src/interval';

export default {
  mixins: [ HasCards ],

  props: {
    uri: {
      type: String,
      required: false,
      default: 'main'
    }
  },

  data () {
    return {
      startAt: null,
      endAt: null,
      unit: null,
      timezone: null,
      selectedRange: null
    };
  },

  computed: {
    cardsEndpoint () {
      return `/api/dashboards/${this.uri}`;
    },

    dashboard () {
      return find(ExTeal.config.dashboards, dashboard => dashboard.uri == this.uri);
    },

    ranges () {
      return this.dashboard.ranges;
    },

    timeRange () {
      return `${this.startAt.toLocaleString(DateTime.DATETIME_SHORT)} to ${this.endAt.toLocaleString(DateTime.DATETIME_SHORT)}`;
    },

    shouldShowCards () {
      return this.cards.length > 0;
    },

    metricData () {
      return {
        unit: this.unit,
        startAt: this.startAt,
        endAt: this.endAt,
        timezone: this.timezone
      };
    }
  },

  created () {
    this.selectedRange = this.dashboard.default_range;
    this.unit = this.selectedRange.unit;
    this.timezone = DateTime.local().zoneName;
    this.startAt = this.startAtFromRange(this.selectedRange);
    this.endAt = DateTime.local();
  },

  methods: {
    updateInterval ({ start, end, unit, range }) {
      this.startAt = start;
      this.endAt = end;
      this.unit = unit;
      this.selectedRange = range;
    },

    startAtFromRange (range) {
      const now = DateTime.local();
      const durationObj = {};

      durationObj[`${range.unit}s`] = range.value;

      return now.minus(Duration.fromObject(durationObj));
    }
  }
};
</script>
