<template>
  <div
    :key="cardKey"
    class="px-3 mb-6 w-full"
    :class="widthClass"
  >
    <component
      :is="card.component"
      :class="cardSizeClass"
      :card="card"
      :resource="resource"
      :resource-name="resourceName"
      :resource-id="resourceId"
      :metric-data="metricData"
    />
  </div>
</template>

<script>

const CardSizes = ['1/2', '1/3', '2/3', '1/4', '3/4'];

export default {
  props: {
    card: {
      type: Object,
      required: true,
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

    metricData: {
      type: Object,
      required: true
    }
  },

  computed: {
    widthClass () {
      console.log(this.card);
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
  return `w-full lg:w-1/2 xl:w-${card.width}`;
}
</script>
