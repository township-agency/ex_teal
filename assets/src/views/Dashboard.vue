<template>
  <div>
    <heading
      v-if="cards.length > 1"
      class="mb-6"
    >
      Dashboard
    </heading>

    <div v-if="shouldShowCards">
      <cards
        v-if="smallCards.length > 0"
        :cards="smallCards"
        class="mb-3"
      />
      <cards
        v-if="largeCards.length > 0"
        :cards="largeCards"
        size="large"
      />
    </div>
  </div>
</template>

<script>
import { HasCards } from 'ex-teal-js';
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
  }
};
</script>
