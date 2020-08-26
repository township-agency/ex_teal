<template>
  <div
    v-if="filteredCards.length > 0"
    class="flex flex-wrap -mx-3"
  >
    <card-wrapper
      v-for="card in filteredCards"
      :key="`${card.component}.${card.options.uri}`"
      :card="card"
      :resource="resource"
      :resource-name="resourceName"
      :resource-id="resourceId"
    />
  </div>
</template>

<script>
export default {
  props: {
    cards: {
      type: Array,
      required: true
    },

    resource: {
      type: Object,
      default () { return {}; }
    },

    resourceName: {
      type: String,
      required: false,
      default: ''
    },

    resourceId: {
      type: [ Number, String ],
      default: ''
    },

    onlyOnDetail: {
      type: Boolean,
      default: false,
    }
  },

  computed: {
    filteredCards () {
      if (this.onlyOnDetail) {
        return this.cards.filter(c => c.only_on_detail == true);
      }

      return this.cards.filter(c => c.only_on_detail == false);
    },
  },
};
</script>
