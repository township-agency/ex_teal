<template>
  <div>
    <div class="lg:flex lg:items-center lg:justify-between pb-6 w-full">
      <heading class="lg:flex md:items-center mb-4 lg:mb-0">
        {{ dashboard.title }}
      </heading>
    </div>

    <div v-if="shouldShowCards">
      <cards
        v-if="cards.length > 0"
        :cards="cards"
      />
    </div>
  </div>
</template>

<script>
import { HasCards } from '@/mixins';
import find from 'lodash/find';

export default {
  mixins: [ HasCards ],

  props: {
    uri: {
      type: String,
      required: false,
      default: 'main'
    }
  },

  computed: {
    cardsEndpoint () {
      return `/api/dashboards/${this.uri}`;
    },

    dashboard () {
      return find(ExTeal.config.dashboards, dashboard => dashboard.uri == this.uri);
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
  }
};
</script>
