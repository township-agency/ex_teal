<template>
  <div>
    <header class="uppercase text-xs mb-4">{{card.title}}</header>
    <loading-card
      :loading="loading"
    >
      <div class="m-4">
        <area-chart
          :data="areaData"
          :prefix="prefix"
          :suffix="suffix"
          :library="{showLines: true}"
          :dataset="dataStyles"
        />
      </div>
    </loading-card>
  </div>
</template>

<script>
import { Minimum } from 'ex-teal-js';
import BaseTrendMetric from './Base/TrendMetric';

export default {
  name: 'TrendMetric',


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

    areaData () {
      return this.data.reduce((acc, { date, value }) => {
        acc[date] = value;
        return acc;
      }, {});
    },

    dataStyles () {
      return {
        pointRadius: 2
      };
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
      const { startAt, endAt, unit, timezone } = this.metricData;
      Minimum(ExTeal.request().get(this.metricEndpoint, { params: {
        start_at: startAt.toISO({ suppressMilliseconds: true }),
        end_at: endAt.toISO({ suppressMilliseconds: true }),
        unit,
        timezone
      } })).then(
        ({
          data: {
            metric: { data, prefix, suffix },
          },
        }) => {
          this.prefix = prefix || this.prefix;
          this.suffix = suffix || this.suffix;
          this.data = data;
          this.loading = false;
        }
      );
    },
  },
};
</script>
