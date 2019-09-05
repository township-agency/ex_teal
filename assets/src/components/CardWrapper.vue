<template>
  <div
    :key="cardKey"
    class="px-3 mb-6"
    :class="widthClass"
  >
    <component
      :is="card.component"
      :class="cardSizeClass"
      :card="card"
      :resource="resource"
      :resource-name="resourceName"
      :resource-id="resourceId"
    />
  </div>
</template>

<script>
import { CardSizes } from 'ex-teal-js';

export default {
  props: {
    card: {
      type: Object,
      required: true,
    },

    size: {
      type: String,
      default: '',
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
  },

  computed: {
    widthClass () {
      return this.size == 'large' ? 'w-full' : calculateCardWidth(this.card);
    },

    cardSizeClass () {
      return this.size !== 'large' ? 'card-wrapper-panel' : '';
    },

    cardKey () {
      const { component, options: { uri } } = this.card;
      return `metric-${component}-${uri}`;
    }
  }
};

function calculateCardWidth (card) {
  return CardSizes.indexOf(card.width) !== -1 ? `w-${card.width}` : 'w-1/3';
}
</script>
