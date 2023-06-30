<template>
  <div>
    <header class="uppercase text-xs mb-4 flex items-center justify-between">
      {{ card.title }}
      <metric-time-control
        v-if="!!selectedRange"
        :ago-ranges="ranges"
        :unit="unit"
        :selected-range="selectedRange"
        @update-interval="updateInterval"
      />
    </header>
    <loading-card :loading="loading">
      <div class="m-4 flex items-center justify-between flex-wrap">
        <BaseValueMetric
          v-for="(d, i) in data"
          :key="i"
          :data="d.data"
          :label="d.label"
          :prefix="prefix"
          :suffix="suffix"
          :format="format"
        />
      </div>
    </loading-card>
  </div>
</template>

<script>
import Minimum from '@/util/minimum';
import BaseValueMetric from './Base/ValueMetric';
import { DateTime } from 'luxon';
import Duration from 'luxon/src/duration';

export default {
  name: 'ValueMetric',

  components: {
    BaseValueMetric,
  },

  props: {
    card: {
      type: Object,
      required: true,
    },

    resourceName: {
      type: String,
      default: '',
    },

    resourceId: {
      type: [ Number, String ],
      default: '',
    }
  },

  data: () => ({
    loading: true,
    data: [],
    prefix: '',
    suffix: '',
    multiple_results: false,
    startAt: null,
    endAt: null,
    unit: null,
    timezone: null,
    selectedRange: null
  }),

  computed: {
    metricEndpoint () {
      const uri = this.card.options.uri;
      if (this.resourceName && this.resourceId) {
        return `/api/${this.resourceName}/${this.resourceId}/metrics/${uri}`;
      } else if (this.resourceName) {
        return `/api/${this.resourceName}/metrics/${uri}`;
      } else {
        return `/api/metrics/${uri}`;
      }
    },

    ranges () {
      return this.card.options.ranges;
    },

    format () {
      return this.card.options.format;
    }
  },

  watch: {
    resourceId () {
      this.fetch();
    }
  },

  created () {
    this.selectedRange = this.card.options.default_range;
    this.unit = this.selectedRange.unit;
    this.timezone = DateTime.local().zoneName;
    this.startAt = this.startAtFromRange(this.selectedRange);
    this.endAt = DateTime.local();
  },

  mounted () {
    this.fetch();
  },

  methods: {
    fetch () {
      this.loading = true;
      const { startAt, endAt, unit, timezone } = this;
      Minimum(ExTeal.request().get(this.metricEndpoint, {
        params: {
          start_at: startAt.toISO({ suppressMilliseconds: true }),
          end_at: endAt.toISO({ suppressMilliseconds: true }),
          unit,
          timezone
        }
      })).then(
        ({
          data: {
            metric: { data, prefix, suffix, multiple_results },
          },
        }) => {
          this.multiple_results = multiple_results;
          this.prefix = prefix || this.prefix;
          this.suffix = suffix || this.suffix;
          this.data = multiple_results ? data : [ { label: this.card.title, data } ];
          this.loading = false;
        }
      );
    },

    startAtFromRange (range) {
      const now = DateTime.local();
      const durationObj = {};
      durationObj[`${range.unit}s`] = range.value;
      return now.minus(Duration.fromObject(durationObj));
    },

    updateInterval ({ start, end, unit, range }) {
      this.startAt = start;
      this.endAt = end;
      this.unit = unit;
      this.selectedRange = range;
      this.fetch();
    },
  },
};
</script>
