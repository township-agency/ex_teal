<template>
  <div>
    <header class="uppercase text-xs mb-4 flex items-center justify-between h-8">
      {{ card.title }}
      <span>Total: {{ total }}</span>
    </header>
    <loading-card :loading="loading">
      <div class="m-4 flex items-end justify-center flex-wrap h-full">
        <BasePartitionMetric
          :chart-data="chartData"
          :options="options"
          :styles="chartStyles"
        />
      </div>
    </loading-card>
  </div>
</template>

<script>
import { InteractsWithTheme } from '@/mixins';
import Minimum from '@/util/minimum';
import BasePartitionMetric from './Base/PartitionMetric';
import merge from 'lodash/merge';

export default {
  name: 'PartitionMetric',

  components: {
    BasePartitionMetric,
  },
  mixins: [ InteractsWithTheme ],

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
    format: '(0[.]00a)',
    data: [],
    prefix: '',
    suffix: '',
    userOptions: {},
    total: 0
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

    chartData () {
      const colors = this.colorsForData(this.data.length);
      return {
        datasets: [ {
          data: this.data.map((d) => d.value),
          backgroundColor: colors
        } ],
        labels: this.data.map((d) => d.label)
      };
    },

    options () {
      return merge({
        type: 'doughnut',
        responsive: true,
        cutoutPercentage: 70,
        maintainAspectRatio: false,
        rotation: Math.PI,
        circumference: Math.PI,
        tooltips: {
          mode: 'index',
          callbacks: {
            label: (item, data) => {
              //get the concerned dataset
              const dataset = data.datasets[item.datasetIndex];
              const label = data.labels[item.index];
              //calculate the total of this data set
              const total = dataset.data.reduce((previousValue, currentValue, currentIndex, array) => {
                return previousValue + currentValue;
              });
              //get the current items value
              const currentValue = dataset.data[item.index];
              //calculate the precentage based on the total and current item, also this does a rough rounding to give a whole number
              const percentage = Math.floor(((currentValue/total) * 100)+0.5);

              return `${label}: ${currentValue} (${percentage}%)`;
            }
          }
        }
      }, this.userOptions);
    },
    chartStyles () {
      return {
        height: '400px',
        width: '350px'
      };
    }
  },

  watch: {
    resourceId () {
      this.fetch();
    }
  },

  mounted () {
    this.fetch();
  },

  methods: {
    fetch () {
      this.loading = true;
      const { startAt, endAt, unit, timezone } = this;
      Minimum(ExTeal.request().get(this.metricEndpoint)).then(
        ({
          data: {
            metric: { data, options },
          },
        }) => {
          this.data = data;
          this.loading = false;
          this.userOptions = options || this.userOptions;
          this.total = this.data.reduce((agg, d) => agg + d.value, 0);
        }
      );
    }
  },
};
</script>
