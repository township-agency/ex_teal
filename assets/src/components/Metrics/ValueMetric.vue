<template>
  <BaseValueMetric
    :title="card.title"
    :previous="previous"
    :value="value"
    :ranges="card.options.ranges"
    :format="format"
    :prefix="prefix"
    :suffix="suffix"
    :selected-range-key="selectedRangeKey"
    :loading="loading"
    @selected="handleRangeSelected"
  />
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
    }
  },

  data: () => ({
    loading: true,
    format: '(0[.]00a)',
    value: 0,
    previous: 0,
    prefix: '',
    suffix: '',
    selectedRangeKey: null,
  }),

  computed: {
    hasRanges () {
      return Object.keys(this.card.options.ranges).length > 0;
    },

    rangePayload () {
      return this.hasRanges ? { params: { range: this.selectedRangeKey } } : {};
    },

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
  },

  created () {
    if (this.hasRanges) {
      const options = this.card.options.ranges;
      const keys = Object.keys(options);
      
      this.selectedRangeKey = keys[0];
    }
  },

  mounted () {
    this.fetch(this.selectedRangeKey);
  },

  methods: {
    handleRangeSelected (key) {
      this.selectedRangeKey = key;
      this.fetch();
    },

    fetch () {
      this.loading = true;
      Minimum(ExTeal.request().get(this.metricEndpoint, this.rangePayload)).then(
        ({
          data: {
            metric: { current, previous, prefix, suffix, format },
          },
        }) => {
          this.value = current;
          this.format = format || this.format;
          this.prefix = prefix || this.prefix;
          this.suffix = suffix || this.suffix;
          this.previous = previous;
          this.loading = false;
        }
      );
    },
  },
};
</script>
