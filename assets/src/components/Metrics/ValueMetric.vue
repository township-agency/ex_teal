<template>
  <div>
    <header class="uppercase text-xs mb-4">
      {{ card.title }}
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
import { Minimum } from 'ex-teal-js';
import BaseValueMetric from './Base/ValueMetric';

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
    },

    metricData: {
      type: Object,
      required: true
    }
  },

  data: () => ({
    loading: true,
    format: '(0[.]00a)',
    data: [],
    prefix: '',
    suffix: '',
    multiple_results: false
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
            metric: { data, prefix, suffix, format, multiple_results },
          },
        }) => {
          this.multiple_results = multiple_results;
          this.format = format || this.format;
          this.prefix = prefix || this.prefix;
          this.suffix = suffix || this.suffix;
          this.data = multiple_results ? data : [ { label: this.card.title, data }];
          this.loading = false;
        }
      );
    },
  },
};
</script>
