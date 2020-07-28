<template>
  <div>
    <header class="uppercase text-xs mb-4">
      {{ card.title }}
    </header>
    <loading-card
      :loading="loading"
    >
      <div class="m-4 max-h-3/4">
        <BaseTrendMetric
          v-if="!loading"
          :chart-data="data"
          :options="chartOptions"
        />
      </div>
    </loading-card>
  </div>
</template>

<script>
import { Minimum } from 'ex-teal-js';
import BaseTrendMetric from './Base/TrendMetric';
import merge from 'lodash/merge';
import { DateTime } from 'luxon';

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
    BaseTrendMetric
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
    },

    metricData: {
      type: Object,
      required: true
    }
  },

  data: () => ({
    loading: true,
    data: [],
    prefix: '',
    suffix: '',
    multipleResults: false,
    userOptions: {},
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
        pointRadius: 1,
        scales: {
          xAxes: [ {
            type: 'time',
            distribution: 'series',
            offset: true,
            ticks: {
              source: 'data',
              autoSkip: true,
              maxRotation: 0,
              autoSkipPadding: 10
            },
            time: {
              unit: this.metricData.unit,
              tooltipFormat: FORMATS[this.metricData.unit]
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
    }
  },

  watch: {
    resourceId () {
      this.fetch();
    },

    metricData () {
      this.fetch();
    }
  },

  mounted () {
    this.fetch();
  },

  methods: {
    fetch () {
      this.loading = true;
      const { startAt, endAt, unit, timezone, multiple_results } = this.metricData;
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
    }
  },
};
</script>
