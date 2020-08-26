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
    <loading-card
      :loading="loading"
    >
      <div class="m-4 max-h-3/4">
        <BaseLineMetric
          v-if="showLine"
          :chart-data="data"
          :options="chartOptions"
        />

        <BaseBarMetric
          v-if="showBar"
          :chart-data="data"
          :options="chartOptions"
        />
      </div>
    </loading-card>
  </div>
</template>

<script>
import { Minimum } from 'ex-teal-js';
import BaseLineMetric from './Base/LineMetric';
import BaseBarMetric from './Base/BarMetric';
import merge from 'lodash/merge';
import { DateTime } from 'luxon';
import Duration from 'luxon/src/duration';
import Interval from 'luxon/src/interval';

const FORMATS = {
  minute: DateTime.TIME_SIMPLE,
  hour: { hour: 'numeric' },
  day: { day: 'numeric', month: 'short' },
  week: 'DD',
  month: { month: 'short', year: 'numeric' },
  year: { year: 'numeric' }
};

export default {
  name: 'TrendMetric',
  components: {
    BaseLineMetric,
    BaseBarMetric
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
    multipleResults: false,
    userOptions: {},
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

    chartOptions () {
      return merge({
        type: 'line',
        responsive: true,
        maintainAspectRatio: false,
        pointRadius: 1,
        scales: {
          xAxes: [ {
            type: 'time',
            distribution: 'series',
            offset: false,
            ticks: {
              source: 'data',
              autoSkip: true,
              maxRotation: 0,
              autoSkipPadding: 10
            },
            time: {
              unit: this.unit,
              tooltipFormat: FORMATS[this.unit]
            }
          } ],
          yAxes: [ {
            gridLines: {
              drawBorder: false
            }
          } ],
        },
        tooltips: {
          mode: 'index',
          callbacks: {
            label: (item, data) => {
              const elems = [ this.prefix, item.value, this.suffix ].filter(v => v);
              return `${data.datasets[item.datasetIndex].label}: ${elems.join('')}`;
            }
          }
        },
        legend: {
          display: this.multipleResults
        }
      }, this.userOptions);
    },

    ranges () {
      return this.card.options.ranges;
    },

    showLine () {
      return !this.loading && this.chartOptions.type == 'line';
    },

    showBar () {
      return !this.loading && this.chartOptions.type == 'bar';
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
      const { startAt, endAt, unit, timezone, multiple_results } = this;
      Minimum(ExTeal.request().get(this.metricEndpoint, { params: {
        start_at: startAt.toISO({ suppressMilliseconds: true }),
        end_at: endAt.toISO({ suppressMilliseconds: true }),
        unit,
        timezone
      } })).then(
        ({
          data: {
            metric: { data, prefix, suffix, multiple_results, options },
          },
        }) => {
          this.multipleResults = multiple_results;
          if (multiple_results) {
            const multiData = data.map((trend) => {
              return { label: trend.label, ...trend.data };
            });
            this.data = { datasets: multiData };
          } else {
            data.label = this.card.title;
            this.data = { datasets: [ data ] };
          }
          this.prefix = prefix !== null ? prefix : this.prefix;
          this.suffix = suffix !== null ? suffix : this.suffix;
          this.suffix = suffix || this.suffix;
          this.userOptions = options;
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
